import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book_models.dart';
import '../models/player_state.dart';

class ChapterScreen extends StatefulWidget {
  final Chapter chapter;
  final VoidCallback onNextChapter;
  final VoidCallback? onDream;

  const ChapterScreen({Key? key, required this.chapter, required this.onNextChapter, this.onDream}) : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  String? currentParagraphId;
  bool isCombatInitialized = false;
  int? enemyHp;
  String combatLog = "";

  @override
  void initState() {
    super.initState();
    if (widget.chapter.type == ChapterType.jeu) {
      currentParagraphId = widget.chapter.paragrapheDepart;
    }
  }

  void _goToParagraph(String nextId) {
    setState(() {
      currentParagraphId = nextId;
      isCombatInitialized = false;
      enemyHp = null;
      combatLog = "";
    });
  }

  void _lancerAssaut(PlayerState player, Enemy enemy) {
    final resultatPip = player.attaqueDePip();
    setState(() {
      combatLog = resultatPip['message'];
      if (resultatPip['touche']) {
        enemyHp = enemyHp! - (resultatPip['dommages'] as int);
        if (enemyHp! <= 0) {
          enemyHp = 0;
          combatLog += "\n\n**VICTOIRE !** Vous avez terrassé l'ennemi !";
        }
      }
      if (enemyHp! > 0) {
        int jetEnnemi = player.lancerDes(2);
        int degatsEnnemi = player.calculerDommages(jetEnnemi);
        if (degatsEnnemi > 0) {
          combatLog += "\n\nL'ennemi riposte et vous arrache $degatsEnnemi Points de Vie !";
          player.modifierPointsDeVie(-degatsEnnemi);
        } else {
          combatLog += "\n\nL'ennemi riposte mais son coup fend l'air !";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title),
        actions: [
          Consumer<PlayerState>(
            builder: (context, player, child) => Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  "❤️ ${player.pointsDeVie}/${player.pointsDeVieMax}",
                  style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFFD4AF37)),
                ),
              ),
            ),
          ),
          if (widget.chapter.type == ChapterType.jeu && widget.onDream != null)
            IconButton(icon: const Icon(Icons.nights_stay, color: Color(0xFFD4AF37)), onPressed: widget.onDream),
        ],
      ),
      // Le fond du donjon
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1614), Color(0xFF0D0A09)],
          ),
        ),
        child: widget.chapter.type == ChapterType.narration ? _buildNarrationView() : _buildInteractiveView(),
      ),
    );
  }

  Widget _buildNarrationView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: MarkdownBody(
              data: widget.chapter.contenu ?? "Contenu introuvable.",
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 18, height: 1.6, color: Color(0xFFEBE3D1)),
                textAlign: WrapAlignment.spaceBetween,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: widget.onNextChapter,
            style: _fantasyButtonStyle(),
            child: Text("CONTINUER", style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveView() {
    final paragraph = widget.chapter.paragraphes?.firstWhere(
      (p) => p.id == currentParagraphId,
      orElse: () => Paragraph(id: 'error', text: 'Paragraphe introuvable.'),
    );

    if (paragraph == null || paragraph.id == 'error') return const Center(child: Text("Erreur de chargement."));

    final player = Provider.of<PlayerState>(context);

    if (paragraph.enemy != null && !isCombatInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          enemyHp = paragraph.enemy!.lifePoints;
          isCombatInitialized = true;
          combatLog = "Un affrontement contre ${paragraph.enemy!.name} débute !";
        });
      });
    }

    bool combatEnCours = (isCombatInitialized && enemyHp != null && enemyHp! > 0 && !player.estMort && !player.estEvanoui);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numéro du paragraphe stylisé
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.keyboard_double_arrow_down, color: Color(0xFFD4AF37)),
                      const SizedBox(height: 8),
                      Text(
                        "~ ${paragraph.id} ~", 
                        style: GoogleFonts.cinzel(fontSize: 42, fontWeight: FontWeight.w900, color: const Color(0xFFD4AF37)),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                
                MarkdownBody(
                  data: paragraph.text,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 18, height: 1.6, color: Color(0xFFEBE3D1)),
                    textAlign: WrapAlignment.spaceBetween,
                  ),
                ),
                
                // --- ARÈNE DE COMBAT (Style D&D) ---
                if (isCombatInitialized && enemyHp != null) ...[
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1515), // Rouge très sombre
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 2), // Bordure or
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        Text("⚔️ RENCONTRE ⚔️", style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 22, fontWeight: FontWeight.bold)),
                        const Divider(color: Color(0xFFD4AF37), thickness: 1, height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text("PIP", style: TextStyle(color: Color(0xFFEBE3D1), fontWeight: FontWeight.bold)),
                                Text("${player.pointsDeVie} PV", style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                Text(paragraph.enemy!.name.toUpperCase(), style: const TextStyle(color: Color(0xFFEBE3D1), fontWeight: FontWeight.bold)),
                                Text("$enemyHp PV", style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(4)),
                          child: MarkdownBody(
                            data: combatLog,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: Color(0xFFEBE3D1), fontSize: 15, fontStyle: FontStyle.italic),
                              strong: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        if (combatEnCours)
                          ElevatedButton.icon(
                            onPressed: () => _lancerAssaut(player, paragraph.enemy!),
                            icon: const Icon(Icons.casino, color: Color(0xFFD4AF37)),
                            label: Text("LANCER LES DÉS", style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000), // Bouton d'attaque rouge
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              side: const BorderSide(color: Color(0xFFD4AF37)),
                            ),
                          ),
                          
                        if (player.estMort)
                          Text("VOUS AVEZ PÉRI...", style: GoogleFonts.cinzel(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
                        if (player.estEvanoui && !player.estMort)
                          Text("VOUS SOMBREZ DANS L'INCONSCIENCE...", style: GoogleFonts.cinzel(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
        
        // --- BOUTONS DE CHOIX ---
        if (!combatEnCours && !player.estMort && !player.estEvanoui && paragraph.choices != null && paragraph.choices!.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF0D0A09),
              border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1)), // Ligne dorée au dessus des choix
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: paragraph.choices!.map((choice) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () => _goToParagraph(choice.nextId),
                  style: _fantasyButtonStyle(),
                  child: Text(
                    choice.text.toUpperCase(), 
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1),
                  ),
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }

  // Style générique pour les boutons d'action (Façon plaque de métal gravée)
  ButtonStyle _fantasyButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2A231E), // Cuir sombre
      foregroundColor: const Color(0xFFEBE3D1), // Texte beige clair
      padding: const EdgeInsets.symmetric(vertical: 18),
      side: const BorderSide(color: Color(0xFF5A4A3E), width: 1), // Bordure subtile
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 2,
    );
  }
}

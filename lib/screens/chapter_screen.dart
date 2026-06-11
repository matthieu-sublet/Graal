import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
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
  
  // Variables spécifiques au combat
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

  // Fonction pour changer de paragraphe et réinitialiser les combats
  void _goToParagraph(String nextId) {
    setState(() {
      currentParagraphId = nextId;
      isCombatInitialized = false;
      enemyHp = null;
      combatLog = "";
    });
  }

  // Mécanique de combat : Tour de Pip + Tour du Monstre
  void _lancerAssaut(PlayerState player, Enemy enemy) {
    // 1. Tour de Pip
    final resultatPip = player.attaqueDePip();
    setState(() {
      combatLog = resultatPip['message'];
      
      if (resultatPip['touche']) {
        enemyHp = enemyHp! - (resultatPip['dommages'] as int);
        if (enemyHp! <= 0) {
          enemyHp = 0;
          combatLog += "\n\n**VICTOIRE !** Vous avez terrassé le ${enemy.name} !";
        }
      }

      // 2. Tour de l'Ennemi (s'il est encore en vie !)
      if (enemyHp! > 0) {
        int jetEnnemi = player.lancerDes(2);
        int degatsEnnemi = player.calculerDommages(jetEnnemi);
        
        if (degatsEnnemi > 0) {
          combatLog += "\n\nLe ${enemy.name} riposte (Jet: $jetEnnemi) et vous arrache $degatsEnnemi Points de Vie !";
          player.modifierPointsDeVie(-degatsEnnemi);
        } else {
          combatLog += "\n\nLe ${enemy.name} riposte (Jet: $jetEnnemi) mais son coup fend l'air sans vous toucher !";
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
          // On affiche le bouton PV en haut à droite
          Consumer<PlayerState>(
            builder: (context, player, child) => Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  "❤️ ${player.pointsDeVie}/${player.pointsDeVieMax} PV",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF6F1E3)),
                ),
              ),
            ),
          ),
          if (widget.chapter.type == ChapterType.jeu && widget.onDream != null)
            IconButton(icon: const Icon(Icons.nights_stay), onPressed: widget.onDream),
        ],
      ),
      body: widget.chapter.type == ChapterType.narration ? _buildNarrationView() : _buildInteractiveView(),
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
                p: const TextStyle(fontSize: 18, height: 1.6, color: Color(0xFF2C2621)),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: widget.onNextChapter,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text("CONTINUER", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
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

    // Initialisation du combat au chargement du paragraphe
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
                Center(
                  child: Text(paragraph.id, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary, fontFamily: 'Georgia')),
                ),
                const SizedBox(height: 32),
                // Cherche cette partie dans ton fichier chapter_screen.dart et ajoute le textAlign :
MarkdownBody(
  data: paragraph.text, // ou widget.chapter.contenu
  styleSheet: MarkdownStyleSheet(
    p: const TextStyle(fontSize: 18, height: 1.6, color: Color(0xFF2C2621)),
    textAlign: WrapAlignment.wrap, // Assure que le texte prend bien toute la place
  ),
),

                
                // --- ZONE DE COMBAT VISUELLE ---
                if (isCombatInitialized && enemyHp != null) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1A17),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF8B0000), width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Pip : ${player.pointsDeVie} PV", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("⚔️", style: const TextStyle(fontSize: 24)),
                            Text("${paragraph.enemy!.name} : $enemyHp PV", style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        MarkdownBody(
                          data: combatLog,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: Color(0xFFEBE3D1), fontSize: 16, fontStyle: FontStyle.italic),
                            strong: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Bouton d'attaque (Visible seulement si le monstre et Pip sont en vie)
                        if (combatEnCours)
                          ElevatedButton.icon(
                            onPressed: () => _lancerAssaut(player, paragraph.enemy!),
                            icon: const Icon(Icons.casino),
                            label: const Text("LANCER LES DÉS (ATTAQUER)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                          
                        if (player.estMort)
                          const Text("💀 VOUS ÊTES MORT...", style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
                        if (player.estEvanoui && !player.estMort)
                          const Text("💫 VOUS ÊTES ÉVANOUI (5 PV ou moins)...", style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
        
        // Les choix (Désactivés pendant que le combat fait rage ou si Pip est KO)
        if (!combatEnCours && !player.estMort && !player.estEvanoui && paragraph.choices != null && paragraph.choices!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20.0),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: paragraph.choices!.map((choice) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () => _goToParagraph(choice.nextId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBE3D1),
                    foregroundColor: const Color(0xFF2C2621),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.black.withOpacity(0.2)),
                  ),
                  child: Text(choice.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }
}

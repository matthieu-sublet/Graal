import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/book_models.dart';

class ChapterScreen extends StatefulWidget {
  final Chapter chapter;
  final VoidCallback onNextChapter;
  final VoidCallback? onDream;

  const ChapterScreen({
    Key? key,
    required this.chapter,
    required this.onNextChapter,
    this.onDream,
  }) : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  String? currentParagraphId;

  @override
  void initState() {
    super.initState();
    if (widget.chapter.type == ChapterType.jeu) {
      currentParagraphId = widget.chapter.paragrapheDepart;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title),
        actions: [
          if (widget.chapter.type == ChapterType.jeu && widget.onDream != null)
            IconButton(
              icon: const Icon(Icons.nights_stay),
              tooltip: "Dormir (Le temps du rêve)",
              onPressed: widget.onDream,
            ),
        ],
      ),
      body: widget.chapter.type == ChapterType.narration
          ? _buildNarrationView()
          : _buildInteractiveView(),
    );
  }

    /// VUE 1 : Affichage d'un chapitre narratif linéaire
  Widget _buildNarrationView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: MarkdownBody(
              data: widget.chapter.contenu ?? "Contenu introuvable.",
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  fontSize: 18, // Texte plus grand
                  height: 1.6, // Plus d'espace entre les lignes
                  color: Color(0xFF2C2621),
                  letterSpacing: 0.3,
                ),
                strong: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
          child: ElevatedButton(
            onPressed: widget.onNextChapter,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Boutons moins ronds, plus "livre"
              ),
            ),
            child: const Text(
              "CONTINUER", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)
            ),
          ),
        ),
      ],
    );
  }

  /// VUE 2 : Affichage d'un chapitre jouable avec des choix
  Widget _buildInteractiveView() {
    final paragraph = widget.chapter.paragraphes?.firstWhere(
      (p) => p.id == currentParagraphId,
      orElse: () => Paragraph(id: 'error', text: 'Paragraphe introuvable.'),
    );

    if (paragraph == null || paragraph.id == 'error') {
      return const Center(child: Text("Erreur de chargement."));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Un grand numéro stylisé pour le paragraphe
                Center(
                  child: Text(
                    paragraph.id,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                      fontFamily: 'Georgia', // Une touche très "vieux livre" pour les chiffres
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                MarkdownBody(
                  data: paragraph.text,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      fontSize: 18, 
                      height: 1.6,
                      color: Color(0xFF2C2621),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (paragraph.choices != null && paragraph.choices!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: paragraph.choices!.map((choice) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentParagraphId = choice.nextId;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEBE3D1), // Bouton couleur papier
                      foregroundColor: const Color(0xFF2C2621), // Texte sombre
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      elevation: 1,
                      side: BorderSide(color: Colors.black.withOpacity(0.2)), // Petite bordure fine
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      choice.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

}

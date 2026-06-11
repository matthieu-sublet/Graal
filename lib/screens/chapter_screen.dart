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

  Widget _buildNarrationView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: MarkdownBody(
              data: widget.chapter.contenu ?? "Contenu introuvable.",
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: widget.onNextChapter,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text("Continuer"),
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

    if (paragraph == null || paragraph.id == 'error') {
      return const Center(child: Text("Erreur : Impossible de charger le paragraphe."));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Paragraphe ${paragraph.id}",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                MarkdownBody(
                  data: paragraph.text,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (paragraph.choices != null && paragraph.choices!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: paragraph.choices!.map((choice) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        currentParagraphId = choice.nextId;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      choice.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
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

import 'package:flutter/services.dart';
import '../models/book_models.dart';

class BookParser {
  static Future<GameBook> parseMarkdownFile(String path) async {
    final String content = await rootBundle.loadString(path);

    final expParagraphe = RegExp(r'(?:##\s*)?\*\*(\d+)\*\*');
    final expChoix = RegExp(r'rendez[- ]vous au (\d+)', caseSensitive: false);
    final expEnnemi = RegExp(r'([A-Za-zÀ-ÖØ-öø-ÿ\s]+)\s*:\s*(\d+)\s*POINTS\s*DE\s*VIE', caseSensitive: false);

    final matches = expParagraphe.allMatches(content).toList();
    List<Paragraph> paragraphesJouables = [];

    String introText = "Introduction introuvable.";
    if (matches.isNotEmpty) {
      introText = _cleanOcrText(content.substring(0, matches.first.start));
    }

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      final id = match.group(1)!;

      final start = match.end;
      final end = (i + 1 < matches.length) ? matches[i + 1].start : content.length;
      
      // On extrait et on NETTOIE le texte du paragraphe
      String textBloc = _cleanOcrText(content.substring(start, end));

      final matchEnnemi = expEnnemi.firstMatch(textBloc);
      Enemy? enemyInParagraph;
      if (matchEnnemi != null) {
        enemyInParagraph = Enemy(
          name: matchEnnemi.group(1)!.trim(),
          lifePoints: int.parse(matchEnnemi.group(2)!),
        );
      }

      final choiceMatches = expChoix.allMatches(textBloc);
      List<Choice> choices = [];
      for (final cMatch in choiceMatches) {
        choices.add(Choice(text: "Aller au paragraphe ${cMatch.group(1)!}", nextId: cMatch.group(1)!));
      }

      paragraphesJouables.add(Paragraph(
        id: id,
        text: textBloc,
        choices: choices,
        enemy: enemyInParagraph,
      ));
    }

    return GameBook(
      annexes: {},
      tempsDuReve: DreamTime(description: "Règles", sections: []),
      histoire: [
        Chapter(order: 1, title: "Le Royaume d'Avalon", type: ChapterType.narration, contenu: introText, suivant: "jeu"),
        Chapter(order: 2, title: "L'Aventure Commence", type: ChapterType.jeu, paragrapheDepart: matches.isNotEmpty ? matches.first.group(1)! : "1", paragraphes: paragraphesJouables)
      ],
    );
  }

  /// Fonction utilitaire pour nettoyer les erreurs de scan (OCR)
  static String _cleanOcrText(String rawText) {
    String cleanText = rawText.trim();
    
    // 1. Retire les artefacts de scan courants (tu pourras en ajouter ici si besoin)
    cleanText = cleanText.replaceAll(RegExp(r'\[—\]'), '-');
    cleanText = cleanText.replaceAll(RegExp(r'\s+[|~]\s+'), ' ');

    // 2. Le plus important : Remplacer les simples retours à la ligne par des espaces
    // (Cela permet au texte de s'adapter à la largeur de ton téléphone)
    // Mais on conserve les doubles retours à la ligne qui sont de vrais paragraphes.
    cleanText = cleanText.replaceAll(RegExp(r'(?<!\n)\n(?!\n)'), ' ');

    // 3. Supprimer les espaces multiples créés par l'étape précédente
    cleanText = cleanText.replaceAll(RegExp(r' {2,}'), ' ');

    return cleanText;
  }
}

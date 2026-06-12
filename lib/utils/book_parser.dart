import 'package:flutter/services.dart';
import '../models/book_models.dart';

class BookParser {
  static Future<GameBook> parseMarkdownFile(String path) async {
    final String rawContent = await rootBundle.loadString(path);

    // 1. D'abord, on "nettoie" complètement le texte de tous les déchets de l'OCR
    final String content = _cleanOcrText(rawContent);

    // 2. Les nouvelles expressions régulières (beaucoup plus précises)
    // On exige que le numéro (ex: **14**) soit au DÉBUT d'une ligne pour être un vrai paragraphe
    final expParagraphe = RegExp(r'^\s*(?:##\s*)?\*\*(\d+)\*\*', multiLine: true);
    
    // On capture toutes les tournures du livre : "rendez-vous au 14", "rendez-vous donc au 3", etc.
    final expChoix = RegExp(r'rendez\s*[- ]\s*vous(?:\s+donc|\s+directement)?\s+au\s+\**(\d+)\**', caseSensitive: false);
    
    // On capture la vie des monstres
    final expEnnemi = RegExp(r'([A-Za-zÀ-ÖØ-öø-ÿ\s]+)\s*:\s*(\d+)\s*POINTS\s*DE\s*VIE', caseSensitive: false);

    final matches = expParagraphe.allMatches(content).toList();
    List<Paragraph> paragraphesJouables = [];

    String introText = "Introduction introuvable.";
    if (matches.isNotEmpty) {
      introText = content.substring(0, matches.first.start).trim();
    }

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      final id = match.group(1)!; // Le numéro du paragraphe

      final start = match.end;
      final end = (i + 1 < matches.length) ? matches[i + 1].start : content.length;
      
      String textBloc = content.substring(start, end).trim();

      // Vérifie s'il y a un monstre
      final matchEnnemi = expEnnemi.firstMatch(textBloc);
      Enemy? enemyInParagraph;
      if (matchEnnemi != null) {
        enemyInParagraph = Enemy(
          name: matchEnnemi.group(1)!.trim(),
          lifePoints: int.parse(matchEnnemi.group(2)!),
        );
      }

      // Génère les choix pour les boutons
      final choiceMatches = expChoix.allMatches(textBloc);
      List<Choice> choices = [];
      Set<String> nextIdsFound = {}; // Pour éviter les boutons en double
      
      for (final cMatch in choiceMatches) {
        final nextId = cMatch.group(1)!;
        if (!nextIdsFound.contains(nextId)) {
          choices.add(Choice(text: "ALLER AU $nextId", nextId: nextId));
          nextIdsFound.add(nextId);
        }
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

  /// Le "Nettoyeur" automatique de déchets OCR
  static String _cleanOcrText(String rawText) {
    String cleanText = rawText;
    
    // 1. Détruire les énormes blocs d'images factices
    cleanText = cleanText.replaceAll(RegExp(r'\*\*==> picture.*?<==\*\*', dotAll: true), '');
    cleanText = cleanText.replaceAll(RegExp(r'\*\*-----\s*Start of picture text\s*-----\*\*.*?\*\*-----\s*End of picture text\s*-----\*\*', dotAll: true), '');
    
    // 2. Transformer les balises HTML qui traînent en simples espaces
    cleanText = cleanText.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ');

    // 3. Réparer les phrases coupées en plein milieu (les simples sauts de ligne)
    // On conserve les doubles sauts de ligne qui sont de vrais paragraphes.
    cleanText = cleanText.replaceAll(RegExp(r'(?<!\n)\n(?!\n)'), ' ');

    // 4. Nettoyer les espaces en trop
    cleanText = cleanText.replaceAll(RegExp(r' {2,}'), ' ');

    return cleanText.trim();
  }
}

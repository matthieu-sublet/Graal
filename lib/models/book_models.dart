enum ChapterType { narration, jeu }

class GameBook {
  final Map<String, String> annexes;
  final DreamTime tempsDuReve;
  final List<Chapter> histoire;

  GameBook({
    required this.annexes,
    required this.tempsDuReve,
    required this.histoire,
  });
}

class DreamTime {
  final String description;
  final List<Paragraph> sections;

  DreamTime({required this.description, required this.sections});
}

class Chapter {
  final int order;
  final String title;
  final ChapterType type;
  final String? contenu;
  final String? suivant;
  final String? paragrapheDepart;
  final List<Paragraph>? paragraphes;

  Chapter({
    required this.order,
    required this.title,
    required this.type,
    this.contenu,
    this.suivant,
    this.paragrapheDepart,
    this.paragraphes,
  });
}

class Paragraph {
  final String id;
  final String text;
  final List<Choice>? choices;

  Paragraph({
    required this.id,
    required this.text,
    this.choices,
  });
}

class Choice {
  final String text;
  final String nextId;
  final Map<String, dynamic>? condition;

  Choice({
    required this.text,
    required this.nextId,
    this.condition,
  });
}

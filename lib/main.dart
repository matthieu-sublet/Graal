import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/player_state.dart';
import 'utils/book_parser.dart';
import 'screens/chapter_screen.dart';

void main() {
  runApp(
    // On injecte l'état du personnage dans toute l'application
    ChangeNotifierProvider(
      create: (context) => PlayerState(),
      child: const MonApplication(),
    ),
  );
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quête du Graal',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7), // Fond style vieux papier
      ),
      home: const MenuPrincipal(),
    );
  }
}

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("La Quête du Graal")),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () async {
            // 1. Analyse automatique du fichier Markdown
            final gameBook = await BookParser.parseMarkdownFile('assets/livre.md');
            
            // 2. Lancement du premier chapitre
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChapterScreen(
                    chapter: gameBook.histoire.first,
                    onNextChapter: () {
                      // 3. Bascule vers l'aventure interactive au clic sur Continuer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterScreen(
                            chapter: gameBook.histoire[1], 
                            onNextChapter: () {}, 
                            onDream: () {
                              print("Le joueur s'endort et entre dans le Temps du Rêve...");
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          },
          child: const Text("Commencer l'Aventure"),
        ),
      ),
    );
  }
}

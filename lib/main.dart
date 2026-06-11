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

import 'package:google_fonts/google_fonts.dart'; // Ajoute cet import en haut

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quête du Graal',
      debugShowCheckedModeBanner: false, // Retire le petit bandeau "DEBUG"
      theme: ThemeData(
        // Couleurs principales (Fond parchemin, textes sombres)
        scaffoldBackgroundColor: const Color(0xFFF6F1E3), 
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF5A2A22), // Un rouge/brun profond pour les accents
          onPrimary: Colors.white,
          surface: Color(0xFFEBE3D1), // Parchemin un peu plus sombre pour les boutons
          onSurface: Color(0xFF2C2621), // Couleur de l'encre (presque noir)
        ),
        // On applique la police Lora à toute l'application
        textTheme: GoogleFonts.loraTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1A17), // App bar très sombre
          foregroundColor: Color(0xFFF6F1E3),
          elevation: 4,
          centerTitle: true,
        ),
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

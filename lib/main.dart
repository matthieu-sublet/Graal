import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/player_state.dart';
import 'utils/book_parser.dart';
import 'screens/chapter_screen.dart';

void main() {
  runApp(
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF14110F), // Noir/Brun très sombre
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B0000), // Rouge Sang
          secondary: Color(0xFFD4AF37), // Or vieilli
          surface: Color(0xFF2A231E), // Cuir sombre
        ),
        textTheme: GoogleFonts.loraTextTheme(ThemeData.dark().textTheme).copyWith(
          // Textes génériques en beige parchemin
          bodyMedium: const TextStyle(color: Color(0xFFEBE3D1)), 
          bodyLarge: const TextStyle(color: Color(0xFFEBE3D1)),
          // Titres avec la police épique Cinzel
          headlineSmall: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          displayLarge: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontWeight: FontWeight.w900),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0A0807), // Presque noir
          foregroundColor: const Color(0xFFD4AF37), // Or
          elevation: 10,
          centerTitle: true,
          titleTextStyle: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold),
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
      body: Container(
        // Dégradé radial pour un effet "lumière de torche dans le donjon"
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF3A1C1C), Color(0xFF0A0807)],
            radius: 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "LA QUÊTE\nDU GRAAL", 
                textAlign: TextAlign.center, 
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48, height: 1.2, shadows: [
                  const Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2, 2))
                ]),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14110F), // Fond sombre
                  foregroundColor: const Color(0xFFD4AF37), // Texte or
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  side: const BorderSide(color: Color(0xFFD4AF37), width: 2), // Bordure dorée
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // Bords presque carrés, plus "RPG"
                  ),
                  elevation: 8,
                ),
                onPressed: () async {
                  final gameBook = await BookParser.parseMarkdownFile('assets/livre.md');
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterScreen(
                          chapter: gameBook.histoire.first,
                          onNextChapter: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterScreen(
                                  chapter: gameBook.histoire[1], 
                                  onNextChapter: () {}, 
                                  onDream: () {},
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  "COMMENCER L'AVENTURE", 
                  style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // L'import est bien tout en haut !

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
        scaffoldBackgroundColor: const Color(0xFFF6F1E3), 
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF5A2A22), 
          onPrimary: Colors.white,
          surface: Color(0xFFEBE3D1), 
          onSurface: Color(0xFF2C2621), 
        ),
        textTheme: GoogleFonts.loraTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1A17), 
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
            backgroundColor: const Color(0xFF5A2A22),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(fontSize: 20, letterSpacing: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
          child: const Text("COMMENCER L'AVENTURE"),
        ),
      ),
    );
  }
}

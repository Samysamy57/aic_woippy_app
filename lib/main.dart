// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:aic_woippy_app/src/features/splash/presentation/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 1. NOUVELLE COULEUR PRIMAIRE ---
    // Un vert forêt, plus profond et élégant.
    const primaryColor = Color(0xFF62AC45);
    final baseTextTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIC Woippy',
      // --- DÉBUT DE LA DÉFINITION DU THÈME ---
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),

        // --- 2. TAILLE DES TEXTES AJUSTÉE ---
        textTheme: baseTextTheme.copyWith(
          // Titres très grands (ex: "Bienvenue")
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontSize: 28),
          // Titres de section (ex: "Prochaines distributions")
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontSize: 22),
          // Titres de cartes ou d'éléments importants
          titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: 18),
        ),

        // --- 3. HAUTEUR DE L'APPBAR RÉDUITE ---
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          centerTitle: true,
          toolbarHeight: 40, // Hauteur personnalisée (défaut: 56)
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 10, // Taille du titre de l'AppBar légèrement réduite
            fontWeight: FontWeight.w600,
          ),
        ),

        // Le reste du thème utilise automatiquement la nouvelle couleur
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
      // --- FIN DE LA DÉFINITION DU THÈME ---
      home: const SplashScreen(),
    );
  }
}
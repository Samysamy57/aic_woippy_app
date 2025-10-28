// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:aic_woippy_app/src/features/splash/presentation/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart'; // <-- AJOUTER CET IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- MODIFICATION DE LA LOGIQUE APP CHECK ---
  // On utilise le "provider" de débogage uniquement en mode debug.
  // En mode release (TestFlight, App Store), il utilisera App Attest.
  final appleProvider = kDebugMode ? AppleProvider.debug : AppleProvider.appAttest;

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Gardez debug pour Android pour l'instant
    appleProvider: appleProvider,
  );
  // --- FIN DE LA MODIFICATION ---

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
    const primaryColor = Color(0xFF33803B); // Le nouveau vert
    final baseTextTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIC Woippy',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),

        textTheme: baseTextTheme.copyWith(
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontSize: 28),
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontSize: 22),
          titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: 18),
        ),

        // --- DÉBUT DE LA CORRECTION ---
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0, // 1. On retire l'ombre en mettant l'élévation à 0
          centerTitle: true,
          toolbarHeight: 50,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),

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
      home: const SplashScreen(),
    );
  }
}
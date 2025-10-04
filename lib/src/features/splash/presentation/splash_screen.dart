// lib/src/features/splash/presentation/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aic_woippy_app/src/features/auth/presentation/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Déclenche la navigation après 3 secondes
    Timer(
      const Duration(seconds: 3),
          () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Utilisation d'un widget pour une animation de fondu simple
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, double opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: const Icon(
                Icons.mosque_outlined,
                size: 100,
                color: Color(0xFF2E7D32), // Un vert profond et élégant
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "AIC Woippy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            )
          ],
        ),
      ),
    );
  }
}
// lib/src/features/distributions/presentation/announcements_screen.dart
import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Page des Annonces',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
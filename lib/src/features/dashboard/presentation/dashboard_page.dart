import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aic_woippy_app/src/features/auth/application/auth_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On récupère l'état de l'utilisateur pour, par exemple, afficher son nom
    final user = ref.watch(authStateChangesProvider).value;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // On retire l'AppBar car le bandeau est déjà dans home_screen.dart
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${user?.displayName ?? user?.email?.split('@')[0] ?? 'Étudiant'} !',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenue sur votre espace.',
              style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            // Ici, nous ajouterons plus tard les widgets importants
            const Center(
              child: Text(
                'Votre tableau de bord principal.',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
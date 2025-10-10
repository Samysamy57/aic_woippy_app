// lib/src/features/auth/presentation/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aic_woippy_app/src/features/auth/application/auth_controller.dart';
import 'package:aic_woippy_app/src/features/auth/presentation/animated_auth_screen.dart';
import 'package:aic_woippy_app/src/features/auth/presentation/phone_verification_screen.dart';
import 'package:aic_woippy_app/src/features/dashboard/presentation/home_screen.dart';
import 'package:aic_woippy_app/src/features/profile/application/profile_provider.dart';
import 'package:aic_woippy_app/src/features/profile/presentation/dossier_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // 1. Pas d'utilisateur -> Écran de connexion
          return const AnimatedAuthScreen();
        } else {
          // Utilisateur connecté, on vérifie ses informations
          final userData = ref.watch(userDataProvider);
          return userData.when(
            data: (userModel) {
              if (userModel == null) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // --- CORRECTION À APPLIQUER ICI ---
              // On restaure la logique originale qui vérifie si le téléphone de l'utilisateur est validé.
              if (!userModel.phoneVerified) {
                return PhoneVerificationScreen(phoneNumber: userModel.phone);
              }
              // --- FIN DE LA CORRECTION ---

              // Le téléphone est vérifié, on regarde le statut du dossier
              final status = userModel.dossierStatus;
              if (status == 'not_submitted' || status == 'rejected') {
                return const DossierScreen();
              } else {
                // Tout est en ordre -> Page d'accueil
                return const HomeScreen();
              }
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, s) {
              // Gestion d'erreur...
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(authControllerProvider.notifier).signOut();
              });
              return const AnimatedAuthScreen();
            },
          );
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text("Erreur: $error"))),
    );
  }
}
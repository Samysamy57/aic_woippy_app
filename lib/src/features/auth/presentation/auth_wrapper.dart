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
          return const AnimatedAuthScreen();
        } else {
          final userData = ref.watch(userDataProvider);
          return userData.when(
            data: (userModel) {
              if (userModel == null) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // --- MODIFICATION DE TEST ICI ---
              // On force la condition à 'true' pour sauter l'écran de vérification.
              // C'était : if (!userModel.phoneVerified) {
              if (false) { // <-- MODIFICATION TEMPORAIRE
                // ------------------------------------

                return PhoneVerificationScreen(phoneNumber: userModel.phone);
              }

              final status = userModel.dossierStatus;
              if (status == 'not_submitted' || status == 'rejected') {
                return const DossierScreen();
              } else {
                return const HomeScreen();
              }
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, s) {
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
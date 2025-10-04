// lib/src/features/auth/presentation/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aic_woippy_app/src/features/auth/application/auth_controller.dart';
import 'package:aic_woippy_app/src/features/auth/presentation/login_screen.dart';
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
          return const LoginScreen();
        } else {
          final userData = ref.watch(userDataProvider);
          return userData.when(
            data: (userModel) {
              if (userModel == null) {
                // Ce cas peut se produire brièvement pendant la création du document.
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final status = userModel.dossierStatus;
              if (status == 'not_submitted' || status == 'rejected') {
                return const DossierScreen();
              } else {
                return const HomeScreen();
              }
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            // *** C'EST ICI QU'ON AJOUTE LA GESTION D'ERREUR ***
            error: (e, s) {
              // Si on a une erreur de permission, c'est probablement que l'utilisateur a été supprimé.
              // On le déconnecte de force pour nettoyer l'état de l'app.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(authControllerProvider.notifier).signOut();
              });
              // On affiche l'écran de connexion en attendant la déconnexion.
              return const LoginScreen();
            },
          );
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Erreur d\'authentification: $error'))),
    );
  }
}
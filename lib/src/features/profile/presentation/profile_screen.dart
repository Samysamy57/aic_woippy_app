// FILE: lib/src/features/profile/presentation/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aic_woippy_app/src/features/auth/application/auth_controller.dart';
import 'package:aic_woippy_app/src/features/auth/presentation/auth_wrapper.dart'; // NOUVELLE IMPORTATION
import 'package:aic_woippy_app/src/features/profile/application/profile_provider.dart';
import 'package:aic_woippy_app/src/features/profile/presentation/dossier_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(userDataProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        automaticallyImplyLeading: false,
      ),
      body: userDataAsync.when(
        data: (userModel) {
          if (userModel == null) {
            return const Center(
              child: Card(
                color: Colors.amberAccent,
                child: ListTile(
                  leading: Icon(Icons.warning_amber_rounded),
                  title: Text('Informations manquantes'),
                  subtitle: Text('Nous n\'avons pas pu trouver votre fiche. Veuillez vous déconnecter et vous réinscrire.'),
                ),
              ),
            );
          }

          final showDossierButton = userModel.dossierStatus == 'not_submitted' || userModel.dossierStatus == 'rejected';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. LE BANDEAU "ACTION REQUISE" EST COMPLÈTEMENT SUPPRIMÉ D'ICI

              // --- Section Informations Utilisateur ---
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Text(
                  '${userModel.firstName.isNotEmpty ? userModel.firstName[0] : ''}${userModel.lastName.isNotEmpty ? userModel.lastName[0] : ''}',
                  style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${userModel.firstName} ${userModel.lastName}',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(userModel.email),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Téléphone'),
                  subtitle: Text(userModel.phone),
                ),
              ),
              // 2. ON TRANSFORME LA CARTE DU STATUT EN BOUTON
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DossierScreen()),
                  );
                },
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Statut du dossier'),
                    subtitle: Text(
                      _getDossierStatusText(userModel.dossierStatus),
                      style: TextStyle(fontWeight: FontWeight.bold, color: _getDossierStatusColor(userModel.dossierStatus)),
                    ),
                    // 3. On ajoute une icône pour montrer que c'est cliquable
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDossierStatusIcon(userModel.dossierStatus),
                          color: _getDossierStatusColor(userModel.dossierStatus),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),

              // --- FIN DE LA CORRECTION ---

              // --- Section Déconnexion ---
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await ref.read(authControllerProvider.notifier).signOut();
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  // Fonctions utilitaires pour la lisibilité
  String _getDossierStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Approuvé';
      case 'pending':
        return 'En attente de validation';
      case 'rejected':
        return 'Rejeté';
      case 'not_submitted':
        return 'Non soumis';
      default:
        return 'Inconnu';
    }
  }

  Color _getDossierStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
      case 'not_submitted':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getDossierStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'not_submitted':
        return Icons.edit_document;
      default:
        return Icons.help_outline;
    }
  }
}
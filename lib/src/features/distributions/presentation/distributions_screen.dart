// lib/src/features/distributions/presentation/distributions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aic_woippy_app/src/features/distributions/presentation/widgets/dossier_action_banner.dart';
import 'widgets/upcoming_registration_banner.dart';
import 'package:aic_woippy_app/src/features/profile/application/profile_provider.dart';
import 'package:aic_woippy_app/src/features/distributions/application/distributions_provider.dart';
import 'package:aic_woippy_app/src/features/distributions/models/distribution_model.dart';
//import 'widgets/dossier_status_footer.dart';
import 'widgets/distribution_card.dart';
import 'package:aic_woippy_app/src/features/profile/presentation/dossier_screen.dart';

class DistributionsScreen extends ConsumerWidget {
  final VoidCallback navigateToProfileTab;
  const DistributionsScreen({super.key, required this.navigateToProfileTab});

  Widget _buildSection(BuildContext context, String title, AsyncValue<List<DistributionModel>> asyncData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        asyncData.when(
          data: (distributions) {
            if (distributions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Aucune distribution de ce type à venir."),
              );
            }
            return SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: distributions.length,
                itemBuilder: (context, index) {
                  if (index == distributions.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: DistributionCard(distribution: distributions[index]),
                    );
                  }
                  return DistributionCard(distribution: distributions[index]);
                },
              ),
            );
          },
          loading: () => const SizedBox(height: 170, child: Center(child: CircularProgressIndicator())),
          error: (e, s) => SizedBox(
              height: 170,
              child: Center(child: Text("Erreur de chargement de la section.", style: TextStyle(color: Colors.red)))),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalDistributionsAsync = ref.watch(normalDistributionsProvider);
    final quickDistributionsAsync = ref.watch(quickDistributionsProvider);
    final userDataAsync = ref.watch(userDataProvider);

    return userDataAsync.when(
      data: (userModel) {
        if (userModel == null) return const Center(child: Text("Utilisateur non trouvé."));
        final isApproved = userModel.dossierStatus == 'approved';

        // --- DÉBUT DE LA CORRECTION ---
        return Scaffold(
          body: Column(
            children: [
              // 1. On affiche le nouveau bandeau en haut si le dossier n'est pas approuvé
              if (!isApproved)
                DossierActionBanner(
                  status: userModel.dossierStatus,
                  rejectionReason: userModel.rejectionData?['reason'],
                ),
              // 2. Le reste de la page prend l'espace disponible
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      children: [
                        _buildSection(context, 'Prochaines distributions', normalDistributionsAsync),
                        _buildSection(context, 'Distributions Rapides', quickDistributionsAsync),
                        // Espace pour la bannière du bas
                        const SizedBox(height: 80),
                      ],
                    ),
                    // 3. La bannière pour la prochaine récupération reste en bas
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: UpcomingRegistrationBanner(),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        // --- FIN DE LA CORRECTION ---
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Erreur critique: Impossible de charger les données de l'utilisateur.\n$e")),
    );
  }
}

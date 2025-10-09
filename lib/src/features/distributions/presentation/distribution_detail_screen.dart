// lib/src/features/distributions/presentation/distribution_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aic_woippy_app/src/features/distributions/models/distribution_model.dart';
import 'package:aic_woippy_app/src/features/profile/application/profile_provider.dart';
import 'package:aic_woippy_app/src/features/distributions/application/distributions_provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'widgets/confirmation_popup.dart';
import 'widgets/view_qr_code_button.dart';
import 'widgets/collapsible_chip_list.dart';
import 'widgets/volunteer_confirmation_popup.dart';
// NOUVEL AJOUT : Importer le widget pour le fond
import 'package:aic_woippy_app/src/shared/widgets/background_container.dart';


class DistributionDetailScreen extends ConsumerWidget {
  final String distributionId;
  const DistributionDetailScreen({super.key, required this.distributionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distributionAsyncValue = ref.watch(distributionDetailProvider(distributionId));

    return distributionAsyncValue.when(
      data: (distribution) {
        final userData = ref.watch(userDataProvider).value;
        final userRegistrations = ref.watch(userRegistrationsProvider).value ?? [];
        final isRegistered = userRegistrations.any((doc) => doc.id.startsWith(distribution.id));


        return BackgroundContainer(
          imagePath: 'assets/images/background_main.png', // <-- AJOUTEZ CETTE LIGNE
          child: Scaffold(
            // MODIFICATION : Rendre le Scaffold transparent
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: BackButton(color: Colors.white),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderImage(distribution),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(distribution.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildInfoCard(context, icon: Icons.calendar_today, title: "Date et Heure", subtitle: DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR').format(distribution.date.toDate())),
                        const SizedBox(height: 8),
                        _buildInfoCard(context, icon: Icons.location_on, title: "Lieu", subtitle: distribution.location),
                      ],
                    ),
                  ),
                  _buildSectionTitle(context, 'Aperçu du panier', Icons.shopping_basket_outlined),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CollapsibleChipList(items: distribution.foodItems),
                  ),
                  _buildSectionTitle(context, 'Instructions importantes', Icons.info_outline),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(distribution.instructions),
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomButtons(context, ref, userData?.dossierStatus, isRegistered, distribution),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(appBar: AppBar(), body: Center(child: Text("Erreur de chargement de la distribution: $error"))),
    );
  }

  // Le reste du fichier reste INCHANGÉ...
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 16, right: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(DistributionModel distribution) {
    if (distribution.imageUrl.startsWith('http')) {
      return Image.network(
        distribution.imageUrl,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        distribution.imageUrl,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildBottomButtons(BuildContext context, WidgetRef ref, String? dossierStatus, bool isRegistered, DistributionModel distribution) {
  if (dossierStatus != 'approved') {
    String message;
    Color color;
    switch (dossierStatus) {
      case 'not_submitted':
        message = 'Veuillez compléter et soumettre votre dossier pour participer.';
        color = Colors.blueGrey;
        break;
      case 'pending':
        message = 'Votre dossier est en attente de validation.';
        color = Colors.orange;
        break;
      case 'rejected':
        message = 'Votre dossier a été refusé. Veuillez le consulter.';
        color = Colors.red;
        break;
      default:
        message = 'Statut du dossier non valide pour l\'inscription.';
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      color: color,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  } else {
    final currentUserId = ref.read(firebaseAuthProvider).currentUser?.uid;
    final isVolunteer = distribution.volunteers.contains(currentUserId);
    final volunteerSlotsAvailable = distribution.volunteers.length < distribution.maxVolunteers;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isRegistered)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: ViewQrCodeButton(distribution: distribution),
            )
          else if (!isVolunteer)
            ElevatedButton(
              onPressed: () {
                showMaterialModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (context) => ConfirmationPopup(distributionId: distribution.id),
                );
              },
              child: const Text('Récupérer mon panier'),
            ),

          if ((isRegistered || !isVolunteer) && (isVolunteer || volunteerSlotsAvailable || !volunteerSlotsAvailable && !isVolunteer))
            const SizedBox(height: 8),

          if (isVolunteer)
            OutlinedButton.icon(
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Annuler (bénévole)'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmer l\'annulation'),
                    content: const Text('Êtes-vous sûr de vouloir annuler votre participation en tant que bénévole ?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Retour')),
                      FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirmer')),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await ref.read(distributionRepositoryProvider).cancelVolunteerRegistration(distribution.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Votre participation a été annulée.')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
                  }
                }
              },
            )
          else if (volunteerSlotsAvailable)
            OutlinedButton(
              onPressed: () {
                showMaterialModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (context) => VolunteerConfirmationPopup(distributionId: distribution.id),
                );
              },
              child: Text('Participer en tant que bénévole '),
            )
          else
            const OutlinedButton(
              onPressed: null,
              child: Text('Bénévolat complet'),
            ),
        ],
      ),
    );
  }
}
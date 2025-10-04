// lib/src/features/distributions/presentation/qr_code_popup.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:aic_woippy_app/src/features/distributions/application/distributions_provider.dart';

class QrCodePopup extends ConsumerWidget {
  final String qrCodeData;
  const QrCodePopup({super.key, required this.qrCodeData});

  Future<void> _showCancelConfirmationDialog(BuildContext context, WidgetRef ref, String distributionId) async {
    String? cancelReason;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'annulation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Êtes-vous sûr de vouloir annuler votre participation ?'),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => cancelReason = value,
              decoration: const InputDecoration(
                labelText: 'Raison (optionnel)',
                hintText: 'Ex: Emploi du temps, imprévu...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Retour'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ref.read(distributionRepositoryProvider).cancelRegistration(distributionId, reason: cancelReason);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre inscription a bien été annulée.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distributionId = qrCodeData.split('|')[0];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Présentez ce code à votre arrivée',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: QrImageView(
              data: qrCodeData,
              version: QrVersions.auto,
              size: 250.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ce QR Code est unique et lié à cette distribution.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),


          Column(

            children: [

              _buildWalletButton(context),
              const SizedBox(height: 12),


              ElevatedButton(
                onPressed: () => _showCancelConfirmationDialog(context, ref, distributionId),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  backgroundColor: Colors.grey[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text('Annuler'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWalletButton(BuildContext context) {
    final isIos = Platform.isIOS;
    final logoPath = isIos ? 'assets/images/apple_wallet_button.png' : 'assets/images/google_wallet_button.png';
    final walletName = isIos ? 'Apple Wallet' : 'Google Wallet';

    return ElevatedButton(
      onPressed: () {
        // TODO: Implémenter la logique de création et d'ajout du pass
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fonctionnalité Wallet non implémentée.')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Image.asset(logoPath, height: 24),
            ),
            Container(
              color: Colors.white24,
              width: 1,
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajouter à',
                    style: TextStyle(color: Colors.grey[300], fontSize: 10, height: 1),
                  ),
                  Text(
                    walletName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
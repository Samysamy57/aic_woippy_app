// lib/src/features/distributions/presentation/widgets/confirmation_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aic_woippy_app/src/features/distributions/application/distributions_provider.dart';
import 'package:aic_woippy_app/src/features/distributions/presentation/qr_code_popup.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ConfirmationPopup extends ConsumerStatefulWidget {
  final String distributionId;


  const ConfirmationPopup({
    super.key,
    required this.distributionId,
  });

  @override
  ConsumerState<ConfirmationPopup> createState() => _ConfirmationPopupState();
}

class _ConfirmationPopupState extends ConsumerState<ConfirmationPopup> {
  bool _isChecked = false;
  bool _isLoading = false;

  void _submit() async {
    setState(() { _isLoading = true; });
    try {
      // On appelle la logique de réservation
      await ref.read(distributionRepositoryProvider).registerForDistribution(widget.distributionId);

      // On génère les données pour le QR code (sera passé à la page suivante)
      final qrData = "${widget.distributionId}|${ref.read(firebaseAuthProvider).currentUser!.uid}";

      if (mounted) {
        // 1. Ferme la pop-up de confirmation
        Navigator.of(context).pop();
        // 2. Ouvre la pop-up du QR Code
        showMaterialModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => QrCodePopup(qrCodeData: qrData),
        );
      }
    } catch (e) {
      // S'il y a une erreur (ex: plus de paniers), on ferme le pop-up et on affiche un message
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
    // Pas besoin de setState isLoading à false car on navigue ailleurs
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Avant de confirmer...", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildWarningRow(Icons.shopping_bag_outlined, "Venez avec vos propres sacs, notamment un sac isotherme pour les produits frais."),
          _buildWarningRow(Icons.qr_code_2, "Présentez votre QR code personnel à l'entrée."),
          _buildWarningRow(Icons.access_time, "Respectez les horaires de distribution indiqués."),
          _buildWarningRow(Icons.warning_amber_rounded, "Toute absence non justifiée pourra être pénalisée."),
          const SizedBox(height: 24),
          Row(
            children: [
              Checkbox(
                value: _isChecked,
                onChanged: (value) => setState(() => _isChecked = value!),
              ),
              const Expanded(child: Text("J'ai lu et j'accepte les conditions de la distribution.")),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isChecked && !_isLoading ? _submit : null, // Bouton désactivé si pas coché ou en chargement
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirmer ma participation'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWarningRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

// Ajout pour que le provider d'auth soit accessible
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
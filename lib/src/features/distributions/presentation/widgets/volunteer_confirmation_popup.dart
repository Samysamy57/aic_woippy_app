// lib/src/features/distributions/presentation/widgets/volunteer_confirmation_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aic_woippy_app/src/features/distributions/application/distributions_provider.dart';

class VolunteerConfirmationPopup extends ConsumerStatefulWidget {
  final String distributionId;

  const VolunteerConfirmationPopup({
    super.key,
    required this.distributionId,
  });

  @override
  ConsumerState<VolunteerConfirmationPopup> createState() => _VolunteerConfirmationPopupState();
}

class _VolunteerConfirmationPopupState extends ConsumerState<VolunteerConfirmationPopup> {
  bool _isLoading = false;

  void _submit() async {
    setState(() { _isLoading = true; });
    try {
      // On appelle la nouvelle méthode du repository
      await ref.read(distributionRepositoryProvider).registerAsVolunteer(widget.distributionId);

      if (mounted) {
        Navigator.of(context).pop(); // Ferme le pop-up
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merci ! Votre participation a bien été enregistrée.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
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
          Text("Devenir bénévole", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInstructionRow(Icons.access_time_filled, "Arriver 30 minutes avant le début de la distribution."),
          _buildInstructionRow(Icons.shopping_basket, "Vous récupérerez votre propre panier en priorité."),
          _buildInstructionRow(Icons.sentiment_very_satisfied, "Aider à servir les autres étudiants avec le sourire."),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Je confirme ma participation'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
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
// lib/src/features/distributions/presentation/widgets/dossier_status_footer.dart
import 'package:flutter/material.dart';

class DossierStatusFooter extends StatelessWidget {
  final String status;
  final VoidCallback onTap;

  const DossierStatusFooter({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPending = status == 'pending';
    final color = isPending ? Colors.orange.shade700 : Colors.red.shade700;
    final text = isPending
        ? 'Votre dossier est en attente de validation.'
        : 'Votre dossier a été refusé.';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: color,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Text(
          '$text Cliquez ici pour voir les détails.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
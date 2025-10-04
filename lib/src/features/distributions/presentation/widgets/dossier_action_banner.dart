// lib/src/features/distributions/presentation/widgets/dossier_action_banner.dart
import 'package:flutter/material.dart';
import 'package:aic_woippy_app/src/features/profile/presentation/dossier_screen.dart';

class DossierActionBanner extends StatelessWidget {
  final String status;
  final String? rejectionReason;

  const DossierActionBanner({
    super.key,
    required this.status,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRejected = status == 'rejected';
    final color = isRejected ? Colors.red[800]! : Colors.orange[800]!;

    String title;
    String subtitle;

    if (isRejected) {
      title = 'Dossier Refusé';
      subtitle = rejectionReason ?? 'Veuillez consulter votre dossier pour plus de détails.';
    } else { // pending or not_submitted
      title = 'Information';
      subtitle = 'Votre dossier nécessite une action pour accéder aux distributions.';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DossierScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        color: color.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: color.withOpacity(0.9), fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
// lib/src/features/distributions/presentation/widgets/upcoming_registration_banner.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aic_woippy_app/src/features/distributions/application/distributions_provider.dart';
import 'package:aic_woippy_app/src/features/distributions/models/distribution_model.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../qr_code_popup.dart';
import 'confirmation_popup.dart';

class UpcomingRegistrationBanner extends ConsumerStatefulWidget {
  const UpcomingRegistrationBanner({super.key});

  @override
  ConsumerState<UpcomingRegistrationBanner> createState() => _UpcomingRegistrationBannerState();
}

class _UpcomingRegistrationBannerState extends ConsumerState<UpcomingRegistrationBanner> {
  Timer? _timer;
  String _countdownText = '';
  // On garde en mémoire l'ID de la distribution affichée pour éviter de redémarrer le timer inutilement
  String? _currentDistributionId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime distributionDate) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = distributionDate.difference(now);
      if (difference.isNegative) {
        timer.cancel();
        if (mounted) setState(() => _countdownText = 'Distribution en cours');
      } else {
        if (mounted) setState(() => _countdownText = _formatDuration(difference));
      }
    });
  }

  String _formatDuration(Duration d) {
    if (d.inDays >= 1) {
      return "Dans ${d.inDays} jour${d.inDays > 1 ? 's' : ''}";
    } else if (d.inHours >= 2) {
      return "Dans ${d.inHours} heures";
    } else if (d.inMinutes >= 60) {
      return "Dans ${d.inHours}h et ${d.inMinutes.remainder(60)}m";
    } else {
      return "Dans ${d.inMinutes}m et ${d.inSeconds.remainder(60)}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrations = ref.watch(userRegistrationsProvider).value ?? [];
    final normalDistributions = ref.watch(normalDistributionsProvider).value ?? [];
    final quickDistributions = ref.watch(quickDistributionsProvider).value ?? [];
    final allDistributions = [...normalDistributions, ...quickDistributions];

    if (registrations.isEmpty || allDistributions.isEmpty) {
      return const SizedBox.shrink();
    }

    // --- DÉBUT DE LA NOUVELLE LOGIQUE DE TRI ---

    // 1. Créer une liste d'objets qui associent une inscription à sa distribution
    final List<Map<String, dynamic>> registeredDistributions = [];
    for (var reg in registrations) {
      final distributionId = (reg.data() as Map)['distributionId'];
      // On cherche la distribution correspondante dans notre liste complète
      final associatedDistribution = allDistributions.firstWhere(
            (dist) => dist.id == distributionId,
        orElse: () => allDistributions.first, // Fallback de sécurité
      );
      registeredDistributions.add({
        'registration': reg,
        'distribution': associatedDistribution,
      });
    }

    // 2. Trier cette nouvelle liste par la date de la distribution, du plus proche au plus lointain
    registeredDistributions.sort((a, b) =>
        (a['distribution'] as DistributionModel).date.compareTo((b['distribution'] as DistributionModel).date)
    );

    // 3. S'il n'y a aucune distribution correspondante, on ne fait rien
    if (registeredDistributions.isEmpty) {
      return const SizedBox.shrink();
    }

    // 4. La prochaine distribution est maintenant le premier élément de notre liste triée
    final nextUpcoming = registeredDistributions.first;
    final DistributionModel nextDistribution = nextUpcoming['distribution'];

    // --- FIN DE LA NOUVELLE LOGIQUE DE TRI ---

    // On (re)démarre le timer uniquement si la distribution a changé
    if (_currentDistributionId != nextDistribution.id) {
      _currentDistributionId = nextDistribution.id;
      _startTimer(nextDistribution.date.toDate());
    }

    return GestureDetector(
      onTap: () {
        final qrData = "${nextDistribution.id}|${ref.read(firebaseAuthProvider).currentUser!.uid}";
        showMaterialModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => QrCodePopup(qrCodeData: qrData),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prochaine récupération :',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    DateFormat('EEEE d MMMM', 'fr_FR').format(nextDistribution.date.toDate()),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Text(
              _countdownText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
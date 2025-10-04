// lib/src/features/distributions/presentation/widgets/view_qr_code_button.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:aic_woippy_app/src/features/distributions/models/distribution_model.dart';
import '../qr_code_popup.dart';
import 'confirmation_popup.dart';

class ViewQrCodeButton extends ConsumerStatefulWidget {
  final DistributionModel distribution;
  const ViewQrCodeButton({super.key, required this.distribution});

  @override
  ConsumerState<ViewQrCodeButton> createState() => _ViewQrCodeButtonState();
}

class _ViewQrCodeButtonState extends ConsumerState<ViewQrCodeButton> {
  Timer? _timer;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    _startTimer(widget.distribution.date.toDate());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime distributionDate) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final difference = distributionDate.difference(DateTime.now());
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
    return GestureDetector(
      onTap: () {
        final qrData = "${widget.distribution.id}|${ref.read(firebaseAuthProvider).currentUser!.uid}";
        showMaterialModalBottomSheet(
          context: context,
          // --- CORRECTION APPLIQUÉE ICI ---
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
                    'Vous êtes inscrit :',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    DateFormat('EEEE d MMMM', 'fr_FR').format(widget.distribution.date.toDate()),
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
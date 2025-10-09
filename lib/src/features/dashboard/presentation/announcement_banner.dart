// lib/src/features/dashboard/presentation/announcement_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aic_woippy_app/src/features/dashboard/data/dashboard_repository.dart';

// Provider pour le repository
final dashboardRepoProvider = Provider((ref) => DashboardRepository());

// Provider qui fetch l'annonce
final latestAnnouncementProvider = FutureProvider<DocumentSnapshot?>((ref) {
  return ref.watch(dashboardRepoProvider).getLatestGlobalAnnouncement();
});

class AnnouncementBanner extends ConsumerStatefulWidget {
  const AnnouncementBanner({super.key});

  @override
  ConsumerState<AnnouncementBanner> createState() => _AnnouncementBannerState();
}

class _AnnouncementBannerState extends ConsumerState<AnnouncementBanner> {
  bool _isExpanded = false;
  bool _isRead = false;
  String? _lastReadAnnouncementId;

  @override
  void initState() {
    super.initState();
    _loadReadStatus();
  }

  // Charge l'ID de la dernière annonce lue depuis la mémoire du téléphone
  Future<void> _loadReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastReadAnnouncementId = prefs.getString('lastReadAnnouncementId');
    });
  }

  // Sauvegarde l'ID de l'annonce actuelle comme "lue"
  Future<void> _markAsRead(String announcementId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastReadAnnouncementId', announcementId);
    setState(() {
      _isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final announcementAsyncValue = ref.watch(latestAnnouncementProvider);
    final colors = Theme.of(context);

    return announcementAsyncValue.when(
      data: (snapshot) {
        if (snapshot == null || !snapshot.exists) {
          return const SizedBox.shrink(); // Ne rien afficher si pas d'annonce
        }
        final data = snapshot.data() as Map<String, dynamic>;
        final currentAnnouncementId = snapshot.id;

        // Détermine si la notif doit s'afficher
        final bool showNotificationBadge = _lastReadAnnouncementId != currentAnnouncementId && !_isRead;

        return GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
              // Si on ouvre le message et qu'il n'était pas lu, on le marque comme lu
              if (showNotificationBadge) {
                _markAsRead(currentAnnouncementId);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.campaign_rounded, color: colors.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'Information',
                        style: TextStyle(fontWeight: FontWeight.bold, color: colors.primaryColor),
                      ),
                      AnimatedCrossFade(
                        firstChild: Text(
                          data['message'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text(data['message'] ?? ''),
                        crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (showNotificationBadge)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[700],
                  )
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 88, // Hauteur approximative du bandeau pour éviter les sauts d'affichage
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}
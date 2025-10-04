// lib/src/features/dashboard/data/dashboard_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupère la dernière annonce globale en triant par date et en prenant la première
  Future<DocumentSnapshot?> getLatestGlobalAnnouncement() async {
    final querySnapshot = await _firestore
        .collection('global_announcements')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    return null;
  }
}
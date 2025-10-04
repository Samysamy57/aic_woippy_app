// lib/src/features/distributions/data/distributions_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aic_woippy_app/src/features/distributions/models/distribution_model.dart';

class DistributionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupère toutes les distributions à venir, triées par date
  Stream<List<DistributionModel>> _getDistributionsStream({String? type}) {
    Query query = _firestore
        .collection('distributions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('date');

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DistributionModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
    });
  }

  // Fonctions publiques pour chaque type
  Stream<List<DistributionModel>> getUpcomingNormalDistributions() => _getDistributionsStream(type: 'normal');
  Stream<List<DistributionModel>> getUpcomingQuickDistributions() => _getDistributionsStream(type: 'rapide');

  Future<void> registerForDistribution(String distributionId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Utilisateur non connecté.");
    }

    final registrationRef = _firestore.collection('registrations').doc('${distributionId}_${user.uid}');

    // On utilise une transaction pour s'assurer que tout se passe bien
    await _firestore.runTransaction((transaction) async {
      final distributionRef = _firestore.collection('distributions').doc(distributionId);
      final distributionDoc = await transaction.get(distributionRef);

      if (!distributionDoc.exists) {
        throw Exception("Cette distribution n'existe plus.");
      }

      final availableBaskets = distributionDoc.data()!['availableBaskets'] as int;

      if (availableBaskets <= 0) {
        throw Exception("Désolé, il n'y a plus de paniers disponibles.");
      }

      // Décrémenter le nombre de paniers
      transaction.update(distributionRef, {
        'availableBaskets': FieldValue.increment(-1),
      });

      // Créer l'inscription pour l'utilisateur
      transaction.set(registrationRef, {
        'userId': user.uid,
        'distributionId': distributionId,
        'registeredAt': FieldValue.serverTimestamp(),
        'status': 'registered', // 'registered', 'retrieved', 'cancelled'
        'qrCodeData': '${distributionId}|${user.uid}', // Données uniques pour le QR Code
      });
    });
  }
  Stream<List<DocumentSnapshot>> getUserRegistrations() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('registrations')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'registered')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
  // On ajoute un paramètre optionnel "reason"
  Future<void> cancelRegistration(String distributionId, {String? reason}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Utilisateur non connecté.");
    }

    final registrationRef = _firestore.collection('registrations').doc('${distributionId}_${user.uid}');

    await _firestore.runTransaction((transaction) async {
      final distributionRef = _firestore.collection('distributions').doc(distributionId);
      final registrationDoc = await transaction.get(registrationRef);

      if (!registrationDoc.exists) {
        return;
      }

      transaction.update(distributionRef, {
        'availableBaskets': FieldValue.increment(1),
      });

      // Au lieu de supprimer, on met à jour le statut et on ajoute la raison
      // Cela permet de garder un historique pour les admins
      transaction.update(registrationRef, {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelReason': reason ?? 'Non spécifié',
      });
    });
  }

  Future<void> registerAsVolunteer(String distributionId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Utilisateur non connecté.");
    }

    final distributionRef = _firestore.collection('distributions').doc(distributionId);

    // On utilise FieldValue.arrayUnion pour ajouter l'UID de l'utilisateur au tableau
    // des bénévoles. C'est une opération atomique et idempotente (si l'UID est
    // déjà dans le tableau, il ne sera pas ajouté une deuxième fois).
    await distributionRef.update({
      'volunteers': FieldValue.arrayUnion([user.uid])
    });
  }

  Future<void> cancelVolunteerRegistration(String distributionId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Utilisateur non connecté.");
    }

    final distributionRef = _firestore.collection('distributions').doc(distributionId);

    // On utilise FieldValue.arrayRemove pour retirer l'UID de l'utilisateur du tableau.
    // C'est une opération atomique et sécurisée.
    await distributionRef.update({
      'volunteers': FieldValue.arrayRemove([user.uid])
    });
  }

  Stream<DistributionModel> getDistributionStream(String distributionId) {
    return _firestore
        .collection('distributions')
        .doc(distributionId)
        .snapshots() // .snapshots() écoute les changements en temps réel
        .map((doc) => DistributionModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>));
  }


}
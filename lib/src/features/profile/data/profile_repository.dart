// lib/src/features/profile/data/profile_repository.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:aic_woippy_app/src/core/models/user_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<UserModel?> getUserData() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
      }
      return null;
    });
  }

  Future<String> uploadDocument(File file, String documentName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilisateur non authentifié.");
    try {
      final filePath = 'user_documents/${user.uid}/$documentName';
      final ref = _storage.ref().child(filePath);
      final snapshot = await ref.putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Erreur lors du téléversement du fichier : $documentName");
    }
  }

  Future<void> updateDossierData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilisateur non authentifié.");

    final userDocRef = _firestore.collection('users').doc(user.uid);
    // On utilise `set` avec `merge: true` au lieu de `update`.
    // C'est plus sûr car ça crée le champ s'il n'existe pas, sans causer d'erreur.
    await userDocRef.set(data, SetOptions(merge: true));
  }
}
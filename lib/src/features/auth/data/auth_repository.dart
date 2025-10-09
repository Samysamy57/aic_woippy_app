// lib/src/features/auth/data/auth_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aic_woippy_app/src/core/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception("Erreur, aucun utilisateur créé.");

      final user = UserModel(
        uid: firebaseUser.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        createdAt: Timestamp.now(),
      );

      final userData = {
        'uid': user.uid,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'phone': user.phone,
        'role': user.role,
        'dossierStatus': user.dossierStatus,
        'paymentStatus': user.paymentStatus,
        'createdAt': user.createdAt,
        'phoneVerified': false,
      };

      await _firestore.collection('users').doc(firebaseUser.uid).set(userData);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') throw Exception('Cette adresse email est déjà utilisée.');
      if (e.code == 'weak-password') throw Exception('Le mot de passe est trop faible.');
      throw Exception('Une erreur est survenue lors de l\'inscription.');
    } catch (e) {
      throw Exception('Une erreur inconnue est survenue.');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Email ou mot de passe incorrect.');
      }
      throw Exception('Une erreur est survenue lors de la connexion.');
    } catch (e) {
      throw Exception('Une erreur inconnue est survenue.');
    }
  }

  // --- NOUVELLE MÉTHODE AJOUTÉE ---
  Future<String?> findUserByPhone(String phoneNumber) async {
    final query = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).limit(1).get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data()['email'] as String?;
    }
    return null;
  }
  // --- FIN DE L'AJOUT ---

  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<void> verifySmsCodeAndLinkAccount({required String verificationId, required String smsCode}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté pour lier le téléphone.");

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await user.linkWithCredential(credential);
    await _firestore.collection('users').doc(user.uid).update({'phoneVerified': true});
  }

  Future<void> linkCredential(PhoneAuthCredential credential) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté.");
    await user.linkWithCredential(credential);
    await _firestore.collection('users').doc(user.uid).update({'phoneVerified': true});
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
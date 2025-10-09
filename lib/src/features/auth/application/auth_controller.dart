// lib/src/features/auth/application/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:aic_woippy_app/src/features/auth/data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(authRepository: ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(false);

  // --- LES MÉTHODES signUp et signIn restent identiques ---
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = true;
    try {
      await _authRepository.signUp(
        firstName: firstName, lastName: lastName, email: email, phone: phone, password: password,
      );
    } finally {
      state = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = true;
    try {
      await _authRepository.signIn(email: email, password: password);
    } finally {
      state = false;
    }
  }

  // --- LOGIQUE DE MOT DE PASSE OUBLIÉ MISE À JOUR ---

  Future<void> requestPasswordResetCode({required String email}) async {
    state = true;
    try {
      final callable = _functions.httpsCallable('requestPasswordResetCode');
      await callable.call({'email': email});
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? "Une erreur est survenue.");
    } finally {
      state = false;
    }
  }

  // NOUVELLE MÉTHODE
  Future<void> verifyResetCode({required String email, required String code}) async {
    state = true;
    try {
      final callable = _functions.httpsCallable('verifyResetCode');
      await callable.call({'email': email, 'code': code});
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? "La vérification a échoué.");
    } finally {
      state = false;
    }
  }

  // NOUVELLE MÉTHODE
  Future<void> resetPassword({required String email, required String newPassword}) async {
    state = true;
    try {
      final callable = _functions.httpsCallable('resetPassword');
      await callable.call({'email': email, 'newPassword': newPassword});
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? "La réinitialisation a échoué.");
    } finally {
      state = false;
    }
  }

  // --- LES MÉTHODES de vérification SMS restent identiques ---
  Future<void> sendPhoneVerificationCode({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _authRepository.sendPhoneVerificationCode(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<void> verifySmsCodeAndLinkAccount({required String verificationId, required String smsCode}) async {
    state = true;
    try {
      await _authRepository.verifySmsCodeAndLinkAccount(verificationId: verificationId, smsCode: smsCode);
    } finally {
      state = false;
    }
  }

  Future<void> linkCredential(PhoneAuthCredential credential) async {
    state = true;
    try {
      await _authRepository.linkCredential(credential);
    } finally {
      state = false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
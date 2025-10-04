// lib/src/features/auth/application/auth_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aic_woippy_app/src/features/auth/data/auth_repository.dart';

// Provider pour notre AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Provider pour l'état de l'authentification
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Provider pour notre contrôleur
final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(authRepository: ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(false);

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
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
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

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
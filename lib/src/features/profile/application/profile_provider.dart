// lib/src/features/profile/application/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aic_woippy_app/src/core/models/user_model.dart';
import 'package:aic_woippy_app/src/features/profile/data/profile_repository.dart';

// Provider pour le repository
final profileRepositoryProvider = Provider((ref) => ProfileRepository());

// Provider qui expose le Stream des données de l'utilisateur
final userDataProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(profileRepositoryProvider).getUserData();
});
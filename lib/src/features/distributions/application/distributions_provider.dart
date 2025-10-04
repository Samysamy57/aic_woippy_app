// lib/src/features/distributions/application/distributions_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aic_woippy_app/src/features/distributions/data/distributions_repository.dart';
import 'package:aic_woippy_app/src/features/distributions/models/distribution_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final distributionRepositoryProvider = Provider((ref) => DistributionRepository());

final normalDistributionsProvider = StreamProvider<List<DistributionModel>>((ref) {
  return ref.watch(distributionRepositoryProvider).getUpcomingNormalDistributions();
});

final quickDistributionsProvider = StreamProvider<List<DistributionModel>>((ref) {
  return ref.watch(distributionRepositoryProvider).getUpcomingQuickDistributions();
});

final userRegistrationsProvider = StreamProvider<List<DocumentSnapshot>>((ref) {
  return ref.watch(distributionRepositoryProvider).getUserRegistrations();
});

final distributionDetailProvider = StreamProvider.family<DistributionModel, String>((ref, distributionId) {
  final repository = ref.watch(distributionRepositoryProvider);
  return repository.getDistributionStream(distributionId);
});
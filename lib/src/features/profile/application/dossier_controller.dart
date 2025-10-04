// lib/src/features/profile/application/dossier_controller.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aic_woippy_app/src/features/profile/data/profile_repository.dart';
import 'package:aic_woippy_app/src/features/profile/application/profile_provider.dart';

// État pour gérer plusieurs chargements simultanés (ex: un par fichier)
class DossierState {
  final bool isSaving;
  final Set<String> uploadingFiles; // Set des noms de fichiers en cours d'upload

  DossierState({this.isSaving = false, this.uploadingFiles = const {}});

  DossierState copyWith({bool? isSaving, Set<String>? uploadingFiles}) {
    return DossierState(
      isSaving: isSaving ?? this.isSaving,
      uploadingFiles: uploadingFiles ?? this.uploadingFiles,
    );
  }
}

final dossierControllerProvider = StateNotifierProvider<DossierController, DossierState>((ref) {
  return DossierController(
    ref: ref,
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

class DossierController extends StateNotifier<DossierState> {
  final ProfileRepository _profileRepository;
  final Ref _ref;

  // *** CORRECTION DU CONSTRUCTEUR ICI ***
  // On assigne explicitement les paramètres aux champs privés de la classe.
  DossierController({
    required ProfileRepository profileRepository,
    required Ref ref,
  })  : _profileRepository = profileRepository,
        _ref = ref,
        super(DossierState());

  // Sauvegarde les champs de texte
  Future<void> saveDossierData(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true);
    try {
      await _profileRepository.updateDossierData(data);
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  // Gère le téléversement d'un fichier et met à jour le champ correspondant
  Future<void> uploadFileAndUpdateField(File file, String fieldName, String documentName) async {
    state = state.copyWith(uploadingFiles: {...state.uploadingFiles, documentName});
    try {
      final url = await _profileRepository.uploadDocument(file, documentName);
      await _profileRepository.updateDossierData({fieldName: url});
      // Rafraîchir les données utilisateur pour que l'UI se mette à jour
      _ref.refresh(userDataProvider);
    } finally {
      state = state.copyWith(uploadingFiles: {...state.uploadingFiles..remove(documentName)});
    }
  }

  // Soumission finale du dossier pour validation
  Future<void> submitDossierForReview() async {
    state = state.copyWith(isSaving: true);
    try {
      await _profileRepository.updateDossierData({'dossierStatus': 'pending'});
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
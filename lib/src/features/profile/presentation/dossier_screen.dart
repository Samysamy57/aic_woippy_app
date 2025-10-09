// lib/src/features/profile/presentation/dossier_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aic_woippy_app/src/core/models/user_model.dart';
import 'package:aic_woippy_app/src/features/profile/application/dossier_controller.dart';
import 'package:aic_woippy_app/src/features/profile/application/profile_provider.dart';
import 'package:aic_woippy_app/src/features/dashboard/presentation/home_screen.dart';
import 'package:aic_woippy_app/src/shared/widgets/background_container.dart';


class DossierScreen extends ConsumerWidget {
  const DossierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDataProvider);
    final canPop = userAsync.value?.dossierStatus != 'not_submitted';


    return BackgroundContainer(
      imagePath: 'assets/images/background_main.png', // <-- AJOUTEZ CETTE LIGNE
      child: Scaffold(

        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Mon Dossier Étudiant'),
          automaticallyImplyLeading: canPop,
        ),
        body: userAsync.when(
          data: (user) {
            if (user == null) return const Center(child: Text('Utilisateur introuvable.'));
            return DossierForm(user: user);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Erreur de chargement: $e')),
        ),
      ),
    );
  }
}

class DossierForm extends ConsumerStatefulWidget {
  final UserModel user;
  const DossierForm({required this.user, super.key});

  @override
  ConsumerState<DossierForm> createState() => _DossierFormState();
}

class _DossierFormState extends ConsumerState<DossierForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _addressController;
  late final TextEditingController _schoolController;
  late final TextEditingController _studyLevelController;
  late final TextEditingController _crousNameController;
  String? _isCrousScholarship;
  String? _accommodationType;
  bool? _hasDisability;

  List<String> _rejectedFields = [];

  InputDecoration _rejectedInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.red),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _schoolController = TextEditingController(text: widget.user.school ?? '');
    _studyLevelController = TextEditingController(text: widget.user.studyLevel ?? '');
    _crousNameController = TextEditingController(text: widget.user.crousName ?? '');
    _isCrousScholarship = widget.user.isCrousScholarship;
    _accommodationType = widget.user.accommodationType;
    _hasDisability = widget.user.hasDisability;

    if (widget.user.dossierStatus == 'rejected' && widget.user.rejectionData?['fields'] != null) {
      final fieldsData = widget.user.rejectionData!['fields'];
      if (fieldsData is List) {
        _rejectedFields = List<String>.from(fieldsData.map((e) => e.toString()));
      } else if (fieldsData is String) {
        _rejectedFields = [fieldsData];
      }
    }
  }


  @override
  void dispose() {
    _addressController.dispose();
    _schoolController.dispose();
    _studyLevelController.dispose();
    _crousNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(ImageSource source, String fieldName, String documentName) async {
    final picker = ImagePicker();
    File? file;

    if (source == ImageSource.gallery) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        file = File(pickedFile.path);
      }
    } else if (source == ImageSource.camera) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (pickedFile != null) {
        file = File(pickedFile.path);
      }
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        file = File(result.files.single.path!);
      }
    }

    if (file != null) {
      ref.read(dossierControllerProvider.notifier).uploadFileAndUpdateField(file, fieldName, documentName);
    }
  }

  void _showFilePicker(BuildContext context, String fieldName, String documentName) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie de photos'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickFile(ImageSource.gallery, fieldName, documentName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickFile(ImageSource.camera, fieldName, documentName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Choisir un fichier (PDF, image...)'),
              onTap: () {
                Navigator.of(ctx).pop();
                // On passe une source bidon pour déclencher le cas 'else'
                _pickFile(ImageSource.gallery, fieldName, documentName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionBanner() {
    if (widget.user.dossierStatus != 'rejected' || widget.user.rejectionData?['reason'] == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Dossier Refusé", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text(widget.user.rejectionData!['reason'], style: const TextStyle(color: Colors.red)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFileUploadField(String title, String fieldName, String documentName, String? url) {
    final dossierState = ref.watch(dossierControllerProvider);
    final isUploading = dossierState.uploadingFiles.contains(documentName);
    final isRejected = _rejectedFields.contains(fieldName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isRejected ? Colors.red : null)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          style: isRejected ? OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)) : null,
          onPressed: isUploading ? null : () => _showFilePicker(context, fieldName, documentName),
          icon: isUploading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(url != null ? Icons.check_circle : Icons.upload_file, color: url != null ? Colors.green : (isRejected ? Colors.red : null)),
          label: Text(isUploading ? 'Téléversement...' : (url != null ? 'Fichier envoyé' : 'Choisir un fichier...')),
        ),
      ],
    );
  }

  Future<void> _saveAndExit() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final dataToSave = {
      'address': _addressController.text.trim(),
      'school': _schoolController.text.trim(),
      'studyLevel': _studyLevelController.text.trim(),
      'isCrousScholarship': _isCrousScholarship,
      'accommodationType': _accommodationType,
      'hasDisability': _hasDisability,
      'crousName': _isCrousScholarship == 'oui' ? _crousNameController.text.trim() : null,
    };

    await ref.read(dossierControllerProvider.notifier).saveDossierData(dataToSave);

    messenger.showSnackBar(const SnackBar(content: Text('Progression sauvegardée.')));
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
    );
  }

  Future<void> _submitForReview() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires.'), backgroundColor: Colors.red));
      return;
    }
    final messenger = ScaffoldMessenger.of(context);

    final dataToSave = {
      'dossierStatus': 'pending',
      'rejectionData': FieldValue.delete(),
      'address': _addressController.text.trim(),
      'school': _schoolController.text.trim(),
      'studyLevel': _studyLevelController.text.trim(),
      'isCrousScholarship': _isCrousScholarship,
      'accommodationType': _accommodationType,
      'hasDisability': _hasDisability,
      'crousName': _isCrousScholarship == 'oui' ? _crousNameController.text.trim() : null,
    };
    await ref.read(dossierControllerProvider.notifier).saveDossierData(dataToSave);

    messenger.showSnackBar(const SnackBar(
      content: Text('Dossier soumis pour validation !'),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dossierState = ref.watch(dossierControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRejectionBanner(),
          Text("Complétez votre dossier", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextFormField(controller: _schoolController, decoration: _rejectedFields.contains('school') ? _rejectedInputDecoration('École / Université *') : const InputDecoration(labelText: 'École / Université *'), validator: (v) => v!.isEmpty ? 'Champ requis' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _studyLevelController, decoration: _rejectedFields.contains('studyLevel') ? _rejectedInputDecoration('Niveau d\'étude *') : const InputDecoration(labelText: 'Niveau d\'étude (ex: Licence 2) *'), validator: (v) => v!.isEmpty ? 'Champ requis' : null),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _accommodationType,
            decoration: _rejectedFields.contains('accommodationType') ? _rejectedInputDecoration('Type de logement *') : const InputDecoration(labelText: 'Type de logement *'),
            items: const [
              DropdownMenuItem(value: 'crous', child: Text('Logement CROUS')),
              DropdownMenuItem(value: 'personnel', child: Text('Logement personnel')),
              DropdownMenuItem(value: 'famille', child: Text('Chez la famille / des proches')),
            ],
            onChanged: (value) => setState(() => _accommodationType = value),
            validator: (value) => value == null ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _isCrousScholarship,
            decoration: _rejectedFields.contains('isCrousScholarship') ? _rejectedInputDecoration('Boursier CROUS ? *') : const InputDecoration(labelText: 'Boursier CROUS ? *'),
            items: const [
              DropdownMenuItem(value: 'oui', child: Text('Oui')),
              DropdownMenuItem(value: 'non', child: Text('Non')),
              DropdownMenuItem(value: 'en_attente', child: Text('En attente de réponse')),
            ],
            onChanged: (value) => setState(() => _isCrousScholarship = value),
            validator: (value) => value == null ? 'Champ requis' : null,
          ),
          if (_isCrousScholarship == 'oui') ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _crousNameController.text.isNotEmpty ? _crousNameController.text : null,
              decoration: _rejectedFields.contains('crousName') ? _rejectedInputDecoration('Nom du CROUS *') : const InputDecoration(labelText: 'Nom du CROUS *'),
              items: const [
                DropdownMenuItem(value: 'Saulcy', child: Text('Saulcy')),
                DropdownMenuItem(value: 'Technopole', child: Text('Technopôle')),
                DropdownMenuItem(value: 'Autre', child: Text('Autre')),
              ],
              onChanged: (value) => setState(() => _crousNameController.text = value!),
              validator: (value) => value == null ? 'Champ requis' : null,
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(controller: _addressController, decoration: _rejectedFields.contains('address') ? _rejectedInputDecoration('Adresse complète *') : const InputDecoration(labelText: 'Adresse complète *'), maxLines: 2, validator: (v) => v!.isEmpty ? 'Champ requis' : null),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Situation de handicap'),
            value: _hasDisability ?? false,
            onChanged: (value) => setState(() => _hasDisability = value),
            secondary: const Icon(Icons.accessible),
          ),
          if (_hasDisability == true) ...[
            const SizedBox(height: 8),
            _buildFileUploadField('Justificatif de handicap', 'disabilityProofUrl', 'justificatif_handicap.jpg', widget.user.disabilityProofUrl),
          ],
          const SizedBox(height: 24),
          _buildFileUploadField('Carte Étudiant *', 'studentIdCardUrl', 'carte_etudiant.jpg', widget.user.studentIdCardUrl),
          const SizedBox(height: 16),
          _buildFileUploadField('Certificat de Scolarité *', 'schoolCertificateUrl', 'certificat_scolarite.jpg', widget.user.schoolCertificateUrl),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: dossierState.isSaving ? null : _submitForReview,
            child: dossierState.isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Soumettre à nouveau'),
          ),
          TextButton(
            onPressed: dossierState.isSaving ? null : _saveAndExit,
            child: const Text('Sauvegarder et continuer plus tard'),
          ),
        ],
      ),
    );
  }
}
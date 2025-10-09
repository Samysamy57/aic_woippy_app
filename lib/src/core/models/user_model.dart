// lib/src/core/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool phoneVerified; // <-- NOUVELLE LIGNE
  final String role;
  final String dossierStatus;
  final String paymentStatus;
  final Timestamp createdAt;

  final String? studyLevel;
  final String? isCrousScholarship;
  final String? crousName;
  final String? accommodationType;
  final String? schoolCertificateUrl;
  final bool? hasDisability;
  final String? disabilityProofUrl;
  final String? address;
  final String? school;
  final String? studentIdCardUrl;

  final Map<String, dynamic>? rejectionData; // Ex: { "reason": "Document illisible", "fields": ["studentIdCardUrl"] }

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.phoneVerified = false,
    this.role = 'student',
    this.dossierStatus = 'not_submitted',
    this.paymentStatus = 'unpaid',
    required this.createdAt,
    this.address,
    this.school,
    this.studentIdCardUrl,
    this.rejectionData,
    this.studyLevel,
    this.isCrousScholarship,
    this.crousName,
    this.accommodationType,
    this.schoolCertificateUrl,
    this.hasDisability,
    this.disabilityProofUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: data['uid'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      phoneVerified: data['phoneVerified'] ?? false,
      role: data['role'] ?? 'student',
      dossierStatus: data['dossierStatus'] ?? 'not_submitted',
      paymentStatus: data['paymentStatus'] ?? 'unpaid',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      address: data['address'],
      school: data['school'],
      studentIdCardUrl: data['studentIdCardUrl'],
      rejectionData: data['rejectionData'],
      studyLevel: data['studyLevel'],
      isCrousScholarship: data['isCrousScholarship'],
      crousName: data['crousName'],
      accommodationType: data['accommodationType'],
      schoolCertificateUrl: data['schoolCertificateUrl'],
      hasDisability: data['hasDisability'],
      disabilityProofUrl: data['disabilityProofUrl'],
    );
  }
}
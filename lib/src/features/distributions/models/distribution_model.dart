import 'package:cloud_firestore/cloud_firestore.dart';

class DistributionModel {
  final String id;
  final String title;
  final Timestamp date;
  final String location;
  final String instructions;
  final List<String> foodItems;
  final int availableBaskets;
  final String imageUrl;
  final String type; // 'normal', 'rapide', etc.
  final List<String> volunteers;
  final int maxVolunteers;

  DistributionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.instructions,
    required this.foodItems,
    required this.availableBaskets,
    required this.imageUrl,
    required this.type,
    required this.volunteers,
    required this.maxVolunteers,
  });

  factory DistributionModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Sécurisation des listes
    final List<String> foodItems =
    List<String>.from(data['foodItems'] ?? []);

    final List<String> volunteers =
    List<String>.from(data['volunteers'] ?? []);

    return DistributionModel(
      id: doc.id,
      title: data['title'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      location: data['location'] ?? 'Lieu non spécifié',
      instructions: data['instructions'] ?? 'Aucune instruction.',
      foodItems: foodItems,
      availableBaskets: data['availableBaskets'] ?? 0,
      imageUrl: data['imageUrl'] ?? 'assets/images/default_distribution.jpg',
      type: data['type'] ?? 'normal',
      volunteers: volunteers,
        maxVolunteers: data['maxVolunteers'] ?? 5
    );
  }
}

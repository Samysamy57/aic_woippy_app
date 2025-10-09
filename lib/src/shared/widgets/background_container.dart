// lib/src/shared/widgets/background_container.dart
import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  // NOUVEAU PARAMÈTRE REQUIS : le chemin de l'image à afficher
  final String imagePath;

  const BackgroundContainer({
    super.key,
    required this.child,
    // On l'ajoute au constructeur
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          // ON UTILISE LE PARAMÈTRE ICI au lieu d'un chemin fixe
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
      ),
      child: child,
    );
  }
}
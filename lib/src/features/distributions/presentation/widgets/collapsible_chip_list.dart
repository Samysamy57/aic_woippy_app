// lib/src/features/distributions/presentation/widgets/collapsible_chip_list.dart
import 'package:flutter/material.dart';
import 'dart:math' as math; // Importation nécessaire pour la rotation

class CollapsibleChipList extends StatefulWidget {
  final List<String> items;
  final int maxVisible;

  const CollapsibleChipList({
    super.key,
    required this.items,
    this.maxVisible = 5, // On réduit un peu pour que le bouton soit plus visible
  });

  @override
  State<CollapsibleChipList> createState() => _CollapsibleChipListState();
}

class _CollapsibleChipListState extends State<CollapsibleChipList> {
  // Variable d'état pour savoir si la liste est dépliée
  bool _isExpanded = false;

  Widget _buildChip(BuildContext context, String label) {
    final primaryColor = Theme.of(context).primaryColor;
    return Chip(
      label: Text(label, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      side: BorderSide(color: primaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // On détermine quels items afficher en fonction de l'état
    final bool canCollapse = widget.items.length > widget.maxVisible;
    final displayedItems = _isExpanded ? widget.items : widget.items.sublist(0, canCollapse ? widget.maxVisible : widget.items.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Le conteneur des chips s'animera en taille quand le contenu change
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: displayedItems.map((item) => _buildChip(context, item)).toList(),
          ),
        ),
        // On affiche le bouton "Voir plus/moins" uniquement si la liste est plus grande que la limite
        if (canCollapse)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0, // 0.5 = 180 degrés
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.expand_more),
            ),
            label: Text(_isExpanded ? "Voir moins" : "Voir les ${widget.items.length - widget.maxVisible} autres"),
          ),
      ],
    );
  }
}
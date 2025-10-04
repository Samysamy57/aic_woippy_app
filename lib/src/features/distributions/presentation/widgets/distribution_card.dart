// lib/src/features/distributions/presentation/widgets/distribution_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:aic_woippy_app/src/features/distributions/models/distribution_model.dart';
import '../distribution_detail_screen.dart';

class DistributionCard extends StatefulWidget {
  final DistributionModel distribution;
  const DistributionCard({super.key, required this.distribution});

  @override
  State<DistributionCard> createState() => _DistributionCardState();
}

class _DistributionCardState extends State<DistributionCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.distribution.availableBaskets <= 10 && widget.distribution.availableBaskets > 0) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10),
      )..repeat(reverse: true);

      _colorAnimation = ColorTween(
        begin: Colors.amber.withOpacity(0.91),
        end: Colors.amberAccent.withOpacity(0.91),
      ).animate(_animationController!);
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSoldOut = widget.distribution.availableBaskets <= 0;
    final bool isLowStock = widget.distribution.availableBaskets <= 10 && !isSoldOut;

    Widget imageWidget;
    // --- DÉBUT DE LA CORRECTION ---
    if (widget.distribution.imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        widget.distribution.imageUrl,
        // --- FIN DE LA CORRECTION ---
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 100,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 100,
            color: Colors.grey[200],
            child: Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
          );
        },
      );
    } else {
      // --- DÉBUT DE LA CORRECTION ---
      imageWidget = Image.asset(
        widget.distribution.imageUrl,
        // --- FIN DE LA CORRECTION ---
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 100,
            color: Colors.grey[200],
            child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, PageTransition(
          type: PageTransitionType.rightToLeft,
          // ON PASSE L'ID AU LIEU DE L'OBJET ENTIER
          child: DistributionDetailScreen(distributionId: widget.distribution.id),
        ));
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageWidget,
                ),
                if (isLowStock && _animationController != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _animationController!,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          color: _colorAnimation?.value ?? Colors.greenAccent.withOpacity(0.91),
                          child: Text(
                            "Plus que ${widget.distribution.availableBaskets} paniers !",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (isSoldOut)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      color: Colors.red.withOpacity(0.91),
                      child: const Text(
                        "Épuisé",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.distribution.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('d MMM yyyy', 'fr_FR').format(widget.distribution.date.toDate()),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (!isSoldOut)
                        Row(
                          children: [
                            Icon(Icons.shopping_basket_outlined, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.distribution.availableBaskets}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
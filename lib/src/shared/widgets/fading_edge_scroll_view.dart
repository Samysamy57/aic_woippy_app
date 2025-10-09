// lib/src/shared/widgets/fading_edge_scroll_view.dart
import 'package:flutter/material.dart';

/// A widget that wraps a scrollable child (like a ListView) and applies
/// a fading effect to the top and bottom edges.
class FadingEdgeScrollView extends StatelessWidget {
  final Widget child;
  const FadingEdgeScrollView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // The ShaderMask is the widget that applies the gradient effect.
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        // We create a linear gradient to act as the "mask".
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // The colors define the opacity:
          // - Transparent at the very top
          // - Opaque (black) shortly after
          // - Opaque for most of the content
          // - Transparent again at the very bottom
          colors: const [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          // The stops control where the color transitions happen.
          // This creates a short fade effect (5%) at the top and bottom.
          stops: const [0.0, 0.05, 0.95, 1.0],
        ).createShader(bounds);
      },
      // This blend mode is crucial. It tells the ShaderMask to only draw
      // the child where the mask (our gradient) is opaque.
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
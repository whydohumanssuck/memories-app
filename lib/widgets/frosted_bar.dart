import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedBar extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const FrostedBar({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.78),
              borderRadius: borderRadius,
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

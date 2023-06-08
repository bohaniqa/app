import 'package:flutter/material.dart';
import '../theme.dart';

class BOQIconBadge extends StatelessWidget {

  const BOQIconBadge({
    super.key,
    required this.icon,
    this.size = 64.0,
    this.backgroundColor,
    this.color,
  });

  final IconData icon;

  final double size;

  final Color? backgroundColor;

  final Color? color;

  @override
  Widget build(final BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? BOQColors.theme.accent1,
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.5,
            color: color ?? BOQColors.theme.background,
          ),
        ),
      ),
    );
  }
}
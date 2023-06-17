import 'package:boq/src/fonts/icons.dart';
import 'package:flutter/material.dart';

class BOQCurrencySymbol extends StatelessWidget {

  const BOQCurrencySymbol({
    super.key,
    this.icon = BOQIcons.symbolfill,
    this.size = 18.0,
    this.color,
  });

  factory BOQCurrencySymbol.boq({
    final Color? color,
  }) => BOQCurrencySymbol(
    color: color,
  );

  factory BOQCurrencySymbol.sol({
    final Color? color,
  }) => BOQCurrencySymbol(
    icon: BOQIcons.solana, 
    color: color,
  );

  final IconData icon;

  final double size;

  final Color? color;

  @override
  Widget build(final BuildContext context) => Icon(
    icon, 
    size: size, 
    color: color,
  );
}
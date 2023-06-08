import 'package:boq/src/consts.dart';
import 'package:boq/src/theme.dart';
import 'package:boq/src/widgets/currency_symbol.dart';
import 'package:flutter/material.dart';
import 'number_tile.dart';

class BOQNumberCard extends StatelessWidget {

  const BOQNumberCard({
    super.key, 
    required this.value,
    required this.label,
    this.color,
    this.valueSuffix,
  });

  final num? value;
  final String label;
  final Color? color;
  final Widget? valueSuffix;

  factory BOQNumberCard.boq({
    required final num? value,
    required final String label,
    final Color? color,
  }) => BOQNumberCard(
    value: value, 
    label: label, 
    color: color,
    valueSuffix: BOQCurrencySymbol(
      color: BOQColors.theme.background,
    ),
  );

  factory BOQNumberCard.sol({
    required final num? value,
    required final String label,
    final Color? color,
  }) => BOQNumberCard(
    value: value, 
    label: label,  
    color: color,
    valueSuffix: BOQCurrencySymbol.sol(
      color: BOQColors.theme.background,
    ),
  );

  factory BOQNumberCard.percent({
    required final num? value,
    required final String label,
    final Color? color,
  }) => BOQNumberCard(
    value: value, 
    label: label,  
    color: color,
    valueSuffix: const Text(
      '%',
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  @override
  Widget build(final BuildContext context) => Card(
    color: color ?? BOQColors.theme.accent1,
    child: Padding(
      padding: const EdgeInsets.all(kSpacing),
      child: BOQNumberTile(
        value: value,
        label: label,
        valueColor: BOQColors.theme.background,
        labelColor: BOQColors.theme.background,
        valueSuffix: valueSuffix,
      ),
    ),
  );
}
import 'package:boq/src/theme.dart';
import 'package:flutter/material.dart';
import '../number_format.dart';

class BOQNumberTile extends StatelessWidget {

  const BOQNumberTile({
    super.key, 
    required this.value,
    required this.label,
    this.valueColor,
    this.labelColor,
    this.valueSuffix,
  });

  final num? value;
  final String label;
  final Color? valueColor;
  final Color? labelColor;
  final Widget? valueSuffix;

  @override
  Widget build(final BuildContext context) {
    final TextStyle style = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: valueColor ?? BOQColors.theme.text,
    );
    final String valueString = value != null ? abbreviateNumber(value!) : '-';
    final Text title = Text(valueString, style: style);
    return Column(
      children: [
        valueSuffix != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                title,
                const SizedBox(width: 4.0),
                valueSuffix ?? const SizedBox.shrink()
              ],
            )
          : title,
        Text(
          label, 
          style: TextStyle(
            fontSize: 14.0,
            color: labelColor ?? BOQColors.theme.subtext,
          ),
        ),
      ],
    );
  }
}
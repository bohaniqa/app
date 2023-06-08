import 'package:boq/src/consts.dart';
import 'package:boq/src/fonts/icons.dart';
import 'package:boq/src/theme.dart';
import 'package:flutter/material.dart';

class BOQHelpTile extends StatelessWidget {

  const BOQHelpTile({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;

  final String answer;

  @override
  Widget build(final BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 18.0,
        ),
      ),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          indent: kSpacing,
          endIndent: kSpacing,
          color: BOQColors.theme.background,
        ),
        Padding(
          padding: const EdgeInsets.all(kSpacing),
          child: Text(answer),
        ),
      ],
    );
  }
}
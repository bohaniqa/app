import 'package:flutter/material.dart';

class BOQSectionTitle extends StatelessWidget {
  
  const BOQSectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(final BuildContext context) 
    => Text(
      title,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 14, 
        fontWeight: FontWeight.w500,
      ),
    );
}
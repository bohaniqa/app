import 'package:boq/src/consts.dart';
import 'package:boq/src/screens/screen.dart';
import 'package:boq/src/widgets/help_tile.dart';
import 'package:flutter/material.dart';

class BOQHelpScreen extends StatelessWidget {

  const BOQHelpScreen({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: BOQScreen(
        title: 'HELP', 
        canPop: true,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: const [
            BOQHelpTile(
              question: 'What is the Emission Rate?',
              answer: 'Mining rewards.',
            ),
            SizedBox(
              height: kItemSpacing,
            ),
            BOQHelpTile(
              question: 'What is the Inflation Rate?',
              answer: 'Mining rewards increase.',
            ),
          ],
        ),
      ),
    );
  }
}
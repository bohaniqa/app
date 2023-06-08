import 'package:boq/src/consts.dart';
import 'package:boq/src/fonts/icons.dart';
import 'package:flutter/material.dart';

class BOQScreen extends StatelessWidget {

  const BOQScreen({
    super.key,
    required this.title,
    required this.child,
    this.canPop = false,
  });

  final String title;

  final Widget child;

  final bool canPop;

  void _pop(final BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(final BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: kSpacing),
            Row(
              children: [
                if (canPop)
                  GestureDetector(
                    onTap: () => _pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(right: BOQIcons.size),
                      child: Icon(BOQIcons.arrowleft),
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (canPop)
                  const SizedBox(
                    width: BOQIcons.size * 2.0,
                  ),
              ],
            ),
            const SizedBox(height: kSpacing),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
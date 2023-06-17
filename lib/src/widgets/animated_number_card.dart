import 'package:boq/src/theme.dart';
import 'package:flutter/material.dart';
import '../consts.dart';
import '../number_format.dart';
import 'currency_symbol.dart';

class BOQAnimatedCountCard extends StatelessWidget {

  const BOQAnimatedCountCard({
    super.key, 
    required this.count,
    required this.label,
  });

  final int count;
  final String label;

  @override
  Widget build(final BuildContext context) => Card(
    color: BOQColors.theme.accent2,
    child: Padding(
      padding: const EdgeInsets.all(kSpacing),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AnimatedCount(count: count),
              const SizedBox(width: 4.0),
              BOQCurrencySymbol.boq(color: BOQColors.theme.background)
            ],
          ),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: BOQColors.theme.background,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

class _AnimatedCount extends ImplicitlyAnimatedWidget {
  
  const _AnimatedCount({
    required this.count,
    Duration duration = const Duration(seconds: 2),
    Curve curve = Curves.fastOutSlowIn,
  }) : super(duration: duration, curve: curve);

  final int count;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends AnimatedWidgetBaseState<_AnimatedCount> {
  
  late IntTween _intCount;

  @override
  void initState() {
    _intCount = IntTween(begin: widget.count, end: widget.count);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return Text(
      formatNumber(
        _intCount.evaluate(animation), 
        dps: 0,
      ).toString(),
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w900,
        color: BOQColors.theme.background,
        fontFamily: 'Roboto'
      ),
    );
  }

  @override
  void forEachTween(final TweenVisitor<dynamic> visitor) {
    _intCount = visitor(
      _intCount,
      widget.count, 
      (dynamic value) => IntTween(begin: value)
    ) as IntTween;
  }
}
import 'package:boq/src/consts.dart';
import 'package:boq/src/number_format.dart';
import 'package:boq/src/providers/account.dart';
import 'package:boq/src/providers/price.dart';
import 'package:boq/src/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BOQProfitabilityCalculator extends StatefulWidget {

  const BOQProfitabilityCalculator({
    super.key,
  });

  @override
  State<BOQProfitabilityCalculator> createState() => _BOQProfitabilityCalculatorState();
}

class _BOQProfitabilityCalculatorState extends State<BOQProfitabilityCalculator> {

  double? _price;
  int? _numberOfShifts;

  void _onPriceChange(final String value) {
    final double? price = double.tryParse(value);
    if (mounted && _price != price) {
      setState(() => _price = price ?? 0.0);
    }
  }

  void _onNumberOfShiftsChanged(final String value) {
    final int? numberOfShifts = int.tryParse(value);
    if (mounted && _numberOfShifts != numberOfShifts) {
      setState(() => _numberOfShifts = numberOfShifts ?? 0);
    }
  }

  Widget _label(final String text) => Text(
    text,
    textAlign: TextAlign.start,
    style: TextStyle(
      fontSize: 12,
      color: BOQColors.theme.subtext,
    ),
  );

  double _totalRewards({
    required final int numberOfShifts,
  }) {
    final double lastTerm = kInflationRate * (numberOfShifts-1);
    final double inflationRewards = (numberOfShifts / 2) * lastTerm;
    return (kBaseRate*numberOfShifts)+inflationRewards;
  }

  double _shiftRate({
    required final int numberOfShifts,
  }) {
    return numberOfShifts == 0 ? 0 : kBaseRate + ((numberOfShifts-1) * kInflationRate);
  }

  @override
  Widget build(final BuildContext context) {
    final BOQPriceProvider priceProvider = context.watch<BOQPriceProvider>();
    final double? price = _price ?? priceProvider.value;
    final int? numberOfShifts = _numberOfShifts;
    final rewards = price != null ? price*_shiftRate(numberOfShifts: numberOfShifts ?? 0) : null;
    // final rewards = price != null ? price*_totalRewards(numberOfShifts: numberOfShifts ?? 1) : null;
    final rate = rewards != null ? formatCurrency(rewards) : null;
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '\$$rate',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // const SizedBox(
              //   height: 4.0,
              // ),
              Text(
                '  |  shift rewards',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: BOQColors.theme.subtext
                ),
              )
            ],
          ),
          const SizedBox(
            height: kSpacing,
          ),
          _label('$kTokenSymbol Token Price'),
          const SizedBox(
            height: kItemSpacing,
          ),
          TextFormField(
            cursorColor: BOQColors.theme.subtext,
            keyboardType: TextInputType.number,
            initialValue: price?.toString(),
            onChanged: _onPriceChange,
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                  left: kSpacing, 
                  bottom: 2.0,
                  right: 2.0,
                ),
                child: Text(
                  '\$', 
                  style: TextStyle(
                    color: BOQColors.theme.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0, 
                minHeight: 0,
              ),
            ),
          ),
          const SizedBox(
            height: kSpacing,
          ),
          _label('Number of Shifts'),
          const SizedBox(
            height: kItemSpacing,
          ),
          TextFormField(
            cursorColor: BOQColors.theme.subtext,
            keyboardType: const TextInputType.numberWithOptions(),
            initialValue: numberOfShifts?.toString(),
            onChanged: _onNumberOfShiftsChanged,
            decoration: const InputDecoration(
              hintText: '0',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
    );
  }
}
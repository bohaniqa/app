import 'package:boq/src/consts.dart';
import 'package:boq/src/fonts/icons.dart';
import 'package:boq/src/program/state.dart';
import 'package:boq/src/providers/supply.dart';
import 'package:boq/src/screens/screen.dart';
import 'package:boq/src/theme.dart';
import 'package:boq/src/widgets/animated_number_card.dart';
import 'package:boq/src/widgets/icon_badge.dart';
import 'package:boq/src/widgets/number_card.dart';
import 'package:boq/src/widgets/profitability_calculator.dart';
import 'package:boq/src/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

import '../providers/account.dart';
import '../providers/price.dart';

class BOQDashboardScreen extends StatelessWidget {

  const BOQDashboardScreen({super.key});

  Widget _banner({
    required final IconData icon,
    required final String description,
    final Color? color,
  }) => Row(
    children: [
      BOQIconBadge(
        icon: icon,
        backgroundColor: color,
      ),
      const SizedBox(
        width: 16.0,
      ),
      Expanded(
        child: Text(description),
      ),
    ],
  );

  Widget _tile({
    required final num? value,
    required final String label,
    required final String message,
  }) => Expanded(
    child: Tooltip(
      message: message,
      child: BOQNumberCard(
        value: value, 
        label: label,
        color: BOQColors.theme.accent2,
      ),
    ),
  );
  
  Widget _boqTile({
    required final double? value,
    required final String label,
    required final String message,
  }) => Expanded(
    child: Tooltip(
      message: message,
      child: BOQNumberCard.boq(
        value: value, 
        label: label,
        color: BOQColors.theme.accent2,
      ),
    ),
  );

  double? _shiftHeight({
    required final BOQAccount? account,
    required final BOQEmployer? employer
  }) {
    if (account == null || employer == null) return null;
    return employer.shift(account.slot.toBigInt()) * kCollectionSize;
  }

  Future<void> _onRefresh(final BuildContext context) async {
    try {
      final provider = SolanaWalletProvider.of(context);
      await Future.wait([
        BOQPriceProvider.instance.update(provider),
        BOQAccountProvider.instance.update(provider),
        // BOQSupplyProvider.instance.update(provider),
      ]);
    } catch (error) {
      final snackBar = SnackBar(
        backgroundColor: BOQColors.theme.tile,
        shape: Border(
          top: BorderSide(
            width: 4.0,
            color: BOQColors.theme.background,
          )
        ),
        content: Text(
          'Unable to refresh.', 
          style: TextStyle(color: BOQColors.theme.text),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final BOQAccountProvider accountProvider = context.watch<BOQAccountProvider>();
    final BOQAccount? account = accountProvider.value;
    final BOQEmployer? employer = account?.employer;
    final double? shiftHeight = _shiftHeight(account: account, employer: employer);
    return RefreshIndicator(
      displacement: kSpacing * 2.0,
      color: BOQColors.theme.accent1,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () => _onRefresh(context),
      child: BOQScreen(
        title: 'DASHBOARD',
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BOQSectionTitle(
                title: 'Network',
              ),
              const SizedBox(
                height: kSpacing,
              ),
              _banner(
                icon: BOQIcons.network,
                description: 'Clock-in to earn $kTokenSymbol. A new shift begins every 24 hours.',
                color: BOQColors.theme.accent2,
              ),
              const SizedBox(
                height: kSpacing,
              ),
              Row(
                children: [
                  _tile(
                    value: shiftHeight?.toInt(), 
                    label: 'Total Shifts',
                    message: 'The number of completed shifs.',
                  ),
                  const SizedBox(
                    width: kItemSpacing,
                  ),
                  _tile(
                    value: employer?.employees.toDouble(), 
                    label: 'Total Miners',
                    message: 'The number of miners in circulation.',
                  ),
                ],
              ),
              const SizedBox(
                height: kItemSpacing,
              ),
              Row(
                children: [
                  _boqTile(
                    value: kBaseRate, 
                    label: 'Base Rate',
                    message: 'The minimum mining rewards per shift.',
                  ),
                  const SizedBox(
                    width: kItemSpacing,
                  ),
                  _boqTile(
                    value: kInflationRate, 
                    label: 'Inflation Rate',
                    message: 'The mining rewards increase per shift.',
                  ),
                ],
              ),

              const SizedBox(
                height: kItemSpacing,
              ),

              _BOQSupply(
                employer: employer,
              ),
    
              const SizedBox(
                height: kSpacing * 2.0,
              ),
    
              const BOQSectionTitle(
                title: 'Profitability Calculator',
              ),
              const SizedBox(
                height: kSpacing,
              ),
              _banner(
                icon: BOQIcons.calculator,
                description: 'Estimate the potential earnings of your $kTokenSymbol Miner.',
              ),
              const SizedBox(
                height: kSpacing,
              ),
              const BOQProfitabilityCalculator(),
              const SizedBox(
                height: kSpacing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BOQTile extends StatelessWidget {
  
  const _BOQTile({
    required this.value,
    required this.label,
    required this.message,
  });

  final double? value;
  final String label;
  final String message;

  @override
  Widget build(final BuildContext context) => Expanded(
    child: Tooltip(
      message: message,
      child: BOQNumberCard.boq(
        value: value, 
        label: label,
        color: BOQColors.theme.accent2,
      ),
    ),
  );
}

class _BOQSupply extends StatefulWidget {

  const _BOQSupply({
    required this.employer,
  });

  final BOQEmployer? employer;

  @override
  State<_BOQSupply> createState() => __BOQSupplyState();
}

class __BOQSupplyState extends State<_BOQSupply> {

  double? _maxSupply({
    required final BOQEmployer? employer,
    required final BOQSupply? supply,
  }) {
    if (employer == null || supply == null) {
      return null;
    }
    final double shift = employer.shift(supply.slot.toBigInt());
    final double lastTerm = kInflationRate* (shift-1);
    final double inflationRewards = (shift / 2) * lastTerm;
    // print('MAX @ (${shift}) = ${(((baseRate*shift)+(inflationRewards)) * kCollectionSize)}');
    return 149987500000 - (((kBaseRate*shift)+(inflationRewards)) * kCollectionSize);
  }

  @override
  Widget build(final BuildContext context) {
    final BOQSupplyProvider supplyProvider = context.watch<BOQSupplyProvider>();
    final BOQSupply? supply = supplyProvider.value;
    final double maxSupply = _maxSupply(employer: widget.employer, supply: supply) ?? 0.0;
    return Column(
      children: [
        Tooltip(
          message: 'The number of coins circulating in the market.',
          child: BOQAnimatedCountCard(
            count: tryFromTokenAmount(supply?.circulating)?.toInt() ?? 0, 
            label: 'Circulating Supply',
          ),
          // child: BOQNumberCard.boq(
          //   value: tryFromTokenAmount(supply?.circulating), 
          //   label: 'Circulating Supply',
          //   color: BOQColors.theme.accent2,
          //   abbreviate: false,
          // ),
        ),
        const SizedBox(
          height: kItemSpacing,
        ),
        Tooltip(
          message: 'The maximum number of coins that will ever exist. Decreases with every missed shift.',
          child: BOQAnimatedCountCard(
            count: maxSupply.toInt(), 
            label: 'Maximum Supply',
          ),
          // child: BOQNumberCard.boq(
          //   value: maxSupply, 
          //   label: 'Maximum Supply',
          //   color: BOQColors.theme.accent2,
          //   abbreviate: false,
          // ),
        ),
      ],
    );
  }
}
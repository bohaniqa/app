import 'package:boq/src/consts.dart';
import 'package:boq/src/fonts/icons.dart';
import 'package:boq/src/number_format.dart';
import 'package:boq/src/program/state.dart';
import 'package:boq/src/providers/account.dart';
import 'package:boq/src/providers/miners.dart';
import 'package:boq/src/providers/price.dart';
import 'package:boq/src/providers/settings.dart';
import 'package:boq/src/screens/screen.dart';
import 'package:boq/src/theme.dart';
import 'package:boq/src/widgets/currency_symbol.dart';
import 'package:boq/src/widgets/icon_badge.dart';
import 'package:boq/src/widgets/number_tile.dart';
import 'package:boq/src/widgets/shift_modal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BOQHomeScreen extends StatefulWidget {
  const BOQHomeScreen({super.key});
  static const String routeName = '/home';
  @override
  State<BOQHomeScreen> createState() => _BOQHomeScreenState();
}

class _BOQHomeScreenState extends State<BOQHomeScreen> {

  final TapGestureRecognizer _twitterLink = TapGestureRecognizer();
  final TapGestureRecognizer _discordLink = TapGestureRecognizer();
  final TapGestureRecognizer _mintLink = TapGestureRecognizer();
  @override
  void initState() {
    super.initState();
    _twitterLink.onTap = () => launchUrlString('https://twitter.com/bohaniqa').ignore();
    _discordLink.onTap = () => launchUrlString('https://discord.gg/Ht2g2fRQbs').ignore();
    _mintLink.onTap = () => launchUrlString('https://mint.bohaniqa.com').ignore();
  }
  @override
  void dispose() {
    _twitterLink.dispose();
    _discordLink.dispose();
    _mintLink.dispose();
    super.dispose();
  }

  Future<void> _clockIn() async {
    final provider = SolanaWalletProvider.of(context);
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      builder: (_) => BOQShiftModal(provider: provider),
    ).ignore();
  }

  Widget _header(final BOQAccount? account, final Map<String, BOQMiner>? miners) {
    final BOQEmployer? employer = account?.employer;
    final BOQShift? shift = account?.shift;
    final BigInt slotsPerShift = employer?.slots_per_shift ?? BigInt.one;
    final BigInt totalSlots = shift?.total_slots ?? BigInt.zero;
    final BigInt? totalRewards = shift?.total_rewards;
    final int minersCount = miners?.length ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const BOQIconBadge(
          icon: BOQIcons.symbolfill,
        ),
        BOQNumberTile(
          value: minersCount, 
          label: 'Miners',
        ),
        BOQNumberTile(
          value: totalSlots / slotsPerShift, 
          label: 'Shifts',
        ),
        BOQNumberTile(
          value: totalRewards != null ? fromTokenAmount(totalRewards) : 0.0, 
          label: 'Rewards',
        )
      ],
    );
  }

  Future<void> _disconnectWallet() async {
    final provider = SolanaWalletProvider.of(context);
    provider.disconnect(context).ignore();
  }

  Widget _wallet(final Account wallet, final BOQAccount? account, final double? price) {
    final BigInt? tokenAmount = account?.amount;
    final double? amount = tokenAmount != null ? fromTokenAmount(tokenAmount) : null;
    final double? usdAmount = amount != null && price != null ? amount * price : null;
    return GestureDetector(
      onTap: _disconnectWallet,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(kSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                wallet.label ?? 'Wallet',
                style: TextStyle(color: BOQColors.theme.accent1),
              ),
              const SizedBox(
                height: kItemSpacing,
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      amount != null ? formatCurrency(amount) : '0',
                      style: const TextStyle(
                        fontSize: 24.0, 
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  const BOQCurrencySymbol(),
                ],
              ),
              Text(
                usdAmount != null ? '${formatCurrency(usdAmount)} USD' : 'Total Balance', 
                style: TextStyle(color: BOQColors.theme.subtext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _acknowledged() {
    BOQSettingsProvider.instance.set(minerNotice: true);
    if (mounted) setState(() {});
  }

  Widget _notice() => Padding(
    padding: const EdgeInsets.only(
      bottom: kSpacing,
    ),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: kItemSpacing * 2,
          horizontal: kSpacing,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: "It can take up to 24 hours for a newly minted miner to appear. Don't have a miner? ",
                  children: [
                    TextSpan(
                      text: "Mint now",
                      style: TextStyle(color: BOQColors.theme.accent1),
                      recognizer: _mintLink,
                    ),
                    const TextSpan(
                      text: "."
                    ),
                  ]
                ),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(
              width: kItemSpacing,
            ),
            TextButton(
              onPressed: _acknowledged, 
              child: const Text('Ok'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _frameBuilder(
    final BuildContext context, 
    final Widget child, 
    final int? frame, 
    final bool? wasSynchronouslyLoaded,
  ) => Stack(
    children: [
      AspectRatio(
        aspectRatio: 1,
        child: ColoredBox(
          color: BOQColors.theme.tile,
          child: Icon(
            BOQIcons.symbolfill, 
            color: BOQColors.theme.placeholder,
          ),
        ),
      ),
      child,
    ],
  );

  Widget _image(final int id) => Image.asset(
    'assets/nfts/$id.png',
    frameBuilder: _frameBuilder,
  );

  Widget _itemBuilder(final BuildContext context, final int index) {
    final List<BOQMiner>? miners = BOQMinersProvider.instance.entries;
    if (miners == null) return const SizedBox.shrink();
    final int i = index * 2;
    final int id0 = miners[i].id;
    final int id1 = (i + 1) < miners.length ? miners[i+1].id : -1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: _image(id0)),
        const SizedBox(width: kItemSpacing),
        Flexible(child: id1 < 0 ? const SizedBox.shrink() : _image(id1)),
      ],
    );
  } 

  Widget _fallbackItemBuilder(final BuildContext context, final int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: _image(index)),
        const SizedBox(width: kItemSpacing),
        Flexible(child: _image(index + 1)),
      ],
    );
  } 

  Widget _separatorBuilder(final BuildContext context, final int index) {
    return const SizedBox(height: 8);
  } 

  Future<void> _onRefresh() async {
    try {
      final provider = SolanaWalletProvider.of(context);
      await fullUpdate(provider);
    } catch(_) {
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
    final provider = SolanaWalletProvider.of(context);
    final wallet = provider.connectedAccount;
    final isAuthorized = wallet != null;
    const double buttonRadius = 32;
    final BOQAccountProvider accountProvider = context.watch<BOQAccountProvider>();
    final BOQAccount? account = accountProvider.value;
    final BOQMinersProvider minersProvider = context.watch<BOQMinersProvider>();
    final Map<String, BOQMiner>? miners = minersProvider.value;
    final BOQPriceProvider priceProvider = context.watch<BOQPriceProvider>();
    final double? price = priceProvider.value;
    final bool noticeAcknowledged = BOQSettingsProvider.instance.value?.minerNotice ?? false;
    final bool isLive = (account?.slot ?? 0) >= 201250000;
    return RefreshIndicator(
      displacement: kSpacing * 2.0,
      color: BOQColors.theme.accent1,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: _onRefresh,
      child: BOQScreen(
        title: kAppName,
         child: Stack(
           children: [
              Positioned(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAuthorized)
                      _header(account, miners),
                    if (isAuthorized)
                      const SizedBox(height: kSpacing),
                    if (wallet != null)
                      _wallet(wallet, account, price),
                    if (isAuthorized)
                      const SizedBox(height: kSpacing),
                    Text(
                      isAuthorized ? 'Miners' : 'Collection',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: kSpacing),
                    if (isAuthorized && !noticeAcknowledged)
                      _notice(),
                    Expanded(
                      child: miners != null && isAuthorized
                        ? ListView.separated(
                            itemCount: (miners.length / 2).round(),
                            itemBuilder: _itemBuilder,
                            separatorBuilder: _separatorBuilder,
                            padding: const EdgeInsets.only(
                              bottom: kItemSpacing * 2.0 + buttonRadius * 2.0,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                          )
                        : !isAuthorized
                          ? ListView.separated(
                              itemCount: 50,
                              itemBuilder: _fallbackItemBuilder, 
                              separatorBuilder: _separatorBuilder,
                            )
                          : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: SizedBox.square(
                                  dimension: 48.0,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              Text(
                                'Searching for miners.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
              ),
              if (isAuthorized)
                Positioned(
                  left: kItemSpacing, 
                  right: kItemSpacing, 
                  bottom: kItemSpacing,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isLive)
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text.rich(
                                TextSpan(
                                  text: 'Failed to load account information. Follow us on ',
                                  children: [
                                    TextSpan(
                                      text: 'Twitter',
                                      style: TextStyle(color: BOQColors.theme.accent1),
                                      recognizer: _twitterLink,
                                    ),
                                    TextSpan(text: ' or '),
                                    TextSpan(
                                      text: 'Discord',  
                                      style: TextStyle(color: BOQColors.theme.accent1),
                                      recognizer: _discordLink,
                                    ),
                                    TextSpan(text: ' for updates.'),
                                  ]
                                ),
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      if (!isLive)
                        SizedBox(
                          width: 16.0,
                        ),
                      OutlinedButton(
                        onPressed: isLive ? _clockIn : null, 
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size.fromRadius(buttonRadius),
                          disabledBackgroundColor: BOQColors.theme.placeholder,
                        ),
                        child: const Icon(
                          BOQIcons.clock, 
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
           ],
         ),
      ),
    );
  }
}
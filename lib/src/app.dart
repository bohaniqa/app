import 'package:boq/src/consts.dart';
import 'package:boq/src/fonts/icons.dart';
import 'package:boq/src/screens/home.dart';
import 'package:boq/src/screens/settings.dart';
import 'package:boq/src/screens/dashboard.dart';
import 'package:boq/src/theme.dart';
import 'package:flutter/material.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

class BOQApp extends StatefulWidget {

  const BOQApp({
    super.key,
  });

  @override
  State<BOQApp> createState() => _BOQAppState();
}

class _BOQAppState extends State<BOQApp> {

  int _index = 0;

  final List<Widget> _pages = const [
    BOQHomeScreen(),
    BOQDashboardScreen(),
    BOQSettingsScreen(),
  ];

  void _onDestinationSelected(final int index) {
    if (mounted && index != _index) {
      setState(() => _index = index);
    }
  }

  Future<void> _connectWallet() async {
    final provider = SolanaWalletProvider.of(context);
    provider.connect(context).ignore();
  }

  Widget _signInPopup() => ColoredBox(
    color: BOQColors.theme.background,
    child: Padding(
      padding: const EdgeInsets.all(kSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign in to get started.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          TextButton(onPressed: _connectWallet, child: const Text('Connect Wallet'))
        ],
      ),
    ),
  );

  BottomNavigationBarItem _navigationDestination({
    required final IconData icon,
    required final String label,
  }) => BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: BOQColors.theme.divider,
      ), 
      activeIcon: Icon(
        icon, 
        color: BOQColors.theme.accent1,
      ),
      label: label,
    );

  @override
  Widget build(final BuildContext context) {
    final provider = SolanaWalletProvider.of(context);
    final backgroundColor = Theme.of(context).colorScheme.background;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: _pages[_index],
          ),
          if (!provider.isAuthorized)
            _signInPopup(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onDestinationSelected,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        items: [
          _navigationDestination(
            icon: BOQIcons.home,
            label: 'Home',
          ),
          _navigationDestination(
            icon: BOQIcons.stats,
            label: 'Dashboard',
          ),
          _navigationDestination(
            icon: BOQIcons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

import 'package:boq/src/consts.dart';
import 'package:boq/src/providers/miners.dart';
import 'package:boq/src/providers/price.dart';
import 'package:boq/src/providers/provider.dart';
import 'package:boq/src/providers/settings.dart';
import 'package:boq/src/providers/account.dart';
import 'package:boq/src/providers/supply.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';
import 'src/theme.dart';
import 'src/app.dart';

void main() async {
  
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Future.wait([
    SolanaWalletProvider.initialize(),
    BOQProvider.initialize(),
  ]);

  // await Future.wait([
  //   BOQAccountProvider.instance.delete(), 
  //   BOQMinersProvider.instance.delete(),  
  //   BOQPriceProvider.instance.delete(), 
  //   BOQSettingsProvider.instance.delete(),  
  //   BOQSupplyProvider.instance.delete(),  
  // ]);

  BOQAccountProvider.instance.load();
  BOQMinersProvider.instance.load();
  BOQPriceProvider.instance.load();
  BOQSettingsProvider.instance.load();
  BOQSupplyProvider.instance.load();

  runApp(
    SolanaWalletProvider.create(
      httpCluster: kCluster,
      identity: AppIdentity(
        uri: Uri.parse('https://bohaniqa.com'),
        icon: Uri.parse('favicon.png'),
        name: kAppName
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => BOQAccountProvider.instance),
          ChangeNotifierProvider(create: (context) => BOQMinersProvider.instance),
          ChangeNotifierProvider(create: (context) => BOQPriceProvider.instance),
          ChangeNotifierProvider(create: (context) => BOQSettingsProvider.instance),
          ChangeNotifierProvider(create: (context) => BOQSupplyProvider.instance),
        ],
        child: const BOQLoadState(),
      )
    ),
  );
}

class BOQLoadState extends StatefulWidget {

  const BOQLoadState({
    super.key,
  });

  @override
  State<BOQLoadState> createState() => _BOQLoadStateState();
}

class _BOQLoadStateState extends State<BOQLoadState> {

  bool _initialized = false;

  void _initView(final SolanaWalletProvider provider) {
    if (!_initialized) {
      _initialized = true;
      fullUpdate(provider).ignore();
      provider.adapter.addListener(() => _onAuthorizedStateChanged(provider));
      FlutterNativeSplash.remove();
    }
  }

  void _onAuthorizedStateChanged(final SolanaWalletProvider provider) {
    if (provider.isAuthorized) {
      BOQAccountProvider.instance.update(provider).ignore();
      BOQMinersProvider.instance.update(provider).ignore();
    } else {
      BOQAccountProvider.instance.delete().ignore();
      BOQMinersProvider.instance.delete().ignore();
    }
  }

  @override
  Widget build(final BuildContext context) {
    
    final SolanaWalletProvider provider = SolanaWalletProvider.of(context);
    _initView(provider);

    final BOQSettingsProvider settingsProvider = context.watch<BOQSettingsProvider>();
    final Brightness brightness = settingsProvider.value?.brightness ?? Brightness.dark;
    final ThemeData theme = createThemeData(brightness);
    
    return MaterialApp(
      title: '$kAppName - App',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: ColoredBox(
        color: theme.colorScheme.background,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 588),
            child: const BOQApp(),
          ),
        ),
      ),
    );
  }
}
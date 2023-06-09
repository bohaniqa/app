
import 'package:boq/src/consts.dart';
import 'package:boq/src/providers/miners.dart';
import 'package:boq/src/providers/price.dart';
import 'package:boq/src/providers/provider.dart';
import 'package:boq/src/providers/settings.dart';
import 'package:boq/src/providers/account.dart';
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
  // ]);

  BOQAccountProvider.instance.load();
  BOQMinersProvider.instance.load();
  BOQPriceProvider.instance.load();
  BOQSettingsProvider.instance.load();

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
      provider.adapter.addListener(() => _onAuthorizedStateChanged(provider));
      if (!provider.adapter.isAuthorized) BOQAccountProvider.instance.update(provider).ignore();
      BOQPriceProvider.instance.update(provider).ignore();
      _onAuthorizedStateChanged(provider);
      FlutterNativeSplash.remove();
    }
  }

  void _onAuthorizedStateChanged(final SolanaWalletProvider provider) {
    if (provider.adapter.isAuthorized) {
      BOQAccountProvider.instance.update(provider).ignore();
      BOQMinersProvider.instance.update(provider).ignore();
    }
  }

  @override
  Widget build(final BuildContext context) {
    
    final SolanaWalletProvider provider = SolanaWalletProvider.of(context);
    _initView(provider);

    final BOQSettingsProvider settingsProvider = context.watch<BOQSettingsProvider>();
    final Brightness brightness = settingsProvider.value?.brightness ?? Brightness.light;
    final ThemeData theme = createThemeData(brightness);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const BOQApp(),
    );
  }
}
import 'package:boq/src/providers/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

class BOQPriceProvider extends BOQProvider<double> {

  BOQPriceProvider._();

  static BOQPriceProvider instance = BOQPriceProvider._();

  @override
  String get key => 'boq.price';

  @override
  Future<double>? query(final SolanaWalletProvider provider) 
    => Future.value(null);

  @override
  double? read(final SharedPreferences prefs) => prefs.getDouble(key);

  @override
  Future<bool> write(final SharedPreferences prefs, final double? data) 
    => data != null ? prefs.setDouble(key, data) : delete();
}
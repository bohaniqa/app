import 'dart:convert';

import 'package:boq/src/consts.dart';
import 'package:http/http.dart' as http;
import 'package:boq/src/providers/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

class BOQPriceProvider extends BOQProvider<double> {

  BOQPriceProvider._();

  static BOQPriceProvider instance = BOQPriceProvider._();

  @override
  String get key => 'boq.price';

  @override
  Future<double>? query(final SolanaWalletProvider provider) async {
    const String endpoint = "https://api.geckoterminal.com/api/v2/networks/solana/tokens/"
    "FWzs6NG9xaiGkSTqzU6d4n8BDd8bUpf2uHBQ9iu4HkUo";
    final response = await http.get(Uri.parse(endpoint));
    final Map body = json.decode(response.body);
    final double fdvUSD = double.parse(body['data']['attributes']['fdv_usd']);
    final TokenAmount amount = await provider.connection.getTokenSupply(kTokenMint);
    final double circulating = double.parse(amount.uiAmountString);
    return fdvUSD / circulating;
  }

  @override
  double? read(final SharedPreferences prefs) => prefs.getDouble(key);

  @override
  Future<bool> write(final SharedPreferences prefs, final double? data) 
    => data != null ? prefs.setDouble(key, data) : delete();
}
import 'package:boq/src/consts.dart';
import 'package:boq/src/providers/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

class BOQSupply {

  const BOQSupply({
    required this.slot,
    required this.circulating,
  });

  final int slot;

  final BigInt circulating;

  factory BOQSupply.fromJson(final Map<String, dynamic> json) => BOQSupply(
    slot: json['slot'],
    circulating: BigInt.parse(json['circulating']),
  );
  
  Map<String, dynamic> toJson() => {
    'slot': slot,
    'circulating': circulating.toString(),
  };
}

class BOQSupplyProvider extends BOQProvider<BOQSupply> {

  BOQSupplyProvider._();

  static BOQSupplyProvider instance = BOQSupplyProvider._();

  @override
  String get key => 'boq.supply';

  @override
  Future<BOQSupply>? query(final SolanaWalletProvider provider) async {
    final builder = JsonRpcMethodBuilder<dynamic, dynamic>([
      GetSlot(),
      GetTokenSupply(kTokenMint)
    ]);
    final responses = await provider.connection.sendAll(builder);
    final int slot = (responses[0] as JsonRpcSuccessResponse).result as int;
    final TokenAmount data = (responses[1] as JsonRpcSuccessResponse).result!.value;
    return BOQSupply(
      slot: slot, 
      circulating: data.amount,
    );
  }

  @override
  BOQSupply? read(final SharedPreferences prefs) {
    final Map<String, dynamic>? data = readJson(prefs);
    return data != null ? BOQSupply.fromJson(data) : null;
  }

  @override
  Future<bool> write(final SharedPreferences prefs, final BOQSupply? data) 
    => writeJson(prefs, data?.toJson());
}
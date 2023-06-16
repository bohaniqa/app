import 'dart:convert';
import 'dart:math';
import 'package:boq/src/collection.dart';
import 'package:boq/src/providers/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';
import 'package:http/http.dart' as http;
import '../consts.dart';

class BOQMiner {

  const BOQMiner({
    required this.id,
    required this.token,
  });

  final int id;

  final String token;

  factory BOQMiner.fromJson(final Map<String, dynamic> json) => BOQMiner(
    id: json['id'], 
    token: json['token'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'token': token
  };
}

class _BOQMinerItem {
  const _BOQMinerItem({
    required this.id,
    required this.mint,
    required this.token,
  });
  final int id;
  final String mint;
  final String token;
}

class BOQMinersProvider extends BOQProvider<Map<String, BOQMiner>> {

  BOQMinersProvider._();

  static BOQMinersProvider instance = BOQMinersProvider._();

  @override
  String get key => 'boq.miners';

  List<BOQMiner>? get entries => _entries;
  List<BOQMiner>? _entries;

  @override
  set value(final Map<String, BOQMiner>? newValue) {
    if (value != newValue) {
      _entries = newValue?.values.toList(growable: false);
      super.value = newValue;
    }
  }

  Future<Map<String, int>> _fetchMints() async {
    final response = await http.get(kCollectionMintsURI);
    return jsonDecode(response.body)?.cast<String, int>();
  }

  @override
  Future<Map<String, BOQMiner>>? query(final SolanaWalletProvider provider) async {
    final wallet = provider.connectedAccount?.toPubkey();
    if (wallet == null) throw Exception('Wallet not connected.');
    final List responses = await Future.wait([
      _fetchMints(),
      provider.connection.getTokenAccountsByOwner(
        wallet, 
        filter: TokenAccountsFilter.programId(TokenProgram.programId),
      ),
    ]);
    
    final mintedTokens = Map<String, int>.from(responses[0]); // collectionMints;
    final tokenAccounts = responses[1] as List<TokenAccount>;
    final Map<String, BOQMiner> miners = {};
    for (final tokenAccount in tokenAccounts) {
      final token = TokenAccountInfo.fromAccountInfo(tokenAccount.account);
      if (mintedTokens.containsKey(token.mint)) {
        miners[token.mint] = BOQMiner(
          id: mintedTokens[token.mint]!, 
          token: tokenAccount.pubkey,
        );
      }
    }

    return miners;
  }

  @override
  Map<String, BOQMiner>? read(
    final SharedPreferences prefs,
  ) {
    final Map<String, dynamic>? json = readJson(prefs);
    return json?.map((key, value) => MapEntry<String, BOQMiner>(key, BOQMiner.fromJson(value)));
  }

  @override
  Future<bool> write(final SharedPreferences prefs, final Map<String, BOQMiner>? data) 
    => writeJson(prefs, data);
}
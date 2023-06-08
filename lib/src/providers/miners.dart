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

    final List<_BOQMinerItem> blueMiners = [];
    final List<_BOQMinerItem> pinkMiners = [];
    final mintedTokens = Map<String, int>.from(responses[0]);
    final tokenAccounts = responses[1] as List<TokenAccount>;
    for (final tokenAccount in tokenAccounts) {
      final token = TokenAccountInfo.fromAccountInfo(tokenAccount.account);
      if (collectionMints.containsKey(token.mint)) {
        final item = _BOQMinerItem(
          id: mintedTokens[token.mint]!, 
          mint: token.mint, 
          token: tokenAccount.pubkey,
        );
        if (item.id < 5000) {
          blueMiners.add(item);
        } else {
          pinkMiners.add(item);
        }
      }
    }

    blueMiners.sort((a, b) => a.id - b.id);
    pinkMiners.sort((a, b) => a.id - b.id);
    final int maxLength = max(blueMiners.length, pinkMiners.length);
    final Map<String, BOQMiner> miners = {};
    for (int i = 0; i < maxLength; ++i) {
      if (i < blueMiners.length) {
        final blueMiner = blueMiners[i];
        miners[blueMiner.mint] = BOQMiner(
          id: blueMiner.id, 
          token: blueMiner.token,
        );
      }
      if (i < pinkMiners.length) {
        final pinkMiner = pinkMiners[i];
        miners[pinkMiner.mint] = BOQMiner(
          id: pinkMiner.id, 
          token: pinkMiner.token,
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
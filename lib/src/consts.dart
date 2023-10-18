import 'dart:math' show pow;
import 'package:boq/src/providers/account.dart';
import 'package:boq/src/providers/miners.dart';
import 'package:boq/src/providers/price.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

const String kFontFamily = 'Rubik';
const String kAppName = 'Bohaniqa';
const String kTokenSymbol = 'BOQ';
const double kSpacing = 24.0;
const double kItemSpacing = 8.0;

// final kCluster = Cluster.devnet; // dev
final kCluster = kIsWeb 
  ? Cluster(Uri.https('solana-mainnet.g.alchemy.com', 'v2/7bBFOKctvSUjOaKWnEX6_vG4iPUPVKcW'))
  : Cluster.mainnet; // main

// final kTokenMint = Pubkey.fromBase58('66V5fdwnNTEXxJFuiWsMTWo2e6QZymnXAhBo2NbZWCsY'); // dev
final kTokenMint = Pubkey.fromBase58('FWzs6NG9xaiGkSTqzU6d4n8BDd8bUpf2uHBQ9iu4HkUo'); // main
final kTokenMetadata = MetaplexTokenMetadataProgram.findMetadataAddress(kTokenMint);
// final kCollectionMint = Pubkey.fromBase58('CBHkXSbvsV1BLSzUcDvYydYp5RjEbwGpSYDhazqnCNVr'); // dev
final kCollectionMint = Pubkey.fromBase58('ArHNsvzrXhvNB5YwhfzxQfZukF44Pupsk2vTejGSpi1H'); // main
final kCollectionMetadata = MetaplexTokenMetadataProgram.findMetadataAddress(kCollectionMint);
// final kCandyMachineCreator = Pubkey.fromBase58('GoJE16iGSFsgUERqVou5BBBY88i9zB3aMZSimuLCWrC5'); // dev
final kCandyMachineCreator = Pubkey.fromBase58('Ha9dPhnKFfpunZLtVu9t6vpGYdyJHJj6NJQFiQXRPt4R'); // main
final kCollectionMintsURI = Uri.https('raw.githubusercontent.com', 'bohaniqa/bohaniqa.github.io/master/mints.json');
const kCollectionSize = 10000;
const kBaseRate = 250.0;
const kInflationRate = 0.25;
const kMaxShifts = 10000;
final kUnit = BigInt.from(pow(10, 8));
const kSlotsPerShift = 250000;
const kMaxSupply = 149987500000;

double fromTokenAmount(final BigInt value) {
  return value / kUnit;
}

double? tryFromTokenAmount(final BigInt? value) {
  return value != null ? fromTokenAmount(value) : null;
}

Future<void> fullUpdate(final SolanaWalletProvider provider) {
  final futures = [
    BOQPriceProvider.instance.update(provider),
    BOQAccountProvider.instance.update(provider),
  ];
  if (provider.isAuthorized) {
    futures.add(BOQMinersProvider.instance.update(provider));
  }
  return Future.wait(futures);
}
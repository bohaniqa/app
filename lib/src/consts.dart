import 'dart:math' show pow;
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

const String kFontFamily = 'Rubik';
const String kAppName = 'BOHANIQA';
const String kTokenSymbol = 'BOQ';
const double kSpacing = 24.0;
const double kItemSpacing = 8.0;

final kCluster = Cluster.devnet;

final kTokenMint = Pubkey.fromBase58('6VL54oH9h56D9dsXWJpg8VF1jsuf8SWHamVg2DuSuP1f');
final kTokenMetadata = MetaplexTokenMetadataProgram.findMetadataAddress(kTokenMint);
final kCollectionMint = Pubkey.fromBase58('CBHkXSbvsV1BLSzUcDvYydYp5RjEbwGpSYDhazqnCNVr');
final kCollectionMetadata = MetaplexTokenMetadataProgram.findMetadataAddress(kCollectionMint);
final kCandyMachineCreator = Pubkey.fromBase58('GoJE16iGSFsgUERqVou5BBBY88i9zB3aMZSimuLCWrC5');
final kCollectionMintsURI = Uri.https('raw.githubusercontent.com', 'bohaniqa/bohaniqa.github.io/master/mints.json');
const kCollectionSize = 10000;
const kBaseRate = 250.0;
const kBonusRate = 0.25;
const kMaxShifts = 10000;

double fromTokenAmount(final BigInt value, [final int decimals = 8]) {
  return value / pow(10, decimals).toBigInt();
}
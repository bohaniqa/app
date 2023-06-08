import 'package:boq/src/consts.dart';
import 'package:boq/src/program/program.dart';
import 'package:boq/src/program/state.dart';
import 'package:boq/src/providers/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

class BOQAccount {

  const BOQAccount({
    required this.amount,
    required this.employer,
    required this.shift,
    required this.slot,
  });

  final BigInt? amount;
  final BOQEmployer? employer;
  final BOQShift? shift;
  final int slot;

  factory BOQAccount.fromJson(final Map<String, dynamic> json) {
    final amount = json['amount'];
    final employer = json['employer'];
    final shift = json['shift'];
    return BOQAccount(
      amount: amount != null ? BigInt.parse(amount) : null,
      employer: employer != null ? BOQEmployer.fromJson(employer) : null,
      shift: shift != null ? BOQShift.fromJson(shift) : null,
      slot: json['slot'] ?? 0,
    );
  }

  Map<String, dynamic>? _toJson(final Map<String, dynamic>? json) {
    if (json != null) {
      for (final String key in json.keys) {
        if (json[key] is BigInt) {
          json[key] = json[key].toString();
        }
      }
    }
    return json;
  }
  
  Map<String, dynamic> toJson() => {
    'amount': amount.toString(),
    'employer': _toJson(employer?.toJson()),
    'shift': _toJson(shift?.toJson()),
    'slot': slot,
  };
}

class BOQAccountProvider extends BOQProvider<BOQAccount> {

  BOQAccountProvider._();

  static BOQAccountProvider instance = BOQAccountProvider._();

  @override
  String get key => 'boq.account';

  T? _unwrapResponseContext<T>(final JsonRpcResponse response) {
    if (response is JsonRpcSuccessResponse) {
      return response.result.value;
    } else {
      return null;
    }
  }

  @override
  Future<BOQAccount>? query(final SolanaWalletProvider provider) async {
    final wallet = provider.connectedAccount?.toPubkey();
    if (wallet == null) throw Exception('Wallet not connected.');
    final ata = Pubkey.findAssociatedTokenAddress(wallet, kTokenMint);
    final builder = JsonRpcMethodBuilder<dynamic, dynamic>([
      GetTokenAccountBalance(ata.pubkey),
      GetAccountInfo(BOQShiftProgram.findEmployer().pubkey),
      GetAccountInfo(BOQShiftProgram.findShift(wallet).pubkey),
      GetSlot(),
    ]);
    final responses = await provider.connection.sendAll(builder);
    final TokenAmount? tokenAmount = _unwrapResponseContext(responses[0]);
    final AccountInfo? employerAccount = _unwrapResponseContext(responses[1]);
    final AccountInfo? shiftAccount = _unwrapResponseContext(responses[2]);
    final int slot = (responses[3] as JsonRpcSuccessResponse).result as int;
    return BOQAccount(
      amount: tokenAmount?.amount,
      employer: BOQEmployer.tryFromBase64(employerAccount?.binaryData),
      shift: BOQShift.tryFromBase64(shiftAccount?.binaryData),
      slot: slot,
    );
  }

  @override
  BOQAccount? read(final SharedPreferences prefs) {
    final Map<String, dynamic>? data = readJson(prefs);
    return data != null ? BOQAccount.fromJson(data) : null;
  }

  @override
  Future<bool> write(final SharedPreferences prefs, final BOQAccount? data) 
    => writeJson(prefs, data?.toJson());
}
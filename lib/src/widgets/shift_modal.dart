import 'dart:async';
import 'dart:math';
import 'package:boq/src/consts.dart';
import 'package:boq/src/providers/account.dart';
import 'package:boq/src/providers/miners.dart';
import 'package:boq/src/providers/settings.dart';
import 'package:boq/src/theme.dart';
import 'package:boq/src/widgets/icon_badge.dart';
import 'package:flutter/material.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';
import '../program/program.dart';
import '../program/state.dart';

enum _BOQShiftState {
  initialize,
  createAccount,
  mine,
  error,
  success,
}

class _BOQShiftException implements Exception {
  const _BOQShiftException(this.message);
  final String message;
}

class BOQShiftModal extends StatefulWidget {
  
  const BOQShiftModal({
    super.key,
    required this.provider,
  });

  final SolanaWalletProvider provider;

  @override
  State<BOQShiftModal> createState() => _BOQShiftModalState();
}

class _BOQShiftModalState extends State<BOQShiftModal> {

  String? _message;

  Completer<void>? _createAccountConfirmation;

  late Pubkey _wallet;

  late bool _force;

  static const int _shiftsPerTx = 10;
  static const int _txLimit = 10;

  _BOQShiftState get state => _state;
  _BOQShiftState _state = _BOQShiftState.initialize;
  set state(final _BOQShiftState newValue) {
    if (mounted && _state != newValue) {
      setState(() => _state = newValue);
    }
  }

  bool get request => _request;
  bool _request = false;
  set request(final bool newValue) {
    if (mounted && _request != newValue) {
      setState(() => _request = newValue);
    }
  }

  @override
  void initState() {
    super.initState();
    _force = BOQSettingsProvider.instance.value?.forceShift ?? false;
    Future.delayed(
      const Duration(milliseconds: 200),
      () => _shift(widget.provider),
    );
  }

  void _cancel() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<BOQShift?> _getShift(
    final Connection connection, {
    required final Pubkey pubkey, 
  }) async {
    BOQShift? shift = BOQAccountProvider.instance.value?.shift;
    if (shift == null) {
      final AccountInfo? shiftAccount = await connection.getAccountInfo(pubkey);
      if (shiftAccount != null) {
        shift = BOQShift.fromBase64(shiftAccount.binaryData);
      }
    }
    return shift;
  }

  Future<void> _createShift(
    final Connection connection, 
    final SolanaWalletAdapter adapter, {
    required final Pubkey wallet, 
  }) async {
    final builder = JsonRpcMethodBuilder<dynamic, dynamic>([GetLatestBlockhash(), GetSlot()]);
    final List<JsonRpcResponse> responses = await connection.sendAll(builder, eagerError: true);
    final blockhash = (responses[0] as JsonRpcContextResponse).result!.value;
    final slot = (responses[1] as JsonRpcSuccessResponse).result as int;

    final ProgramAddress shiftAddress = BOQShiftProgram.findShift(wallet);
    final Pubkey boqPubkey = Pubkey.findAssociatedTokenAddress(wallet, kTokenMint).pubkey;

    final tx = Transaction.v0(
      payer: wallet, 
      recentBlockhash: blockhash.blockhash,
      instructions: [
        AssociatedTokenProgram.createIdempotent(
          fundingAccount: wallet, 
          associatedTokenAccount: boqPubkey,
          associatedTokenAccountOwner: wallet, 
          tokenMint: kTokenMint,
        ),
        BOQShiftProgram.createShift(
          owner: wallet,
          shift: shiftAddress,
        ),
        BOQShiftProgram.initializeShift(
          owner: wallet,
          shift: shiftAddress,
          slot: slot.toBigInt(),
        ),
      ], 
    );

    final String encodedTx = adapter.encodeTransaction(tx);
    final SignTransactionsResult result = await adapter.signTransactions([encodedTx]);
    final String signedTx = result.signedPayloads.first;

    final String signature = await connection.sendSignedTransaction((signedTx));
    await connection.confirmTransaction(signature);
  }

  Future<BOQEmployer?> _getEmployer(
    final Connection connection, {
    required final Pubkey pubkey,
  }) async {
    BOQEmployer? employer = BOQAccountProvider.instance.value?.employer;
    if (employer == null) {
      final AccountInfo? employerAccount = await connection.getAccountInfo(pubkey);
      if (employerAccount != null) {
        employer = BOQEmployer.fromBase64(employerAccount.binaryData);
      }
    }
    return employer;
  }

  Future<BigInt> _getSlot(
    final Connection connection, 
  ) async {
    int? slot = BOQAccountProvider.instance.value?.slot;
    return (slot ?? (await connection.getSlot())).toBigInt();
  }

  List<List<T>> _chunk<T>(
    final List<T> items, {
    required final int size,
  }) {
    final List<List<T>> chunks = [];
    for (int i = 0; i < items.length; i += size) {
      chunks.add(items.sublist(i, min(i+size, items.length)));
    }
    return chunks;
  }

  void _debugRate({
    required final BigInt slot,
    required final BOQEmployer employer, 
    required final BOQEmployee employee,
    required final BigInt extraShifts,
  }) {
    final elapsed_slots = slot - employee.last_slot;
    final available_slots = elapsed_slots < employer.slots_per_shift ? elapsed_slots : employer.slots_per_shift;
    final employee_total_slots = employee.total_slots + available_slots;
    final current_shift = extraShifts + (employee.total_slots ~/ employer.slots_per_shift);
    final next_shift = current_shift + BigInt.one;
    final shift_boundary = (current_shift + BigInt.one) * employer.slots_per_shift;
    final next_shift_slots = employee_total_slots > shift_boundary
      ? employee_total_slots % employer.slots_per_shift
      : BigInt.zero;
    final current_shift_slots = available_slots - next_shift_slots;
    final a = employer.base_rate_per_slot * available_slots;
    final b0 = employer.inflation_rate_per_slot * current_shift_slots * current_shift;
    final b1 = employer.inflation_rate_per_slot * next_shift_slots * next_shift;
    final inflation_rate = (employer.inflation_rate_per_slot * current_shift_slots * current_shift)
    + (employer.inflation_rate_per_slot * next_shift_slots * next_shift);
    print('********************************************************************************');
    print('EMPLOYEE         = ${employee.toJson()}');
    print('********************************************************************************');
    print('SLOT HEIGHT      = $slot');
    print('ELAPSED SLOTS    = $elapsed_slots');
    print('AVAILABLE SLOTS  = $available_slots');
    print('CURRENT SHIFT    = $current_shift');
    print('NEXT SHIFT       = $next_shift');
    print('NEXT SHIFT SLOTS = $next_shift_slots');
    print('CURR SHIFT SLOTS = $current_shift_slots');
    print('*** BASE RATE ***   = $a');
    print('*** INFL RATE ***   = $inflation_rate ($b0 : $b1)');
    print('*** PAYOUT ***   = ${fromTokenAmount(a + inflation_rate)}');
  }

  Future<List<Pubkey>> _getAccounts(
    final Connection connection, {
    required final BigInt slot,
    required final BOQEmployer employer, 
    required final List<Pubkey> employees, 
    required final List<Pubkey> tokens, 
  }) async {
    final List<Pubkey> accounts = [];
    final BigInt updateThreshold = slot - (employer.slots_per_shift ~/ BigInt.two);
    final builder = JsonRpcMethodBuilder(_chunk(employees, size: 100)
      .map(GetMultipleAccounts.map)
      .toList(growable: false));
    final responses = (await connection.sendAll(builder))
      .expand((response) => (response as JsonRpcSuccessResponse).result.value)
      .toList(growable: false);
    for (int i = 0; i < responses.length; ++i) {
      final AccountInfo? accountInfo = responses[i];
      if (accountInfo != null) {
        final BOQEmployee employee = BOQEmployee.fromBase64(accountInfo.binaryData);
        _debugRate(slot: slot, employer: employer, employee: employee, extraShifts: BigInt.from(3));
        if (_force || employee.last_slot < updateThreshold) {
          accounts.add(tokens[i]);
          accounts.add(employees[i]);
        }
      }
    }
    return accounts;
  }

  Future<List<Transaction>> _createTxs(
    final Connection connection, {
    required final Pubkey wallet,
    required final Pubkey employerPubkey,
    required final Pubkey shiftPubkey,
    required final List<Pubkey> nftsAndEmployeePairs,
  }) async {
    const int accountsPerTx = _shiftsPerTx * 2;
    final List<Transaction> txs = [];
    final Pubkey mintAuthority = BOQShiftProgram.findMintAuthority().pubkey;
    final Pubkey ataAccount = Pubkey.findAssociatedTokenAddress(wallet, kTokenMint).pubkey;
    final List<List<Pubkey>> accounts = _chunk(nftsAndEmployeePairs, size: accountsPerTx);
    final blockhash = await connection.getLatestBlockhash();
    for (final List<Pubkey> nftsAndEmployeePairs in accounts) {
      txs.add(
        Transaction.v0(
          payer: wallet, 
          recentBlockhash: blockhash.blockhash,
          instructions: [
            BOQShiftProgram.shift(
              mintAuthority: mintAuthority,
              employer: employerPubkey,
              shift: shiftPubkey,
              tokenMint: kTokenMint,
              ataAccount: ataAccount,
              nftsAndEmployees: nftsAndEmployeePairs,
            ),
          ], 
        ),
      );
    }
    return txs;
  }

  Future<void> _shift(final SolanaWalletProvider provider) async {
    try {
      final Pubkey? wallet = provider.connectedAccount?.toPubkey();
      if (wallet == null) throw const _BOQShiftException('Wallet not connected.');
      _wallet = wallet;

      final Pubkey shiftPubkey = BOQShiftProgram.findShift(wallet).pubkey;
      final BOQShift? shift = await _getShift(provider.connection, pubkey: shiftPubkey);
      if (shift == null) {
        _createAccountConfirmation = Completer.sync();
        state = _BOQShiftState.createAccount;
        await _createAccountConfirmation?.future;
      }

      state = _BOQShiftState.mine;
      
      final List<Pubkey> tokens = [];
      final List<Pubkey> employees = [];
      final Map<String, BOQMiner> miners = BOQMinersProvider.instance.value ?? const {};
      final Iterable<String> mints = miners.keys;
      for (final String mint in mints) {
        final Pubkey nftMint = Pubkey.fromBase58(mint);
        employees.add(BOQShiftProgram.findEmployee(nftMint).pubkey);
        tokens.add(Pubkey.fromBase58(miners[mint]!.token));
      }

      final Pubkey employerPubkey = BOQShiftProgram.findEmployer().pubkey;
      final BOQEmployer? employer = await _getEmployer(provider.connection, pubkey: employerPubkey);
      if (employer == null) throw const _BOQShiftException('Account unavailable.');

      final BigInt slot = await _getSlot(provider.connection);

      final List<Pubkey> nftsAndEmployeePairs = await _getAccounts(
        provider.connection,
        slot: slot,
        employer: employer,
        employees: employees,
        tokens: tokens,
      );

      if (nftsAndEmployeePairs.isEmpty) {
        _message = 'Your miners are up to date.';
        state = _BOQShiftState.success;
      } else {
        final List<Transaction> txs = await _createTxs(
          provider.connection, 
          wallet: wallet, 
          employerPubkey: employerPubkey, 
          shiftPubkey: shiftPubkey, 
          nftsAndEmployeePairs: nftsAndEmployeePairs,
        );
        final List<List<Transaction>> txList = _chunk(txs, size: _txLimit);
        final List<Future<SignatureNotification>> notifications = [];
        for (final List<Transaction> txChunks in txList) {
          final List<String> encodedTxs = txChunks
            .map(provider.adapter.encodeTransaction)
            .toList(growable: false);
          final result = await provider.adapter.signTransactions(encodedTxs);
          final signatures = await provider.connection.sendSignedTransactions(
            result.signedPayloads, 
            eagerError: true,
          );
          notifications.addAll(signatures.map(
            (signature) => signature != null 
              ? provider.connection.confirmTransaction(signature)
              : Future.error('Unconfirmed transaction.')
            )
          );
        }
        await Future.wait(notifications, eagerError: true);
        BOQAccountProvider.instance.update(provider).ignore();
        _message = "See you tomorrow!";
        state = _BOQShiftState.success;
      }

    } catch (error) {
      print('MINING ERROR $error');
      _message = error is _BOQShiftException ? error.message : null;
      state = _BOQShiftState.error;
    }
  }

  Widget _cancelButton() => TextButton(
    onPressed: request ? null : _cancel, 
    style: TextButton.styleFrom(
      backgroundColor: BOQColors.theme.tile,
      foregroundColor: BOQColors.theme.text,
    ),
    child: const Text('Cancel'),
  );

  Widget _actionsBar(final Widget actionButton) => Row(
    children: [
      Expanded(child: _cancelButton()),
      const SizedBox(width: kItemSpacing),
      Expanded(child: actionButton),
    ],
  );

  Future<void> _createAccount() async {
    try {
      request = true;
      final Connection connection = widget.provider.connection;
      final SolanaWalletAdapter adapter = widget.provider.adapter;
      await _createShift(connection, adapter, wallet: _wallet);
      _createAccountConfirmation?.complete();
    } catch (error) {
      throw const _BOQShiftException('Account creation failed.');
    } finally {
      request = false;
    }
  }

  Widget _createAccountView() => _createView(
    title: 'Create Account', 
    onAction: _createAccount,
    actionLabel: 'Create',
    child: const Text(
      "Welcome to $kAppName. Create an account to start mining. You'll only need to do this once.",
      textAlign: TextAlign.center,
    ),
  );

  Widget _mineView() {
    final int count = BOQMinersProvider.instance.value?.length ?? 0;
    final color = Theme.of(context).textTheme.bodyMedium?.color;
    return _createView(
      title: 'Mining', 
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Preparing miner shifts.",
              style: TextStyle(fontSize: 16, color: color ?? BOQColors.theme.text),
              children: [
                if (count > _shiftsPerTx) 
                  const TextSpan(
                    text: " This may require multiple transactions. 🐳",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
              ]
            ),
          ),
          const SizedBox(
            height: kSpacing,
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _messageView(
    final String message, {
    required String title,
    required final IconData icon,
    final Color? color,
  }) => _createView(
    title: title, 
    child: Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: kSpacing,
        ),
        BOQIconBadge(
          icon: icon,
          backgroundColor: color,
        ),
      ],
    ),
  );
  
  Widget _createView({
    required final String title,
    required final Widget child,
    void Function()? onAction,
    final String? actionLabel,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0, 
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: kSpacing),
        child,

        if (onAction != null)
          Padding(
            padding: const EdgeInsets.only(top: kSpacing),
            child: _actionsBar(
              TextButton(
                onPressed: request ? null : onAction, 
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(actionLabel ?? 'Continue'),
                    if (request) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _builder(
    final BuildContext context, 
  ) {
    switch (_state) {
      case _BOQShiftState.initialize:
        return const CircularProgressIndicator();
      case _BOQShiftState.createAccount:
        return _createAccountView();
      case _BOQShiftState.mine:
        return _mineView();
      case _BOQShiftState.error:
        return _messageView(
          _message ?? 'Failed to complete shift.', 
          title: 'Error',
          icon: Icons.close_rounded,
          color: BOQColors.theme.accent2,
        );
      case _BOQShiftState.success:
        return _messageView(
          _message ?? 'See you tomorrow!', 
          title: 'Mining Complete',
          icon: Icons.check_rounded,
        );
    }
  }

  @override
  Widget build(final BuildContext context) => Card(
    color: BOQColors.theme.background,
    margin: const EdgeInsets.all(kSpacing),
    child: Padding(
      padding: const EdgeInsets.all(kSpacing),
      child: AnimatedSwitcher(
        key: ValueKey(_state),
        duration: const Duration(milliseconds: 250),
        child: _builder(context),
      ),
    ),
  );
}
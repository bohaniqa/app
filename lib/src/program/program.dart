import 'dart:convert';
import 'package:solana_borsh/borsh.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';
import 'instruction.dart';

class BOQShiftProgram extends Program {

  BOQShiftProgram._()
    : super(Pubkey.fromBase58('J1FMqW26pFkvgqezcS58DEuKgVPsMcPr7P2SugrBBbqa'));

  /// Internal singleton instance.
  static final BOQShiftProgram _instance = BOQShiftProgram._();

  /// The program id.
  static Pubkey get programId => _instance.pubkey;

  static String get mintAuthoritySeed => "mint_authority";

  static String get employerSeed => "employer";

  static String get employeeSeed => "employee";

  static String get shiftSeed => "shift";

  static ProgramAddress findMintAuthority() => Pubkey.findProgramAddress(
    [
      utf8.encode(mintAuthoritySeed),
    ], 
    programId,
  );

  static ProgramAddress findEmployer() => Pubkey.findProgramAddress(
    [
      utf8.encode(employerSeed),
    ], 
    programId,
  );

  /// Find the employee account from an NFT token's [mint] address.
  static ProgramAddress findEmployee(
    final Pubkey mint, 
  ) => Pubkey.findProgramAddress(
    [
      utf8.encode(employeeSeed),
      mint.toBytes(), 
    ], 
    programId,
  );

  static ProgramAddress findShift(
    final Pubkey owner, 
  ) => Pubkey.findProgramAddress(
    [
      utf8.encode(shiftSeed),
      owner.toBytes(),
    ], 
    programId,
  );

  static TransactionInstruction test({
    required Pubkey tokenMint, 
    required Pubkey account, 
    required Pubkey mintAuthority, 
  }) {
    final mintPDA = findMintAuthority();
    print('MINT PDA ${mintPDA.pubkey}');
    print('MINT BMP ${mintPDA.bump}');
    final List<AccountMeta> keys = [
      AccountMeta.writable(tokenMint),
      AccountMeta.writable(account),
      AccountMeta(mintPDA.pubkey),
      AccountMeta(TokenProgram.programId),
    ];
    final List<Iterable<u8>> data = [
    ];
    return _instance.createTransactionIntruction(
      BOQShiftInstruction.test, 
      keys: keys, 
      data: data,
    );
  }

  static TransactionInstruction _createPDA(
    final BOQShiftInstruction instruction, {
    required final Pubkey payer,
    required final ProgramAddress pda,
    final List<AccountMeta> metaKeys = const [],
    final Pubkey? account,
    final bool sign = true,
  }) {
    final List<AccountMeta> keys = [
      ...metaKeys,
      AccountMeta.signerAndWritable(payer),
      AccountMeta.writable(pda.pubkey),
      AccountMeta(programId, isSigner: sign),
      AccountMeta(SystemProgram.programId),
    ];
    final List<Iterable<u8>> data = [
      borsh.u8.encode(pda.bump),
      if (account != null)
        borsh.pubkey.encode(account.toBase58()),
    ];
    return _instance.createTransactionIntruction(
      instruction, 
      keys: keys, 
      data: data,
    );
  }

  static TransactionInstruction createMintAuthority({
    required final Pubkey payer,
  }) => _createPDA(
      BOQShiftInstruction.createMintAuthority,
      payer: payer, 
      pda: findMintAuthority(),
    );
  
  static TransactionInstruction initializeMintAuthority() {
    final pda = findMintAuthority();
    final List<AccountMeta> keys = [
      AccountMeta.writable(pda.pubkey),
    ];
    final List<Iterable<u8>> data = [
      borsh.u8.encode(pda.bump),
    ];
    return _instance.createTransactionIntruction(
      BOQShiftInstruction.initializeMintAuthority, 
      keys: keys, 
      data: data,
    );
  }

  static TransactionInstruction createEmployee({
    required final Pubkey payer,
    required final ProgramAddress employee,
    required final Pubkey nftMint,
    required final Pubkey nftMetadata,
  }) => _createPDA(
      BOQShiftInstruction.createEmployee, 
      payer: payer, 
      pda: employee,
      metaKeys: [
        AccountMeta.writable(findEmployer().pubkey),
        AccountMeta(nftMint),
        AccountMeta(nftMetadata),
      ],
      sign: false,
    );

  static TransactionInstruction initializeEmployee({
    required final ProgramAddress employee,
    required final Pubkey nftMint,
  }) {
    final List<AccountMeta> keys = [
      AccountMeta.writable(employee.pubkey),
    ];
    final List<Iterable<u8>> data = [
      borsh.u8.encode(employee.bump),
      borsh.pubkey.encode(nftMint.toBase58()),
    ];
    return _instance.createTransactionIntruction(
      BOQShiftInstruction.initializeEmployee, 
      keys: keys, 
      data: data,
    );
  }

  static TransactionInstruction createShift({
    required final Pubkey owner,
    required final ProgramAddress shift,
  }) => _createPDA(
      BOQShiftInstruction.createShift, 
      payer: owner, 
      pda: shift,
      sign: false,
    );

  static TransactionInstruction initializeShift({
    required final Pubkey owner,
    required final ProgramAddress shift,
    required final BigInt slot,
  }) {
    final List<AccountMeta> keys = [
      AccountMeta.writable(shift.pubkey),
    ];
    final List<Iterable<u8>> data = [
      borsh.u8.encode(shift.bump),
      borsh.u64.encode(slot),
      borsh.pubkey.encode(owner.toBase58()),
    ];
    return _instance.createTransactionIntruction(
      BOQShiftInstruction.initializeShift, 
      keys: keys, 
      data: data,
    );
  }

  static TransactionInstruction shift({
    required final Pubkey mintAuthority,
    required final Pubkey employer,
    required final Pubkey shift,
    required final Pubkey tokenMint,
    required final Pubkey ataAccount,
    required final List<Pubkey> nftsAndEmployees,
  }) {
    check(nftsAndEmployees.length < 256, '[nftsAndEmployees] length overflows u8.');
    check(nftsAndEmployees.length % 2 == 0, 'NFT and employee account pairs.');
    final int numberOfEmployees = nftsAndEmployees.length ~/ 2;
    final List<AccountMeta> keys = [
      AccountMeta(mintAuthority),
      AccountMeta(employer),
      AccountMeta.writable(shift),
      AccountMeta.writable(tokenMint),
      AccountMeta.writable(ataAccount),
      AccountMeta(TokenProgram.programId),
      for (int i = 0; i < numberOfEmployees; ++i) ...[
        AccountMeta(nftsAndEmployees[i*2]),
        AccountMeta.writable(nftsAndEmployees[(i*2)+1]),
      ],
    ];
    final List<Iterable<u8>> data = [
      borsh.u8.encode(numberOfEmployees)
    ];
    return _instance.createTransactionIntruction(
      BOQShiftInstruction.shift, 
      keys: keys, 
      data: data,
    );
  }
}
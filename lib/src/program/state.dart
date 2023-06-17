
import 'dart:convert';
import 'package:solana_borsh/borsh.dart';
import 'package:solana_borsh/codecs.dart';
import 'package:solana_borsh/models.dart';
import 'package:solana_borsh/types.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

enum BOQAccountType {
  uninitialized,
  mintAuthority,
  employer,
  employee,
  shift,
}

class BOQMintAuthority extends BorshObject {

  const BOQMintAuthority({
    required this.account_type,
    required this.bump,
  });

  final BOQAccountType account_type;
  final int bump;

  static BorshStructCodec codec = borsh.struct({
    'account_type': borsh.enumeration(BOQAccountType.values),
    'bump': borsh.u8,
  });

  @override
  BorshSchema get borshSchema => codec.schema;

  factory BOQMintAuthority.fromBase64(final String encoded) {
    final Map<String, dynamic> json = codec.decode(base64.decode(encoded));
    return BOQMintAuthority.fromJson(json);
  }

  static BOQMintAuthority? tryFromBase64(final String? encoded) 
    => encoded != null ? BOQMintAuthority.fromBase64(encoded) : null;

  factory BOQMintAuthority.fromJson(final Map<String, dynamic> json) => BOQMintAuthority(
    account_type: json['account_type'], 
    bump: json['bump'], 
  );

  @override
  Map<String, dynamic> toJson() => {
    'account_type': account_type,
    'bump': bump,
  };
}

class BOQEmployer extends BorshObject {

  const BOQEmployer({
    required this.account_type,
    required this.bump,
    required this.is_active,

    required this.employees,
    required this.max_employees,

    required this.start_slot,
    required this.end_slot,
    required this.slots_per_shift,
    required this.base_rate_per_slot,
    required this.inflation_rate_per_slot,

    required this.token_mint,
    required this.collection_mint,
  });

  final BOQAccountType account_type;
  final int bump;
  final bool is_active;

  final int employees;
  final int max_employees;

  final BigInt start_slot;
  final BigInt end_slot;
  final BigInt slots_per_shift;
  final BigInt base_rate_per_slot;
  final BigInt inflation_rate_per_slot;

  final Pubkey token_mint;
  final Pubkey collection_mint;

  static BorshStructCodec codec = borsh.struct({
    'account_type': borsh.u8,
    'bump': borsh.u8,
    'is_active': borsh.boolean,
    'employees': borsh.u16,
    'max_employees': borsh.u16,
    'start_slot': borsh.u64,
    'end_slot': borsh.u64,
    'slots_per_shift': borsh.u64,
    'base_rate_per_slot': borsh.u64,
    'inflation_rate_per_slot': borsh.u64,
    'token_mint': borsh.pubkey,
    'collection_mint': borsh.pubkey,
  });

  @override
  BorshSchema get borshSchema => codec.schema;
  
  BigInt slot(final BigInt slot) {
    if (slot < start_slot) {
      return BigInt.zero;
    } else if (slot > end_slot) {
      return end_slot - start_slot;
    } else {
      return slot - start_slot;
    }
  }

  double shift(final BigInt slot) {
    return this.slot(slot) / slots_per_shift;
  }

  factory BOQEmployer.fromBase64(final String encoded) {
    final Map<String, dynamic> json = codec.decode(base64.decode(encoded));
    return BOQEmployer.fromJson(json);
  }
  static BOQEmployer? tryFromBase64(final String? encoded) 
    => encoded != null ? BOQEmployer.fromBase64(encoded) : null;

  static _bigInt(final dynamic value)
    => value is String ? BigInt.parse(value) : value;

  factory BOQEmployer.fromJson(final Map<String, dynamic> json) => BOQEmployer(
    account_type: BOQAccountType.values[json['account_type']], 
    bump: json['bump'], 
    is_active: json['is_active'], 
    employees: json['employees'], 
    max_employees: json['max_employees'], 
    start_slot: _bigInt(json['start_slot']), 
    end_slot: _bigInt(json['end_slot']), 
    slots_per_shift: _bigInt(json['slots_per_shift']), 
    base_rate_per_slot: _bigInt(json['base_rate_per_slot']), 
    inflation_rate_per_slot: _bigInt(json['inflation_rate_per_slot']), 
    token_mint: Pubkey.fromBase58(json['token_mint']), 
    collection_mint: Pubkey.fromBase58(json['collection_mint']), 
  );

  @override
  Map<String, dynamic> toJson() => {
    'account_type': account_type.index,
    'bump': bump,
    'is_active': is_active,
    'employees': employees,
    'max_employees': max_employees,
    'start_slot': start_slot,
    'end_slot': end_slot,
    'slots_per_shift': slots_per_shift,
    'base_rate_per_slot': base_rate_per_slot,
    'inflation_rate_per_slot': inflation_rate_per_slot,
    'token_mint': token_mint.toBase58(),
    'collection_mint': collection_mint.toBase58(),
  };
}

class BOQEmployee extends BorshObject {

  const BOQEmployee({
    required this.account_type,
    required this.bump,
    required this.last_slot,
    required this.total_slots,
    required this.nft_mint,
  });

  final BOQAccountType account_type;
  final int bump;
  final BigInt last_slot;
  final BigInt total_slots;
  final Pubkey nft_mint;

  static BorshStructCodec codec = borsh.struct({
    'account_type': borsh.enumeration(BOQAccountType.values),
    'bump': borsh.u8,
    'last_slot': borsh.u64,
    'total_slots': borsh.u64,
    'nft_mint': borsh.pubkey,
  });

  @override
  BorshSchema get borshSchema => codec.schema;

  factory BOQEmployee.fromBase64(final String encoded) {
    final Map<String, dynamic> json = codec.decode(base64.decode(encoded));
    return BOQEmployee.fromJson(json);
  }

  static BOQEmployee? tryFromBase64(final String? encoded) 
    => encoded != null ? BOQEmployee.fromBase64(encoded) : null;

  factory BOQEmployee.fromJson(final Map<String, dynamic> json) => BOQEmployee(
    account_type: json['account_type'], 
    bump: json['bump'], 
    last_slot: json['last_slot'], 
    total_slots: json['total_slots'], 
    nft_mint: Pubkey.fromBase58(json['nft_mint']), 
  );

  @override
  Map<String, dynamic> toJson() => {
    'account_type': account_type,
    'bump': bump,
    'last_slot': last_slot,
    'total_slots': total_slots,
    'nft_mint': nft_mint.toBase58(),
  };
}


class BOQShift extends BorshObject {

  const BOQShift({
    required this.account_type,
    required this.bump,
    required this.slot,
    required this.total_slots,
    required this.total_rewards,
    required this.owner,
  });

  final BOQAccountType account_type;
  final int bump;
  final BigInt slot;
  final BigInt total_slots;
  final BigInt total_rewards;
  final Pubkey owner;

  ProgramAddress get lookupTable => AddressLookupTableProgram.findAddressLookupTable(owner, slot);

  static _bigInt(final dynamic value)
    => value is String ? BigInt.parse(value) : value;

  static BorshStructCodec codec = borsh.struct({
    'account_type': borsh.u8,
    'bump': borsh.u8,
    'slot': borsh.u64,
    'total_slots': borsh.u64,
    'total_rewards': borsh.u64,
    'owner': borsh.pubkey,
  });

  @override
  BorshSchema get borshSchema => codec.schema;

  BigInt totalShifts(final BOQEmployer employer) {
    return total_slots ~/ employer.slots_per_shift;
  }

  factory BOQShift.fromBase64(final String encoded) {
    final Map<String, dynamic> json = codec.decode(base64.decode(encoded));
    print('SHIFT ACCOUNT ${json}');
    return BOQShift.fromJson(json);
  }

  static BOQShift? tryFromBase64(final String? encoded) 
    => encoded != null ? BOQShift.fromBase64(encoded) : null;

  factory BOQShift.fromJson(final Map<String, dynamic> json) => BOQShift(
    account_type: BOQAccountType.values[json['account_type']], 
    bump: json['bump'], 
    slot: _bigInt(json['slot']), 
    total_slots: _bigInt(json['total_slots']), 
    total_rewards: _bigInt(json['total_rewards']), 
    owner: Pubkey.fromBase58(json['owner']),  
  );

  @override
  Map<String, dynamic> toJson() => {
    'account_type': account_type.index,
    'bump': bump, 
    'slot': slot, 
    'total_slots': total_slots, 
    'total_rewards': total_rewards, 
    'owner': owner.toBase58(), 
  };
}
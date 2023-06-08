import 'package:boq/src/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

class BOQSettings {

  const BOQSettings({
    required this.brightness,
  });

  final Brightness brightness;

  factory BOQSettings.fromJson(final Map<String, dynamic> json) => BOQSettings(
    brightness: Brightness.values.byName(json['brightness'] ?? Brightness.light.name),
  );
  
  Map<String, dynamic> toJson() => {
    'brightness': brightness.name,
  };
}

class BOQSettingsProvider extends BOQProvider<BOQSettings> {

  BOQSettingsProvider._();

  static BOQSettingsProvider instance = BOQSettingsProvider._();

  @override
  String get key => 'boq.settings';

  @override
  Future<BOQSettings>? query(final SolanaWalletProvider provider) 
    => Future.value(value ??= load());

  @override
  BOQSettings? read(final SharedPreferences prefs) {
    final Map<String, dynamic>? data = readJson(prefs);
    return data != null ? BOQSettings.fromJson(data) : null;
  }

  @override
  Future<bool> write(final SharedPreferences prefs, final BOQSettings? data) 
    => writeJson(prefs, data?.toJson());
}
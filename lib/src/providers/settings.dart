import 'package:boq/src/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

class BOQSettings {

  const BOQSettings({
    required this.brightness,
    required this.minerNotice,
  });

  final Brightness brightness;

  final bool minerNotice;

  BOQSettings copyWith({
    final Brightness? brightness,
    final bool? minerNotice,
  }) => BOQSettings(
    brightness: brightness ?? this.brightness, 
    minerNotice: minerNotice ?? this.minerNotice,
  );

  factory BOQSettings.fromJson(final Map<String, dynamic> json) => BOQSettings(
    brightness: Brightness.values.byName(json['brightness'] ?? Brightness.dark.name),
    minerNotice: json['minerNotice'] ?? false,
  );
  
  Map<String, dynamic> toJson() => {
    'brightness': brightness.name,
    'minerNotice': minerNotice
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

  void set({
    final Brightness? brightness,
    final bool? minerNotice,
  }) {
    final BOQSettings? settings = instance.value;
    if (settings != null) {
      instance.value = settings.copyWith(
        brightness: brightness,
        minerNotice: minerNotice,
      );
    } else {
      instance.value = BOQSettings(
        brightness: brightness ?? Brightness.dark, 
        minerNotice: minerNotice ?? false
      );
    }
  }
}
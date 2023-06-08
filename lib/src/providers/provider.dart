import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

abstract class BOQProvider<T> extends ValueNotifier<T?> {

  BOQProvider([final T? value]): super(value);

  String get key;

  bool get updating => _updating;
  bool _updating = false;

  @override
  set value(final T? newValue) {
    if (value != newValue) {
      super.value = newValue;
      save().ignore();
    }
  }

  static late final SharedPreferences _instance;

  static Future<void> initialize() async => _instance = await SharedPreferences.getInstance();

  T? read(final SharedPreferences prefs);

  Map<String, dynamic>? readJson(
    final SharedPreferences prefs, {
    final Object? Function(Object?, Object?)? reviver,
  }) {
    final String? data = prefs.getString(key);
    return data != null ? json.decode(data, reviver: reviver) : null;
  }

  Future<bool> write(final SharedPreferences prefs, final T? data);

  Future<bool> writeJson(
    final SharedPreferences prefs, 
    final Map<String, dynamic>? data, 
  ) => data != null ? prefs.setString(key, json.encode(data)) : prefs.remove(key);

  T? load() {
    final T? value = this.value;
    if (value != null) return value;
    return this.value = read(_instance);
  }

  Future<T>? query(final SolanaWalletProvider provider);

  Future<bool> delete() => _instance.remove(key);

  Future<bool> save() {
    final T? data = value;
    return data != null ? write(_instance, data) : delete();
  }

  Future<void> update(final SolanaWalletProvider provider) async {
    if (_updating) return;
    try {
      _updating = true;
      print('UPDATING ${runtimeType}...');
      final T? data = await query(provider);
      this.value = data;
      save().ignore();
    } catch (e) {
      print('ERROR ${runtimeType} $e');
      notifyListeners();
    } finally {
      _updating = false;
    }
  }
}
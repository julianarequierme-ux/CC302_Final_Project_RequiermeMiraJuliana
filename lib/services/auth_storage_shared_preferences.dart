import 'package:shared_preferences/shared_preferences.dart';

import 'auth_storage.dart';

AuthStorage createAuthStorage() => _SharedPreferencesAuthStorage();

class _SharedPreferencesAuthStorage implements AuthStorage {
  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  @override
  Future<String?> getString(String key) async =>
      (await _preferences).getString(key);

  @override
  Future<bool> setString(String key, String value) async =>
      (await _preferences).setString(key, value);

  @override
  Future<bool?> getBool(String key) async => (await _preferences).getBool(key);

  @override
  Future<bool> setBool(String key, bool value) async =>
      (await _preferences).setBool(key, value);

  @override
  Future<bool> remove(String key) async => (await _preferences).remove(key);

  @override
  Future<bool> containsKey(String key) async =>
      (await _preferences).containsKey(key);
}

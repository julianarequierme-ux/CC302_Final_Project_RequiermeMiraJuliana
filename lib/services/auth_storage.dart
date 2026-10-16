import 'auth_storage_shared_preferences.dart'
    if (dart.library.js_interop) 'auth_storage_web.dart' as platform;

/// Small key-value store used for local accounts on every supported platform.
abstract interface class AuthStorage {
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<bool> setBool(String key, bool value);
  Future<bool> remove(String key);
  Future<bool> containsKey(String key);
}

class AuthStorageException implements Exception {
  final String message;

  const AuthStorageException(this.message);

  @override
  String toString() => message;
}

AuthStorage createAuthStorage() => platform.createAuthStorage();

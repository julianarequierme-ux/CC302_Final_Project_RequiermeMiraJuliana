import 'auth_storage.dart';
import 'package:web/web.dart' as web;

AuthStorage createAuthStorage() => _BrowserLocalStorage();

class _BrowserLocalStorage implements AuthStorage {
  static const _prefix = 'skyseabooking.';

  String _key(String key) => '$_prefix$key';

  T _accessStorage<T>(T Function() operation) {
    try {
      return operation();
    } catch (error) {
      if (error is web.DOMException) {
        throw AuthStorageException(
          'Browser storage error: ${error.message}',
        );
      }
      rethrow;
    }
  }

  @override
  Future<String?> getString(String key) async =>
      _accessStorage(() => web.window.localStorage.getItem(_key(key)));

  @override
  Future<bool> setString(String key, String value) async {
    return _accessStorage(() {
      web.window.localStorage.setItem(_key(key), value);
      return true;
    });
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = await getString(key);
    return value == null ? null : value == 'true';
  }

  @override
  Future<bool> setBool(String key, bool value) => setString(key, '$value');

  @override
  Future<bool> remove(String key) async {
    return _accessStorage(() {
      web.window.localStorage.removeItem(_key(key));
      return true;
    });
  }

  @override
  Future<bool> containsKey(String key) async {
    return _accessStorage(
      () => web.window.localStorage.getItem(_key(key)) != null,
    );
  }
}

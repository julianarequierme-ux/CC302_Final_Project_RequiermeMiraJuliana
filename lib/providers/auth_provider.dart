import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';

/// Exposes saved account/session state and authentication actions to the UI.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service}) : _service = service ?? AuthService() {
    initialize();
  }

  final AuthService _service;
  User? _currentUser;
  bool _loading = true;
  bool _initialized = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get loading => _loading;
  bool get initialized => _initialized;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _service.getCurrentUser();
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } on PlatformException catch (error) {
      _errorMessage = 'Local storage error: ${error.message ?? error.code}';
    } on MissingPluginException catch (error) {
      _errorMessage = 'Local storage is unavailable: ${error.message ?? error}';
    } on AuthStorageException catch (error) {
      _errorMessage = error.message;
    } finally {
      _loading = false;
      _initialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    return _perform(() async {
      _currentUser = await _service.login(email, password);
    });
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required DateTime? dateOfBirth,
    required String nationality,
    required String password,
    String? photoPath,
  }) {
    return _perform(() async {
      _currentUser = await _service.register(
        fullName: fullName,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
        nationality: nationality,
        password: password,
        photoPath: photoPath,
      );
    });
  }

  Future<bool> updateUser(User user) {
    return _perform(() async {
      _currentUser = await _service.updateUser(user);
    });
  }

  Future<bool> changePassword(String oldPassword, String newPassword) =>
      _perform(() => _service.changePassword(oldPassword, newPassword));

  Future<bool> logout() async {
    final success = await _perform(_service.logout);
    if (success) _currentUser = null;
    notifyListeners();
    return success;
  }

  Future<bool> deleteAccount() async {
    final success = await _perform(_service.deleteAccount);
    if (success) _currentUser = null;
    notifyListeners();
    return success;
  }

  Future<bool> _perform(Future<void> Function() action) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } on PlatformException catch (error) {
      _errorMessage = 'Local storage error: ${error.message ?? error.code}';
      return false;
    } on MissingPluginException catch (error) {
      _errorMessage = 'Local storage is unavailable: ${error.message ?? error}';
      return false;
    } on AuthStorageException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

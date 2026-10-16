import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/user.dart';
import 'auth_storage.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Local-only account storage. Passwords are never stored in plain text.
class AuthService {
  static const _usersKey = 'skysea_users';
  static const _sessionKey = 'skysea_session_user_id';
  static const _notificationsKey = 'skysea_notifications_enabled';

  Future<List<User>> _readUsers(AuthStorage storage) async {
    final encoded = await storage.getString(_usersKey);
    if (encoded == null || encoded.isEmpty) return [];
    try {
      final records = jsonDecode(encoded) as List<dynamic>;
      return records
          .map((record) => User.fromJson(record as Map<String, dynamic>))
          .toList();
    } on FormatException catch (error) {
      throw AuthException('Saved account data could not be read: $error');
    } on TypeError catch (error) {
      throw AuthException('Saved account data is invalid: $error');
    }
  }

  Future<void> _writeUsers(AuthStorage storage, List<User> users) async {
    final saved = await storage.setString(
      _usersKey,
      jsonEncode(users.map((user) => user.toJson()).toList()),
    );
    if (!saved) throw const AuthException('Could not save account data.');
  }

  String _passwordHash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<User> register({
    required String fullName,
    required String email,
    required String phone,
    required DateTime? dateOfBirth,
    required String nationality,
    required String password,
    String? photoPath,
  }) async {
    final storage = createAuthStorage();
    final users = await _readUsers(storage);
    final normalizedEmail = email.trim().toLowerCase();
    if (users.any((user) => user.email.toLowerCase() == normalizedEmail)) {
      throw const AuthException('An account with this email already exists.');
    }

    final user = User(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      dateOfBirth: dateOfBirth,
      nationality: nationality.trim(),
      passwordHash: _passwordHash(password),
      photoPath: photoPath,
      createdAt: DateTime.now(),
    );
    users.add(user);
    await _writeUsers(storage, users);
    final savedSession = await storage.setString(_sessionKey, user.id);
    if (!savedSession) {
      throw const AuthException('Could not save login session.');
    }
    return user;
  }

  Future<User> login(String email, String password) async {
    final storage = createAuthStorage();
    final users = await _readUsers(storage);
    final normalizedEmail = email.trim().toLowerCase();
    final index = users.indexWhere(
      (user) => user.email.toLowerCase() == normalizedEmail,
    );
    if (index < 0) throw const AuthException('Account not found.');
    final user = users[index];
    if (user.passwordHash != _passwordHash(password)) {
      throw const AuthException('Wrong password.');
    }
    final savedSession = await storage.setString(_sessionKey, user.id);
    if (!savedSession) {
      throw const AuthException('Could not save login session.');
    }
    return user;
  }

  Future<void> logout() async {
    final storage = createAuthStorage();
    final removed = await storage.remove(_sessionKey);
    if (!removed && await storage.containsKey(_sessionKey)) {
      throw const AuthException('Could not end the login session.');
    }
  }

  Future<User?> getCurrentUser() async {
    final storage = createAuthStorage();
    final id = await storage.getString(_sessionKey);
    if (id == null) return null;
    final users = await _readUsers(storage);
    final index = users.indexWhere((user) => user.id == id);
    if (index < 0) {
      await storage.remove(_sessionKey);
      return null;
    }
    return users[index];
  }

  Future<User> updateUser(User updatedUser) async {
    final storage = createAuthStorage();
    final users = await _readUsers(storage);
    final index = users.indexWhere((user) => user.id == updatedUser.id);
    if (index < 0) throw const AuthException('Account not found.');
    final duplicateEmail = users.any(
      (user) =>
          user.id != updatedUser.id &&
          user.email.toLowerCase() == updatedUser.email.trim().toLowerCase(),
    );
    if (duplicateEmail) {
      throw const AuthException('An account with this email already exists.');
    }
    final normalized = updatedUser.copyWith(
      email: updatedUser.email.trim().toLowerCase(),
    );
    users[index] = normalized;
    await _writeUsers(storage, users);
    return normalized;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final storage = createAuthStorage();
    final id = await storage.getString(_sessionKey);
    if (id == null) throw const AuthException('Please log in again.');
    final users = await _readUsers(storage);
    final index = users.indexWhere((user) => user.id == id);
    if (index < 0) throw const AuthException('Account not found.');
    if (users[index].passwordHash != _passwordHash(oldPassword)) {
      throw const AuthException('Current password is incorrect.');
    }
    users[index] = users[index].copyWith(
      passwordHash: _passwordHash(newPassword),
    );
    await _writeUsers(storage, users);
  }

  Future<void> deleteAccount() async {
    final storage = createAuthStorage();
    final id = await storage.getString(_sessionKey);
    if (id == null) throw const AuthException('Please log in again.');
    final users = await _readUsers(storage);
    users.removeWhere((user) => user.id == id);
    await _writeUsers(storage, users);
    await storage.remove(_sessionKey);
  }

  Future<bool> getNotificationsEnabled() async {
    final storage = createAuthStorage();
    return await storage.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final storage = createAuthStorage();
    final saved = await storage.setBool(_notificationsKey, enabled);
    if (!saved) {
      throw const AuthException('Could not save notification setting.');
    }
  }
}

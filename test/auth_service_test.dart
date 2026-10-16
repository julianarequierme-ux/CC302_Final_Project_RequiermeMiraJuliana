import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyseabooking/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthService auth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = AuthService();
  });

  test('register hashes password and saves the current session', () async {
    final user = await auth.register(
      fullName: 'Juliana Requierme',
      email: 'JULIANA@example.com',
      phone: '+63 912 345 6789',
      dateOfBirth: DateTime(2006, 6, 14),
      nationality: 'Filipino',
      password: 'strongpass',
    );

    expect(user.email, 'juliana@example.com');
    expect(user.passwordHash, isNot('strongpass'));
    expect((await auth.getCurrentUser())?.id, user.id);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('skysea_session_user_id'), user.id);
    expect(
        preferences.getString('skysea_users'), isNot(contains('strongpass')));
  });

  test('duplicate emails and invalid login credentials are rejected', () async {
    await auth.register(
      fullName: 'Juliana Requierme',
      email: 'juliana@example.com',
      phone: '09123456789',
      dateOfBirth: null,
      nationality: 'Filipino',
      password: 'strongpass',
    );
    await auth.logout();

    await expectLater(
      auth.register(
        fullName: 'Another User',
        email: 'JULIANA@example.com',
        phone: '09123456789',
        dateOfBirth: null,
        nationality: 'Filipino',
        password: 'strongpass',
      ),
      throwsA(isA<AuthException>()),
    );
    await expectLater(
      auth.login('missing@example.com', 'strongpass'),
      throwsA(isA<AuthException>()),
    );
    await expectLater(
      auth.login('juliana@example.com', 'wrongpass'),
      throwsA(isA<AuthException>()),
    );
  });

  test('change password, update user, and delete account work locally',
      () async {
    final user = await auth.register(
      fullName: 'Juliana Requierme',
      email: 'juliana@example.com',
      phone: '09123456789',
      dateOfBirth: null,
      nationality: 'Filipino',
      password: 'strongpass',
    );

    final updated = await auth.updateUser(
      user.copyWith(fullName: 'Juliana Mira Requierme'),
    );
    expect(updated.fullName, 'Juliana Mira Requierme');

    await auth.changePassword('strongpass', 'newpass123');
    await auth.logout();
    final loggedIn = await auth.login('juliana@example.com', 'newpass123');
    expect(loggedIn.fullName, 'Juliana Mira Requierme');

    await auth.deleteAccount();
    expect(await auth.getCurrentUser(), isNull);
    await expectLater(
      auth.login('juliana@example.com', 'newpass123'),
      throwsA(isA<AuthException>()),
    );
  });
}

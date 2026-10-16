import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyseabooking/main.dart';
import 'package:skyseabooking/screens/main_shell.dart';
import 'package:skyseabooking/services/auth_service.dart';
import 'package:skyseabooking/widgets/common_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('user can create an account and sign in again', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SkySeaBookingApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test Traveler');
    await tester.enterText(fields.at(1), 'traveler@example.com');
    await tester.enterText(fields.at(2), '+63 912 345 6789');
    await tester.enterText(fields.at(3), 'Filipino');
    await tester.enterText(fields.at(4), 'testpass123');
    await tester.enterText(fields.at(5), 'testpass123');

    await tester.tap(find.text('Date of Birth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final createAccountButton = find.byType(PrimaryButton);
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await AuthService().logout();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const SkySeaBookingApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back!'), findsOneWidget);

    await tester.enterText(
        find.byType(TextFormField).at(0), 'TRAVELER@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'testpass123');
    final loginButton = find.byType(PrimaryButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

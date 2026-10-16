import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyseabooking/data/mock_data.dart';
import 'package:skyseabooking/main.dart';
import 'package:skyseabooking/services/auth_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mock data contains all ten requested destinations', () {
    expect(mockDestinations, hasLength(10));
  });

  testWidgets('home can browse, filter, and open destination details',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AuthService().register(
      fullName: 'Juliana Mira Requierme',
      email: 'juliana@example.com',
      phone: '+63 912 345 6789',
      dateOfBirth: DateTime(2006, 6, 14),
      nationality: 'Filipino',
      password: 'testing123',
    );
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SkySeaBookingApp());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.drag(find.byType(ListView).first, const Offset(0, -780));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Popular Destinations'));
    await tester.tap(find.text('See All').first);
    await tester.pumpAndSettle();

    expect(find.text('All Destinations'), findsOneWidget);
    expect(find.text('Cebu'), findsOneWidget);

    await tester.tap(find.text('Beaches'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Boracay'), findsOneWidget);
    expect(find.text('Baguio'), findsNothing);

    await tester.tap(find.text('Boracay'));
    await tester.pumpAndSettle();
    expect(find.text('Explore the Philippines'), findsOneWidget);
    expect(find.text('Famous for'), findsOneWidget);
    expect(find.text('White Beach'), findsOneWidget);
    expect(find.text('Book Now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

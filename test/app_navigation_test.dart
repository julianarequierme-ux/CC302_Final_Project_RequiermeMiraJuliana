import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyseabooking/services/auth_service.dart';
import 'package:skyseabooking/main.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await AuthService().register(
    fullName: 'Juliana Mira Requierme',
    email: 'juliana@email.com',
    phone: '+63 912 345 6789',
    dateOfBirth: DateTime(2006, 6, 14),
    nationality: 'Filipino',
    password: 'testing123',
  );

  for (final size in const [Size(320, 720), Size(430, 932)]) {
    testWidgets('all tabs render without layout exceptions at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SkySeaBookingApp());
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      for (final tab in [
        'Search',
        'Bookings',
        'Notifications',
        'Profile',
        'Home'
      ]) {
        await tester.tap(find.text(tab).last);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: '$tab tab at $size');
      }
    });
  }
}

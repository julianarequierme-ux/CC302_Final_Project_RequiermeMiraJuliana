import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'state/booking_store.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkySeaBookingApp());
}

class SkySeaBookingApp extends StatelessWidget {
  const SkySeaBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // App-wide account and booking state is provided to all screens.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider<BookingStore>.value(
            value: BookingStore.instance),
      ],
      child: MaterialApp(
        title: 'SkySeaBooking',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const _AuthGate(),
      ),
    );
  }
}

/// Routes to the splash, saved session, or login without a backend.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.initialized) return const SplashScreen();
    if (auth.isLoggedIn) return const MainScreen();
    return const LoginScreen();
  }
}

import 'package:flutter/material.dart';

import '../widgets/booking_widgets.dart';
import 'bookings_screen.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    // IndexedStack preserves each tab's current form and scroll position.
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSearch: () => _go(1), onNotifications: () => _go(3)),
          SearchScreen(onBack: () => _go(0)),
          const BookingsScreen(),
          const NotificationsScreen(),
          ProfileScreen(
            onBookings: () => _go(2),
            onSettings: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _index,
        onTap: _go,
      ),
    );
  }
}

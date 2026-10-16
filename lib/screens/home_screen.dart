import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/booking_widgets.dart';
import '../widgets/common_widgets.dart' show AvatarPicker, SectionHeader;
import 'destination_detail_screen.dart';
import 'destinations_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onNotifications;

  const HomeScreen({
    super.key,
    required this.onSearch,
    required this.onNotifications,
  });

  void _openSearch(BuildContext context, SearchQuery query) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final firstName =
        user?.fullName.trim().split(RegExp(r'\s+')).first ?? 'Traveler';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    // The gradient hero and floating logo/greeting introduce the booking app.
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 294,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/home_hero_poster.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const DecoratedBox(
                    decoration: BoxDecoration(gradient: appGradient),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66215FC4), Color(0xEE123A7A)],
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(19, 11, 12, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand row, tagline, and notification shortcut.
                        Row(
                          children: [
                            const Icon(Icons.flight_takeoff,
                                color: Colors.white, size: 25),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SkySeaBooking',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700)),
                                  Text('Fly Higher • Sail Further',
                                      style: TextStyle(
                                          color: Color(0xFFDDEBFF),
                                          fontSize: 10)),
                                ],
                              ),
                            ),
                            if (user != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: AvatarPicker(
                                  photoPath: user.photoPath,
                                  initials: userInitials(user.fullName),
                                  radius: 16,
                                ),
                              ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  tooltip: 'Notifications',
                                  onPressed: onNotifications,
                                  icon: const Icon(Icons.notifications_none,
                                      color: Colors.white),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 9,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF5A5F),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '$greeting, $firstName! ✈',
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Your next adventure is just a booking away!',
                          style:
                              TextStyle(color: Color(0xFFEAF3FF), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // The card visually overlaps the header while keeping list scrolling simple.
          Transform.translate(
            offset: const Offset(0, -22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchCard(
                onSearch: (query) => _openSearch(context, query),
              ),
            ),
          ),
          // Popular Philippine destinations shown as horizontally scrollable cards.
          SectionHeader(
            title: 'Popular Destinations',
            actionLabel: 'See All',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllDestinationsScreen()),
            ),
          ),
          SizedBox(
            height: 204,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: mockDestinations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 11),
              itemBuilder: (_, index) => DestinationCard(
                destination: mockDestinations[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DestinationDetailsScreen(
                      destination: mockDestinations[index],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Seasonal deals banner with a resilient remote-image fallback.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 174,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?w=1000',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const DecoratedBox(
                          decoration: BoxDecoration(gradient: appGradient)),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xD900244A), Color(0x331E5BC6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Special Deals',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          const Text(
                            'Up to 50% OFF on selected flights and sea boat trips!',
                            maxLines: 2,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: onSearch,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Colors.white.withValues(alpha: .2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 6),
                            ),
                            child: const Text('Book Now →'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

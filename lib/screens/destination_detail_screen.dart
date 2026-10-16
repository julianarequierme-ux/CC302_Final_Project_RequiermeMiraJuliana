import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../models/destination.dart';
import '../models/destination_weather.dart';
import '../services/destination_weather_service.dart';
import '../utils/format.dart';
import '../utils/theme.dart';
import 'search_screen.dart';

/// Destination overview with local highlights and a route-to-search action.
class DestinationDetailsScreen extends StatefulWidget {
  final Destination destination;

  const DestinationDetailsScreen({super.key, required this.destination});

  @override
  State<DestinationDetailsScreen> createState() =>
      _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  final _weatherService = DestinationWeatherService();
  late Future<DestinationWeather> _weather;

  @override
  void initState() {
    super.initState();
    _weather = _weatherService.getCurrentWeather(widget.destination);
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  void _retryWeather() {
    setState(() {
      _weather = _weatherService.getCurrentWeather(widget.destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // A photo-led app bar keeps the selected destination in focus.
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(destination.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    destination.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const DecoratedBox(
                      decoration: BoxDecoration(gradient: appGradient),
                      child: Icon(Icons.landscape_outlined,
                          size: 60, color: Colors.white),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0xAA000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(destination.province,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 13)),
                      ),
                      const Icon(Icons.star_rounded, color: Color(0xFFFFB323)),
                      const SizedBox(width: 3),
                      Text(destination.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Explore the Philippines',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 7),
                  Text(
                    'Discover the natural beauty of ${destination.name}, ${destination.province}. '
                    'Plan an unforgettable getaway and explore the destinations and local experiences nearby.',
                    style: const TextStyle(
                        color: AppColors.muted, height: 1.5, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  _weatherSection(),
                  const SizedBox(height: 22),
                  const Text('Famous for',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: destination.famousFor
                        .split(', ')
                        .map(
                          (highlight) => Chip(
                            avatar: const Icon(Icons.check_circle_outline,
                                color: AppColors.primary, size: 17),
                            label: Text(highlight),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE4EBF6)),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Trips starting from',
                                style: TextStyle(color: AppColors.muted)),
                          ),
                          Text(peso(destination.price),
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: () {
                        final type = destination.travelType == 'Sea Boat'
                            ? 'Sea Boats'
                            : 'Flights';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SearchScreen(
                              initialQuery: SearchQuery(
                                type: type,
                                from:
                                    type == 'Flights' ? 'Manila (MNL)' : 'Cebu',
                                to: destination.name,
                                date: DateTime(2025, 10, 15),
                                returnDate: DateTime(2025, 10, 17),
                                passengers: 1,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Book Now'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherSection() {
    return FutureBuilder<DestinationWeather>(
      future: _weather,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Loading live weather for ${widget.destination.name}…',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            color: const Color(0xFFFFF8E8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_outlined,
                      color: Color(0xFF9A6700)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Live weather is unavailable. Destination details are '
                      'still available offline.',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _retryWeather,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final weather = snapshot.data;
        if (weather == null) {
          return const SizedBox.shrink();
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Live destination weather',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh weather',
                      onPressed: _retryWeather,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                Text(
                  '${weather.temperatureC.round()}°C • ${weather.condition}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    _weatherMetric(
                      Icons.thermostat_outlined,
                      'Feels ${weather.feelsLikeC.round()}°C',
                    ),
                    _weatherMetric(
                      Icons.water_drop_outlined,
                      'Humidity ${weather.humidityPercent}%',
                    ),
                    _weatherMetric(
                      Icons.air,
                      'Wind ${weather.windSpeedKph.round()} km/h',
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  'Updated ${DateFormat('MMM d, h:mm a').format(weather.observedAt)} '
                  '• Open-Meteo',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _weatherMetric(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ],
    );
  }
}

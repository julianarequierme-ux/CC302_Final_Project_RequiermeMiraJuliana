import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/booking.dart';
import '../models/route.dart' as booking;
import '../utils/theme.dart';
import '../widgets/booking_widgets.dart';
import '../widgets/common_widgets.dart' show SectionHeader;
import 'results_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialDestination;
  final SearchQuery? initialQuery;
  final VoidCallback? onBack;

  const SearchScreen({
    super.key,
    this.initialDestination,
    this.initialQuery,
    this.onBack,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String _routeType = widget.initialQuery?.type ?? 'Flights';
  bool _showAllRoutes = false;

  void _showResults(BuildContext context, SearchQuery query) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(query: query)),
    );
  }

  void _searchRoute(BuildContext context, booking.Route route) {
    _showResults(
      context,
      SearchQuery(
        type: route.type,
        from: route.from,
        to: route.to,
        date: DateTime(2025, 10, 15),
        returnDate: DateTime(2025, 10, 17),
        passengers: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeList = _showAllRoutes
        ? [...mockFlightRoutes, ...mockSeaRoutes]
        : (_routeType == 'Sea Boats' ? mockSeaRoutes : mockFlightRoutes);
    // Search form and popular-route list share one scrollable, compact page.
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Search'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          SearchCard(
            compact: false,
            initialQuery: widget.initialQuery ??
                (widget.initialDestination == null
                    ? null
                    : SearchQuery(
                        type: 'Flights',
                        from: 'Manila (MNL)',
                        to: widget.initialDestination!,
                        date: DateTime(2025, 10, 15),
                        returnDate: DateTime(2025, 10, 17),
                        passengers: 1,
                      )),
            onTypeChanged: (value) => setState(() {
              _routeType = value;
              _showAllRoutes = false;
            }),
            onSearch: (query) => _showResults(context, query),
          ),
          SectionHeader(
            title: 'Popular Routes',
            actionLabel: _showAllRoutes ? 'Show Less' : 'See All',
            onAction: () => setState(() => _showAllRoutes = !_showAllRoutes),
          ),
          for (final route in routeList)
            RouteTile(
              route: route,
              onTap: () => _searchRoute(context, route),
            ),
          const SizedBox(height: 6),
          const Text(
            'Demo routes and fares are for preview only.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

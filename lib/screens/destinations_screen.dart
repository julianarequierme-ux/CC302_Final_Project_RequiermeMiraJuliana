import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/destination.dart';
import '../utils/theme.dart';
import '../widgets/booking_widgets.dart';
import 'destination_detail_screen.dart';

/// Browse the local Philippine destination catalog with category filters.
class AllDestinationsScreen extends StatefulWidget {
  const AllDestinationsScreen({super.key});

  @override
  State<AllDestinationsScreen> createState() => _AllDestinationsScreenState();
}

class _AllDestinationsScreenState extends State<AllDestinationsScreen> {
  static const _categories = ['All', 'Beaches', 'Nature', 'City', 'Island'];
  String _category = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final destinations = mockDestinations.where((destination) {
      final matchesCategory =
          _category == 'All' || destination.category == _category;
      final matchesQuery = destination.name.toLowerCase().contains(_query) ||
          destination.province.toLowerCase().contains(_query) ||
          destination.famousFor.toLowerCase().contains(_query);
      return matchesCategory && matchesQuery;
    }).toList();

    // Search and category controls remain above the responsive two-column grid.
    return Scaffold(
      appBar: AppBar(title: const Text('All Destinations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search destinations',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final category = _categories[index];
                return ChoiceChip(
                  label: Text(category),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color:
                        _category == category ? Colors.white : AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide.none,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),
          Expanded(
            child: destinations.isEmpty
                ? const Center(child: Text('No destinations found.'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 600 ? 3 : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        itemCount: destinations.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: columns == 2 ? 0.72 : 0.85,
                        ),
                        itemBuilder: (_, index) {
                          final Destination destination = destinations[index];
                          return DestinationCard(
                            width: double.infinity,
                            destination: destination,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DestinationDetailsScreen(
                                    destination: destination),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

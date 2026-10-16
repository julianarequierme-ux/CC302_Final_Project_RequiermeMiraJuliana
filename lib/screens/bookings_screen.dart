import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../state/booking_store.dart';
import '../utils/theme.dart';
import '../widgets/booking_widgets.dart';
import '../widgets/common_widgets.dart' show SegmentToggle, StateMessage;

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingStore>().items;
    final filteredBookings = bookings
        .where((booking) => _filter == 'All' || booking.type == _filter)
        .toList();

    // Gradient title header and functional category filters.
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.paddingOf(context).top + 22, 12, 22),
            decoration: const BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('My Bookings',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  tooltip: 'Booking calendar',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Calendar view is coming soon.')),
                  ),
                  icon: const Icon(Icons.calendar_month_outlined,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: SegmentToggle(
              options: const ['All', 'Flights', 'Sea Boats'],
              selected: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
          ),
          Expanded(
            child: filteredBookings.isEmpty
                ? const StateMessage(
                    icon: Icons.luggage_outlined,
                    title: 'No bookings found',
                    message: 'Try another booking category.')
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (_, index) => BookingCard(
                      key: ValueKey(filteredBookings[index].id),
                      booking: filteredBookings[index],
                      onDelete: () =>
                          _confirmDelete(context, filteredBookings[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Booking booking) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete booking?'),
        content: Text(
          'Remove your ${booking.from} to ${booking.to} booking? '
          'You can undo this from the confirmation message.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;

    final store = context.read<BookingStore>();
    final removedIndex = store.remove(booking);
    if (removedIndex < 0) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Booking deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => store.restore(removedIndex, booking),
        ),
      ),
    );
  }
}

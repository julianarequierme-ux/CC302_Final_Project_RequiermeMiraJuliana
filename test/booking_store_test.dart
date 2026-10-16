import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skyseabooking/models/booking.dart';
import 'package:skyseabooking/screens/bookings_screen.dart';
import 'package:skyseabooking/state/booking_store.dart';

void main() {
  test('a deleted booking can be restored to its original position', () {
    final store = BookingStore.instance;
    final booking = Booking(
      id: 'test-${DateTime.now().microsecondsSinceEpoch}',
      type: 'Flights',
      from: 'Manila',
      to: 'Cebu',
      date: DateTime(2026, 10, 16),
      time: '10:30 AM',
      carrier: 'Demo Airlines',
      code: 'TEST 1',
      passengers: 1,
    );

    store.add(booking);
    final index = store.remove(booking);

    expect(index, 0);
    expect(store.items.any((item) => item.id == booking.id), isFalse);

    store.restore(index, booking);
    expect(store.items.first.id, booking.id);
    store.remove(booking);
  });

  testWidgets('booking deletion requires confirmation and can be undone',
      (tester) async {
    final store = BookingStore.instance;
    final booking = store.items.first;

    await tester.pumpWidget(
      ChangeNotifierProvider<BookingStore>.value(
        value: store,
        child: const MaterialApp(home: BookingsScreen()),
      ),
    );

    await tester.tap(find.byTooltip('Delete booking').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete booking?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(store.items.any((item) => item.id == booking.id), isTrue);

    await tester.tap(find.byTooltip('Delete booking').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(store.items.any((item) => item.id == booking.id), isFalse);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(store.items.any((item) => item.id == booking.id), isTrue);
  });
}

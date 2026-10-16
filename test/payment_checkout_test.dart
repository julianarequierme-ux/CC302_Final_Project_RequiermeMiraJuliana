import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skyseabooking/models/booking.dart';
import 'package:skyseabooking/screens/payment_screen.dart';
import 'package:skyseabooking/state/booking_store.dart';

void main() {
  testWidgets('selecting Maya confirms a mock booking with its fare',
      (tester) async {
    final store = BookingStore.instance;
    const routeFrom = 'Payment test origin';
    const routeTo = 'Payment test destination';

    await tester.pumpWidget(
      ChangeNotifierProvider<BookingStore>.value(
        value: store,
        child: MaterialApp(
          home: PaymentScreen(
            query: SearchQuery(
              type: 'Flights',
              from: routeFrom,
              to: routeTo,
              date: DateTime(2025, 10, 15),
              passengers: 2,
            ),
            carrier: 'Demo Airlines',
            code: 'DM 100',
            departureTime: '9:00 AM',
            unitPrice: 1200,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Maya'));
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    await tester.tap(find.text('Pay ₱2,400'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Booking confirmed!'), findsOneWidget);
    expect(find.textContaining('No real money was charged.'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pump(const Duration(milliseconds: 300));

    final booking = store.items.firstWhere(
      (item) => item.from == routeFrom && item.to == routeTo,
    );
    expect(booking.paymentMethod, 'Maya');
    expect(booking.totalPrice, 2400);
    expect(booking.status, 'Confirmed');
    store.remove(booking);
  });
}

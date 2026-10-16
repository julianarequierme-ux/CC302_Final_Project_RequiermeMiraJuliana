import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../data/mock_data.dart';

/// Simple app-wide store for the user's bookings (in memory).
class BookingStore extends ChangeNotifier {
  BookingStore._() {
    _seed();
  }
  static final BookingStore instance = BookingStore._();

  final List<Booking> _items = [];
  List<Booking> get items => List.unmodifiable(_items);

  void _seed() {
    _items.addAll(mockBookings);
  }

  void add(Booking b) {
    _items.insert(0, b);
    notifyListeners();
  }

  int remove(Booking b) {
    final i = _items.indexWhere((e) => e.id == b.id);
    if (i >= 0) {
      _items.removeAt(i);
      notifyListeners();
    }
    return i;
  }

  void restore(int index, Booking b) {
    _items.insert(index.clamp(0, _items.length), b);
    notifyListeners();
  }
}

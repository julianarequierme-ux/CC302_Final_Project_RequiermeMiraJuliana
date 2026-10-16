class SearchQuery {
  final String type; // 'Flights' or 'Sea Boats'
  final String from;
  final String to;
  final DateTime date;
  final DateTime? returnDate;
  final int passengers;

  const SearchQuery({
    required this.type,
    required this.from,
    required this.to,
    required this.date,
    this.returnDate,
    required this.passengers,
  });
}

class Booking {
  final String id;
  final String type;
  final String from;
  final String to;
  final DateTime date;
  final String time;
  final String carrier;
  final String code;
  final int passengers;
  final String status; // Confirmed / Upcoming
  final int totalPrice;
  final String paymentMethod;

  const Booking({
    required this.id,
    required this.type,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.carrier,
    required this.code,
    required this.passengers,
    this.status = 'Confirmed',
    this.totalPrice = 0,
    this.paymentMethod = '',
  });

  bool get isPast {
    final n = DateTime.now();
    return date.isBefore(DateTime(n.year, n.month, n.day));
  }

  String get label => status;
}

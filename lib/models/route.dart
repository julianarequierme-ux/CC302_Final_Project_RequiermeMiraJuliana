class Route {
  final String from;
  final String to;
  final int price;
  final String type;

  const Route({
    required this.from,
    required this.to,
    required this.price,
    this.type = 'Flights',
  });
}

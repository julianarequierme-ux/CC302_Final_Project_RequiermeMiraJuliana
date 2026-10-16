class Destination {
  final String name;
  final String province;
  final String famousFor;
  final double rating;
  final String category;
  final String travelType;
  final String imageUrl;
  final int price;

  const Destination({
    required this.name,
    this.province = '',
    this.famousFor = '',
    this.rating = 4.8,
    this.category = 'Island',
    this.travelType = 'Flight + Boat',
    required this.imageUrl,
    this.price = 0,
  });
}

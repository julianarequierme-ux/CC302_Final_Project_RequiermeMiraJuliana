import '../models/booking.dart';
import '../models/destination.dart';
import '../models/route.dart' as booking;

const mockDestinations = <Destination>[
  Destination(
    name: 'Cebu',
    province: 'Central Visayas',
    famousFor: 'Kawasan Falls, Oslob whale sharks',
    price: 1299,
    rating: 4.9,
    imageUrl:
        'https://images.unsplash.com/photo-1518509562904-e7ef99cdcc86?w=700',
    category: 'Nature',
    travelType: 'Flight + Boat',
  ),
  Destination(
    name: 'Boracay',
    province: 'Aklan',
    famousFor: 'White Beach, island hopping',
    price: 2499,
    rating: 4.9,
    imageUrl:
        'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=700',
    category: 'Beaches',
    travelType: 'Flight + Boat',
  ),
  Destination(
    name: 'Palawan',
    province: 'El Nido & Coron',
    famousFor: 'Underground River, lagoons',
    price: 3199,
    rating: 4.9,
    imageUrl:
        'https://images.unsplash.com/photo-1530789253388-582c481c54b0?w=700',
    category: 'Beaches',
    travelType: 'Flight + Boat',
  ),
  Destination(
    name: 'Bohol',
    province: 'Central Visayas',
    famousFor: 'Chocolate Hills, tarsiers, Panglao',
    price: 1499,
    rating: 4.8,
    imageUrl:
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=700',
    category: 'Nature',
    travelType: 'Flight + Boat',
  ),
  Destination(
    name: 'Siargao',
    province: 'Surigao del Norte',
    famousFor: 'Cloud 9 surfing, Sugba Lagoon',
    price: 3499,
    rating: 4.8,
    imageUrl:
        'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=700',
    category: 'Island',
    travelType: 'Flight + Boat',
  ),
  Destination(
    name: 'Siquijor',
    province: 'Central Visayas',
    famousFor: 'Salagdoong Beach, Cambugahay Falls',
    price: 1199,
    rating: 4.7,
    imageUrl:
        'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=700',
    category: 'Beaches',
    travelType: 'Sea Boat',
  ),
  Destination(
    name: 'Baguio',
    province: 'Benguet',
    famousFor: 'Burnham Park, Mines View, pine trees',
    price: 999,
    rating: 4.7,
    imageUrl:
        'https://images.unsplash.com/photo-1448375240586-882707db888b?w=700',
    category: 'City',
    travelType: 'Flight',
  ),
  Destination(
    name: 'Davao',
    province: 'Davao del Sur',
    famousFor: 'Mt. Apo, Eden Nature Park, Philippine eagle',
    price: 2199,
    rating: 4.8,
    imageUrl:
        'https://images.unsplash.com/photo-1511497584788-876760111969?w=700',
    category: 'Nature',
    travelType: 'Flight',
  ),
  Destination(
    name: 'Batanes',
    province: 'Batanes Islands',
    famousFor: 'Rolling hills, Basco lighthouse',
    price: 4999,
    rating: 4.9,
    imageUrl:
        'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=700',
    category: 'Nature',
    travelType: 'Flight',
  ),
  Destination(
    name: 'Camiguin',
    province: 'Northern Mindanao',
    famousFor: 'White Island, Sunken Cemetery',
    price: 1899,
    rating: 4.7,
    imageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=700',
    category: 'Island',
    travelType: 'Sea Boat',
  ),
];

const mockFlightRoutes = <booking.Route>[
  booking.Route(from: 'Manila', to: 'Cebu', price: 1299),
  booking.Route(from: 'Cebu', to: 'Manila', price: 1299),
  booking.Route(from: 'Manila', to: 'Palawan', price: 1899),
  booking.Route(from: 'Manila', to: 'Boracay', price: 2299),
];

const mockSeaRoutes = <booking.Route>[
  booking.Route(
      from: 'Cebu', to: 'Bohol (Sea Trip)', price: 599, type: 'Sea Boats'),
];

final mockBookings = <Booking>[
  Booking(
    id: 's1',
    type: 'Flights',
    from: 'Manila',
    to: 'Cebu',
    date: DateTime(2025, 10, 15),
    time: '10:30 AM',
    carrier: 'Philippine Airlines',
    code: 'PR 2908',
    passengers: 1,
    status: 'Confirmed',
  ),
  Booking(
    id: 's2',
    type: 'Sea Boats',
    from: 'Cebu',
    to: 'Bohol (Sea Trip)',
    date: DateTime(2025, 10, 20),
    time: '8:00 AM',
    carrier: 'OceanJet',
    code: '8A 122',
    passengers: 2,
    status: 'Upcoming',
  ),
  Booking(
    id: 's3',
    type: 'Flights',
    from: 'Cebu',
    to: 'Manila',
    date: DateTime(2025, 11, 5),
    time: '4:20 PM',
    carrier: 'Cebu Pacific',
    code: '5J 567',
    passengers: 1,
    status: 'Past',
  ),
  Booking(
    id: 's4',
    type: 'Sea Boats',
    from: 'Bohol',
    to: 'Siquijor (Sea Trip)',
    date: DateTime(2025, 11, 8),
    time: '9:00 AM',
    carrier: 'FastCat',
    code: '102',
    passengers: 1,
    status: 'Upcoming',
  ),
];

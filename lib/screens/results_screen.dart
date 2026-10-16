import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../utils/format.dart';
import '../utils/theme.dart';
import '../widgets/common_widgets.dart';
import 'payment_screen.dart';

class _Option {
  final String carrier, code, time;
  final int price;
  const _Option(this.carrier, this.code, this.time, this.price);
}

class ResultsScreen extends StatefulWidget {
  final SearchQuery query;
  const ResultsScreen({super.key, required this.query});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<List<_Option>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  // Simulated provider lookup (loading state demo).
  Future<List<_Option>> _load() async {
    await Future.delayed(const Duration(milliseconds: 900));
    final base = 900 + (widget.query.to.length * 211) % 1500;
    if (widget.query.type == 'Flights') {
      return [
        _Option('Philippine Airlines', 'PR ${2000 + base % 900}', '6:15 AM',
            base + 400),
        _Option('Cebu Pacific', '5J ${500 + base % 400}', '10:30 AM', base),
        _Option('AirAsia Philippines', 'Z2 ${100 + base % 300}', '4:20 PM',
            base + 150),
        _Option('PAL Express', '2P ${800 + base % 100}', '8:45 PM', base + 250),
      ];
    }
    return [
      _Option('OceanJet', '8A ${100 + base % 90}', '8:00 AM', base ~/ 3),
      _Option('FastCat', '${100 + base % 50}', '1:00 PM', base ~/ 3 - 50),
      _Option('2GO Travel', 'SF ${200 + base % 60}', '7:30 PM', base ~/ 3 + 80),
    ];
  }

  void _book(_Option option) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          query: widget.query,
          carrier: option.carrier,
          code: option.code,
          departureTime: option.time,
          unitPrice: option.price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.query;
    return Scaffold(
      appBar: AppBar(title: Text('${q.from} → ${q.to}')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${fmtDate(q.date)} • ${q.passengers} passenger${q.passengers > 1 ? 's' : ''} • ${q.type}',
                    style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: AppColors.warning),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Demo schedules and fares; availability is not live.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<_Option>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError || (snap.data ?? []).isEmpty) {
                  return StateMessage(
                    icon: Icons.search_off,
                    title: 'No trips found',
                    message: 'Try a different route or date.',
                    actionLabel: 'Retry',
                    onAction: () => setState(() => _future = _load()),
                  );
                }
                final list = snap.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final o = list[i];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(children: [
                          Icon(
                              q.type == 'Flights'
                                  ? Icons.flight
                                  : Icons.directions_boat,
                              color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(o.carrier,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text('${o.code} • Departs ${o.time}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.muted)),
                                ]),
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(peso(o.price * q.passengers),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary)),
                                const SizedBox(height: 4),
                                FilledButton(
                                    onPressed: () => _book(o),
                                    child: const Text('Book')),
                              ]),
                        ]),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../models/payment_method.dart';
import '../state/booking_store.dart';
import '../utils/format.dart';
import '../utils/theme.dart';

/// Demo checkout: choose a payment rail and confirm a mock booking.
class PaymentScreen extends StatefulWidget {
  final SearchQuery query;
  final String carrier;
  final String code;
  final String departureTime;
  final int unitPrice;

  const PaymentScreen({
    super.key,
    required this.query,
    required this.carrier,
    required this.code,
    required this.departureTime,
    required this.unitPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'gcash';
  bool _processing = false;

  PaymentMethod get _method => supportedPaymentMethods
      .firstWhere((method) => method.id == _selectedMethod);

  Future<void> _confirmPayment() async {
    if (_processing) return;
    setState(() => _processing = true);

    final query = widget.query;
    final total = widget.unitPrice * query.passengers;
    context.read<BookingStore>().add(
          Booking(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            type: query.type,
            from: query.from,
            to: query.to,
            date: query.date,
            time: widget.departureTime,
            carrier: widget.carrier,
            code: widget.code,
            passengers: query.passengers,
            status: 'Confirmed',
            totalPrice: total,
            paymentMethod: _method.name,
          ),
        );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon:
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('Booking confirmed!'),
        content: Text(
          'Your ${_method.name} demo payment of ${peso(total)} was successful. '
          'No real money was charged.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    messenger.showSnackBar(
      const SnackBar(content: Text('Booking saved. View it in My Bookings.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.query;
    final total = widget.unitPrice * query.passengers;

    // Scrollable checkout layout adapts to short and narrow phone screens.
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Trip summary',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text('${query.from} → ${query.to}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${widget.carrier} • ${widget.code}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                  Text('${fmtDate(query.date)} • ${widget.departureTime}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            '${query.passengers} passenger${query.passengers == 1 ? '' : 's'}'),
                      ),
                      Text(peso(widget.unitPrice),
                          style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Total',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Text(peso(total),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 19,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 22, 4, 10),
            child: Text('Choose a payment method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          for (final method in supportedPaymentMethods)
            _PaymentMethodOption(
              method: method,
              selected: _selectedMethod == method.id,
              onTap: () => setState(() => _selectedMethod = method.id),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 19),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Demo checkout only. GCash, Maya, and card payments are not connected to a provider. No payment details are collected and no money will be charged.',
                    style: TextStyle(
                        color: AppColors.text, fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _processing ? null : _confirmPayment,
              icon: _processing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.lock_outline),
              label: Text('Pay ${peso(total)}'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selectable payment rail row shared visually by checkout options.
class _PaymentMethodOption extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.primary : const Color(0xFFE6ECF4),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: method.color.withValues(alpha: .12),
          child: Icon(method.icon, color: method.color),
        ),
        title: Text(method.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(method.description,
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? AppColors.primary : AppColors.muted,
        ),
      ),
    );
  }
}

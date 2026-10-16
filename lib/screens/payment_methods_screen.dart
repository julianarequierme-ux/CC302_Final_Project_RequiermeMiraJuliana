import 'package:flutter/material.dart';

import '../models/payment_method.dart';
import '../utils/theme.dart';

/// Lists the payment options available in the mock booking checkout.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Choose how you want to pay',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'These options are shown at checkout. No payment account or card details are stored.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          for (final method in supportedPaymentMethods)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: method.color.withValues(alpha: .12),
                  child: Icon(method.icon, color: method.color),
                ),
                title: Text(method.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(method.description),
                trailing: const Icon(Icons.check_circle_outline,
                    color: AppColors.primary),
              ),
            ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Demo only: GCash, Maya, and card payment providers are not connected. No real transactions can be made.',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

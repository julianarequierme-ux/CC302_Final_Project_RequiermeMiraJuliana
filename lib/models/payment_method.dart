import 'package:flutter/material.dart';

/// Mock payment options displayed in checkout and the profile payment section.
class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const supportedPaymentMethods = <PaymentMethod>[
  PaymentMethod(
    id: 'gcash',
    name: 'GCash',
    description: 'Pay using your GCash wallet',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF007DFE),
  ),
  PaymentMethod(
    id: 'maya',
    name: 'Maya',
    description: 'Pay using your Maya wallet',
    icon: Icons.wallet_outlined,
    color: Color(0xFF00A86B),
  ),
  PaymentMethod(
    id: 'credit_card',
    name: 'Credit Card',
    description: 'Visa, Mastercard, or other cards',
    icon: Icons.credit_card,
    color: Color(0xFF5A55C9),
  ),
  PaymentMethod(
    id: 'debit_card',
    name: 'Debit Card',
    description: 'Pay with your bank debit card',
    icon: Icons.payment_outlined,
    color: Color(0xFFEF8A27),
  ),
];

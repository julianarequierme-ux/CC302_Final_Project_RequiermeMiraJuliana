String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email is required.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validatePhone(String? value) {
  final phone = value?.trim() ?? '';
  if (phone.isEmpty) return 'Phone number is required.';
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (!RegExp(r'^\+?[0-9][0-9\s()-]{7,16}$').hasMatch(phone) ||
      digits.length < 9 ||
      digits.length > 15) {
    return 'Enter a valid phone number.';
  }
  return null;
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/profile_photo_service.dart';
import '../utils/theme.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';

/// Validated local account registration form.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _nationality = TextEditingController(text: 'Filipino');
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _photoService = ProfilePhotoService();

  DateTime? _dateOfBirth;
  String? _photoPath;
  bool _showPassword = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _nationality.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final action =
        await showAvatarActions(context, hasPhoto: _photoPath != null);
    if (action == null || !mounted) return;
    if (action == AvatarAction.remove) {
      setState(() => _photoPath = null);
      return;
    }
    try {
      final image = await _photoService.pickAndSave(
        source: action == AvatarAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        userId: 'new-account',
      );
      if (image != null && mounted) setState(() => _photoPath = image);
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.message ?? 'Photo permission was denied.')),
        );
      }
    } on FileSystemException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save photo: ${error.message}')),
        );
      }
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date != null) setState(() => _dateOfBirth = date);
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth.')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      fullName: _fullName.text,
      email: _email.text,
      phone: _phone.text,
      dateOfBirth: _dateOfBirth,
      nationality: _nationality.text,
      password: _password.text,
      photoPath: _photoPath,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(auth.errorMessage ?? 'Could not create account.')),
      );
    }
  }

  // Fields stay scrollable and keyboard-safe on smaller devices.
  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Center(
                child: AvatarPicker(
                  photoPath: _photoPath,
                  initials: userInitials(_fullName.text),
                  onTap: _pickPhoto,
                  radius: 42,
                  showAddPhotoLabel: true,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _fullName,
                label: 'Full Name',
                icon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Full name is required.'
                    : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _email,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phone,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: validatePhone,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickBirthDate,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(_dateOfBirth == null
                    ? 'Date of Birth'
                    : DateFormat('MMMM d, yyyy').format(_dateOfBirth!)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  alignment: Alignment.centerLeft,
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: Color(0xFFE5EBF4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nationality,
                label: 'Nationality',
                icon: Icons.flag_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nationality is required.'
                    : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _password,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: !_showPassword,
                validator: (value) => value == null || value.length < 6
                    ? 'Password must be at least 6 characters.'
                    : null,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(_showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _confirmPassword,
                label: 'Confirm Password',
                icon: Icons.lock_reset_outlined,
                obscureText: !_showPassword,
                validator: (value) =>
                    value != _password.text ? 'Passwords do not match.' : null,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Create Account',
                icon: Icons.person_add_alt_1,
                onPressed: loading ? null : _createAccount,
                isLoading: loading,
              ),
              const SizedBox(height: 10),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => Navigator.maybePop(context),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

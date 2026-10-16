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

/// Full form for editing the logged-in user's local profile.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _photoService = ProfilePhotoService();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _nationality;
  DateTime? _dateOfBirth;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _name = TextEditingController(text: user.fullName);
    _email = TextEditingController(text: user.email);
    _phone = TextEditingController(text: user.phone);
    _nationality = TextEditingController(text: user.nationality);
    _dateOfBirth = user.dateOfBirth;
    _photoPath = user.photoPath;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _nationality.dispose();
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
      final photo = await _photoService.pickAndSave(
        source: action == AvatarAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        userId: context.read<AuthProvider>().currentUser!.id,
      );
      if (photo != null && mounted) setState(() => _photoPath = photo);
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date != null) setState(() => _dateOfBirth = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth.')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final oldUser = auth.currentUser!;
    final updated = oldUser.copyWith(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      nationality: _nationality.text.trim(),
      dateOfBirth: _dateOfBirth,
      photoPath: _photoPath,
      clearPhoto: _photoPath == null,
    );
    final success = await auth.updateUser(updated);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Could not save profile.')),
      );
      return;
    }
    if (oldUser.photoPath != null && oldUser.photoPath != _photoPath) {
      try {
        await _photoService.remove(oldUser.photoPath!);
      } on FileSystemException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Could not remove old photo: ${error.message}')),
          );
        }
      }
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Center(
              child: AvatarPicker(
                photoPath: _photoPath,
                initials: userInitials(_name.text),
                onTap: _pickPhoto,
                radius: 44,
              ),
            ),
            const SizedBox(height: 22),
            CustomTextField(
              controller: _name,
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
              onPressed: _pickDate,
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
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Save Changes',
              icon: Icons.check,
              onPressed: loading ? null : _save,
              isLoading: loading,
            ),
          ],
        ),
      ),
    );
  }
}

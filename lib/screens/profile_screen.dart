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
import '../widgets/booking_widgets.dart';
import '../widgets/common_widgets.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onBookings;
  final VoidCallback onSettings;

  const ProfileScreen({
    super.key,
    required this.onBookings,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final dateOfBirth = user.dateOfBirth == null
        ? 'Not set'
        : DateFormat('MMMM d, yyyy').format(user.dateOfBirth!);

    // Account profile and personal details always come from the saved user.
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 280,
            child: ClipPath(
              clipper: _ProfileWaveClipper(),
              child: Container(
                decoration: const BoxDecoration(gradient: appGradient),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 3,
                        right: 8,
                        child: IconButton(
                          tooltip: 'Settings',
                          onPressed: onSettings,
                          icon: const Icon(Icons.settings_outlined,
                              color: Colors.white),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ProfileAvatar(user: user),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(user.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                          ),
                          Text(user.email,
                              style: const TextStyle(
                                  color: Color(0xFFE2EDFF), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFF2D6),
                  child:
                      Icon(Icons.workspace_premium, color: Color(0xFFE5A300)),
                ),
                title: const Text('Traveler',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Member since ${user.createdAt.year}'),
              ),
            ),
          ),
          SectionHeader(
            title: 'Personal Information',
            actionLabel: 'Edit Profile',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(
                children: [
                  ProfileInfoTile(
                    icon: Icons.person_outline,
                    title: 'Full Name',
                    value: user.fullName,
                    onTap: () => _editField(context, user, 'Full Name'),
                  ),
                  const Divider(height: 1, indent: 58),
                  ProfileInfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: user.email,
                    onTap: () => _editField(context, user, 'Email'),
                  ),
                  const Divider(height: 1, indent: 58),
                  ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    value: user.phone.isEmpty ? 'Not set' : user.phone,
                    onTap: () => _editField(context, user, 'Phone Number'),
                  ),
                  const Divider(height: 1, indent: 58),
                  ProfileInfoTile(
                    icon: Icons.cake_outlined,
                    title: 'Date of Birth',
                    value: dateOfBirth,
                    onTap: () => _editBirthDate(context, user),
                  ),
                  const Divider(height: 1, indent: 58),
                  ProfileInfoTile(
                    icon: Icons.flag_outlined,
                    title: 'Nationality',
                    value: user.nationality,
                    onTap: () => _editField(context, user, 'Nationality'),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Quick Links'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(
                children: [
                  _quickLink(context, Icons.luggage_outlined, 'My Bookings',
                      onTap: onBookings),
                  const Divider(height: 1, indent: 58),
                  _quickLink(
                    context,
                    Icons.credit_card_outlined,
                    'Payment Methods',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen()),
                    ),
                  ),
                  const Divider(height: 1, indent: 58),
                  _quickLink(
                      context, Icons.shield_outlined, 'Travel Insurance'),
                  const Divider(height: 1, indent: 58),
                  _quickLink(context, Icons.description_outlined,
                      'Terms & Conditions'),
                  const Divider(height: 1, indent: 58),
                  _quickLink(context, Icons.help_outline, 'Help & Support'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickLink(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      onTap: onTap ??
          () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title is coming soon.')),
              ),
    );
  }

  Future<void> _editField(BuildContext context, User user, String field) async {
    final controller = TextEditingController(
      text: switch (field) {
        'Full Name' => user.fullName,
        'Email' => user.email,
        'Phone Number' => user.phone,
        _ => user.nationality,
      },
    );
    final formKey = GlobalKey<FormState>();
    String? validator(String? value) {
      if (field == 'Email') return validateEmail(value);
      if (field == 'Phone Number') return validatePhone(value);
      if (value == null || value.trim().isEmpty) return '$field is required.';
      return null;
    }

    final saved = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 10, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit $field',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              CustomTextField(
                controller: controller,
                label: field,
                icon: Icons.edit_outlined,
                validator: validator,
                keyboardType: field == 'Email'
                    ? TextInputType.emailAddress
                    : field == 'Phone Number'
                        ? TextInputType.phone
                        : TextInputType.text,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Save',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(sheetContext, controller.text.trim());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (saved == null || !context.mounted) {
      controller.dispose();
      return;
    }
    final updated = switch (field) {
      'Full Name' => user.copyWith(fullName: saved),
      'Email' => user.copyWith(email: saved),
      'Phone Number' => user.copyWith(phone: saved),
      _ => user.copyWith(nationality: saved),
    };
    await _saveUser(context, updated);
    controller.dispose();
  }

  Future<void> _editBirthDate(BuildContext context, User user) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate:
          user.dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date == null || !context.mounted) return;
    await _saveUser(context, user.copyWith(dateOfBirth: date));
  }

  Future<void> _saveUser(BuildContext context, User user) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.updateUser(user);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Profile updated.'
            : auth.errorMessage ?? 'Could not update profile.'),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Log Out?',
      message: 'You will be returned to the login screen.',
      confirmLabel: 'Log Out',
    );
    if (!confirmed || !context.mounted) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.logout();
    if (!context.mounted) return;
    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Could not log out.')),
      );
    }
  }
}

class _ProfileAvatar extends StatefulWidget {
  final User user;

  const _ProfileAvatar({required this.user});

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  final _photoService = ProfilePhotoService();

  Future<void> _choosePhoto() async {
    final oldPath = widget.user.photoPath;
    final action = await showAvatarActions(context, hasPhoto: oldPath != null);
    if (action == null || !mounted) return;
    if (action == AvatarAction.remove) {
      final auth = context.read<AuthProvider>();
      final success =
          await auth.updateUser(widget.user.copyWith(clearPhoto: true));
      if (!mounted) return;
      if (success && oldPath != null) await _removeOldPhoto(oldPath);
      if (mounted) _showResult(success, auth.errorMessage);
      return;
    }
    try {
      final photo = await _photoService.pickAndSave(
        source: action == AvatarAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        userId: widget.user.id,
      );
      if (photo == null || !mounted) return;
      final auth = context.read<AuthProvider>();
      final success =
          await auth.updateUser(widget.user.copyWith(photoPath: photo));
      if (!mounted) return;
      if (success && oldPath != null && oldPath != photo) {
        await _removeOldPhoto(oldPath);
      } else if (!success) {
        await _removeOldPhoto(photo);
      }
      if (mounted) _showResult(success, auth.errorMessage);
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

  Future<void> _removeOldPhoto(String path) async {
    try {
      await _photoService.remove(path);
    } on FileSystemException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not remove old photo: ${error.message}')),
        );
      }
    }
  }

  void _showResult(bool success, String? error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success
              ? 'Profile photo updated.'
              : error ?? 'Could not update photo.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AvatarPicker(
      photoPath: widget.user.photoPath,
      initials: userInitials(widget.user.fullName),
      onTap: _choosePhoto,
      radius: 43,
    );
  }
}

/// Curved lower edge keeps the personal profile header distinctive.
class _ProfileWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..lineTo(0, size.height - 36)
    ..quadraticBezierTo(
        size.width * .25, size.height - 1, size.width * .52, size.height - 22)
    ..quadraticBezierTo(
        size.width * .78, size.height - 45, size.width, size.height - 15)
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

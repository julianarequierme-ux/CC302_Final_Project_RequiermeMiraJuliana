import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Reusable section title with an optional action on the right.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Full-width primary action button shared by forms and result cards.
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon ?? Icons.arrow_forward),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// Reusable validated text field for login, registration, and profile editing.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final int maxLines;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE5EBF4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE5EBF4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

/// Round user photo or initials avatar with an optional photo-picker action.
class AvatarPicker extends StatelessWidget {
  final String? photoPath;
  final String initials;
  final VoidCallback? onTap;
  final double radius;
  final bool showAddPhotoLabel;

  const AvatarPicker({
    super.key,
    required this.photoPath,
    required this.initials,
    this.onTap,
    this.radius = 48,
    this.showAddPhotoLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = !kIsWeb &&
        photoPath != null &&
        photoPath!.isNotEmpty &&
        File(photoPath!).existsSync();
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      backgroundImage: hasPhoto ? FileImage(File(photoPath!)) : null,
      child: hasPhoto
          ? null
          : Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: radius * .55,
              ),
            ),
    );
    final interactive = onTap == null
        ? avatar
        : InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                avatar,
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        interactive,
        if (showAddPhotoLabel) ...[
          const SizedBox(height: 7),
          const Text(
            'Add photo',
            style: TextStyle(color: AppColors.primary, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

enum AvatarAction { camera, gallery, remove }

/// Displays camera, gallery, and optional remove-photo actions.
Future<AvatarAction?> showAvatarActions(
  BuildContext context, {
  required bool hasPhoto,
}) {
  return showModalBottomSheet<AvatarAction>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Photo',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, AvatarAction.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, AvatarAction.gallery),
            ),
            if (hasPhoto)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.danger),
                title: const Text('Remove Photo'),
                onTap: () => Navigator.pop(context, AvatarAction.remove),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Compact segmented control for trip type and booking filters.
class SegmentToggle extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const SegmentToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  IconData? _icon(String option) => switch (option) {
        'Flights' => Icons.flight,
        'Sea Boats' => Icons.directions_boat,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final active = option == selected;
        final icon = _icon(option);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onChanged(option),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : const Color(0xFFE6EEFB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(icon,
                            size: 18,
                            color: active ? Colors.white : AppColors.primary),
                      ),
                    Flexible(
                      child: Text(
                        option,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Centered loading, error, and empty-state messaging.
class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted)),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Confirms irreversible demo actions such as dismissing a notification.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

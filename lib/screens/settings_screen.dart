import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/common_widgets.dart';

/// Account security and notification preferences stored on-device.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _service = AuthService();
  bool _notificationsEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    try {
      final enabled = await _service.getNotificationsEnabled();
      if (mounted) setState(() => _notificationsEnabled = enabled);
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } on PlatformException catch (error) {
      if (mounted) {
        _showMessage('Could not load settings: ${error.message ?? error.code}');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changeNotifications(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    try {
      await _service.setNotificationsEnabled(enabled);
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _notificationsEnabled = !enabled);
        _showMessage(error.message);
      }
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() => _notificationsEnabled = !enabled);
        _showMessage(
          'Could not save settings: ${error.message ?? error.code}',
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final formKey = GlobalKey<FormState>();
    final oldPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmPassword = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: oldPassword,
                  label: 'Current Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required.' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: newPassword,
                  label: 'New Password',
                  icon: Icons.lock_reset_outlined,
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6
                      ? 'Use at least 6 characters.'
                      : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: confirmPassword,
                  label: 'Confirm New Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) => value != newPassword.text
                      ? 'Passwords do not match.'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      final success = await context
          .read<AuthProvider>()
          .changePassword(oldPassword.text, newPassword.text);
      if (mounted) {
        _showMessage(success
            ? 'Password updated.'
            : context.read<AuthProvider>().errorMessage ??
                'Could not change password.');
      }
    }
    oldPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete Account?',
      message:
          'This permanently deletes your local account and saved profile data.',
      confirmLabel: 'Delete Account',
    );
    if (!confirmed || !mounted) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.deleteAccount();
    if (!mounted) return;
    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      _showMessage(auth.errorMessage ?? 'Could not delete account.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Password and delete actions remain explicitly user-confirmed.
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.lock_outline, color: AppColors.primary),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _changePassword,
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined,
                      color: AppColors.primary),
                  title: const Text('Notifications'),
                  subtitle: const Text('Receive booking reminders'),
                  value: _notificationsEnabled,
                  onChanged: _loading ? null : _changeNotifications,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined,
                  color: AppColors.danger),
              title: const Text('Delete Account',
                  style: TextStyle(color: AppColors.danger)),
              subtitle: const Text('Permanently remove this local account'),
              onTap: _deleteAccount,
            ),
          ),
        ],
      ),
    );
  }
}

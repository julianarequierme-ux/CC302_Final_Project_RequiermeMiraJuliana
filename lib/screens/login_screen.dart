import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';
import 'signup_screen.dart';

/// Local account sign-in form.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_email.text, _password.text);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Could not log in.')),
      );
    }
  }

  // Branded header and scrollable form fit both short and tall phone screens.
  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.paddingOf(context).top + 24, 24, 25),
            decoration: const BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.flight_takeoff, color: Colors.white, size: 35),
                SizedBox(height: 8),
                Text('SkySeaBooking',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
                Text('Fly Higher • Sail Further',
                    style: TextStyle(color: Color(0xFFDDEBFF), fontSize: 11)),
                SizedBox(height: 4),
                Text('Welcome back!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w700)),
                Text('Log in to continue your next adventure.',
                    style: TextStyle(color: Color(0xFFEAF3FF), fontSize: 12)),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -17),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Login',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 17),
                        CustomTextField(
                          controller: _email,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 13),
                        CustomTextField(
                          controller: _password,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: !_showPassword,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Password is required.'
                              : null,
                          suffixIcon: IconButton(
                            tooltip: _showPassword
                                ? 'Hide password'
                                : 'Show password',
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                            icon: Icon(_showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Forgot Password?'),
                                content: const Text(
                                    'Password recovery is coming soon.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            ),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        PrimaryButton(
                          label: 'Login',
                          icon: Icons.login,
                          onPressed: loading ? null : _login,
                          isLoading: loading,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              TextButton(
                                onPressed: loading
                                    ? null
                                    : () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignUpScreen()),
                                        ),
                                child: const Text('Create one'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../core/kitchen_theme.dart';
import '../../features/auth/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState is Error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(authState.message),
        backgroundColor: KT.kRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } else if (authState is Authenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is Loading;

    return Scaffold(
      backgroundColor: KT.kLightYellow,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Dark blue top banner with rounded bottom
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 48, 28, 40),
                decoration: const BoxDecoration(
                  color: KT.kDarkBlue,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: KT.kDarkYellow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: Text('🏠', style: TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(height: 20),
                    Text('Welcome back', style: KT.poppins(size: 13, color: KT.kDarkYellow, weight: FontWeight.w500)),
                    Text('ZADNA', style: KT.poppins(size: 32, weight: FontWeight.w800, color: KT.kLightYellow, letterSpacing: 2)),
                    Text('Your kitchen inventory board', style: KT.poppins(size: 13, color: KT.kLightYellow2)),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Sign In', style: KT.poppins(size: 22, weight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('Enter your credentials to continue',
                          style: KT.poppins(size: 13, color: Colors.black45)),
                      const SizedBox(height: 28),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: KT.poppins(weight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          prefixIcon: const Icon(Icons.alternate_email, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: KT.poppins(weight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                              color: Colors.black38,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your password';
                          if (v.length < 8) return 'At least 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(foregroundColor: KT.kGreen),
                          child: Text('Forgot password?', style: KT.poppins(size: 12, color: KT.kGreen)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KT.kDarkBlue,
                          foregroundColor: KT.kLightYellow,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Login', style: KT.poppins(size: 16, weight: FontWeight.w700, color: KT.kLightYellow)),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?", style: KT.poppins(size: 13, color: Colors.black45)),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/register'),
                            style: TextButton.styleFrom(foregroundColor: KT.kGreen),
                            child: Text('Register', style: KT.poppins(size: 13, weight: FontWeight.w700, color: KT.kGreen)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

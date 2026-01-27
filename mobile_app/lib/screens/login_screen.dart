import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pos_app/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );
    debugPrint('Login success status: $success');

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        final role = authProvider.role;
        debugPrint('User role received: $role');
        if (role == 'sales') {
          Navigator.pushReplacementNamed(context, '/sales');
        } else if (role == 'picker') {
          Navigator.pushReplacementNamed(context, '/picker');
        } else if (role == 'accountant') {
          Navigator.pushReplacementNamed(context, '/accountant');
        } else if (role == 'warehouse') {
          Navigator.pushReplacementNamed(context, '/warehouse');
        } else if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (role == 'super_admin') {
          Navigator.pushReplacementNamed(context, '/super-admin');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login Failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.store_mall_directory_rounded,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ).animate().fade(duration: 600.ms).scale(delay: 200.ms),
              const SizedBox(height: 32),

              // Welcome Text
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fade().slideY(begin: 0.3, end: 0, delay: 300.ms),
              Text(
                'Sign in to continue',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fade().slideY(begin: 0.3, end: 0, delay: 500.ms),
              const SizedBox(height: 48),

              // Login Form Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (value) =>
                              Validators.password(value, minLength: 6),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _login,
                                  child: const Text('Login'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fade().slideY(begin: 0.2, end: 0, delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}

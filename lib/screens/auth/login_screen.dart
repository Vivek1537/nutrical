import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.signIn(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(child: Icon(Icons.restaurant_menu, size: 64, color: AppTheme.primary)),
              const SizedBox(height: 16),
              const Center(child: Text('NutriCal', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              Center(child: Text('Sign in to continue', style: TextStyle(color: AppTheme.textSecondary))),
              const SizedBox(height: 48),
              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 16),
              TextField(controller: _passCtrl, obscureText: _obscure,
                decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure)))),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: TextStyle(color: AppTheme.error, fontSize: 13))),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: TextButton(
                onPressed: () { if (_emailCtrl.text.isNotEmpty) { AuthService.resetPassword(_emailCtrl.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent'))); } },
                child: const Text('Forgot Password?'))),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _login,
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Sign In'))),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Don't have an account? ", style: TextStyle(color: AppTheme.textSecondary)),
                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())), child: const Text('Sign Up')),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
}

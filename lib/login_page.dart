import 'package:flutter/material.dart';
import 'package:news_app/auth.dart';
import 'package:news_app/centred_view.dart';
import 'package:provider/provider.dart';
import 'custom_appbar.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);

    return CentredView(
      child: Scaffold(
        appBar: const CustomAppBar(appBarTitle: 'Sign-In'),
        body: Center(
          child: Container(
            height: 400,
            width: 400,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),

                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    // final email = _emailController.text.trim();
                    final email = 'sfjdakljlaksfd@gmail.com';
                    // final password = _passwordController.text;
                    final password = "abcdef123";
                    if (email.isEmpty || password.isEmpty) {
                      _showAlertDialog(context, 'Email and password are required.');
                      return;
                    }

                    final success = await authStore.login(email, password);
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      _showAlertDialog(context, 'Invalid credentials or role not allowed.');
                    }
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}

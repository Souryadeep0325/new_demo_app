import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'auth_store.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _roleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextField(
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Enter role (admin/user)'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final role = _roleController.text;
                authStore.login(role);
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

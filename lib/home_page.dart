import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for changes in AuthStore using Provider
    final authStore = Provider.of<AuthStore>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 100), // Apply 100px padding left and right
        child: Column(
          children: [
            if (authStore.role == 'admin') ...[
              ListTile(
                title: const Text('Sales'),
                onTap: () => Navigator.pushNamed(context, '/sales'),
              ),
              ListTile(
                title: const Text('Purchases'),
                onTap: () => Navigator.pushNamed(context, '/purchases'),
              ),
            ],
            ListTile(
              title: const Text('Listing'),
              onTap: () => Navigator.pushNamed(context, '/listing'),
            ),
            ElevatedButton(
              onPressed: () {
                authStore.logout();  // Call logout method in AuthStore
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

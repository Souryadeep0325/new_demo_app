import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_store.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          if (authStore.role == 'admin') ...[
            ListTile(
              title: Text('Sales'),
              onTap: () => Navigator.pushNamed(context, '/sales'),
            ),
            ListTile(
              title: Text('Purchases'),
              onTap: () => Navigator.pushNamed(context, '/purchases'),
            ),
          ],
          ListTile(
            title: Text('Listing'),
            onTap: () => Navigator.pushNamed(context, '/listing'),
          ),
          ElevatedButton(
            onPressed: () {
              authStore.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}

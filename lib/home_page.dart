import 'package:flutter/material.dart';
import 'package:news_app/centred_view.dart';
import 'auth.dart';
import 'package:provider/provider.dart';
import 'custom_appbar.dart';
import 'gst_calculation_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);

    List<Map<String, String>> tileList = [];

    if (authStore.role == 'ROLE_MANAGER') {
      tileList = [
        {'title': 'Purchases', 'route': '/purchases'},
        {'title': 'QC1', 'route': '/qc1'},
        {'title': 'Factory', 'route': '/factory'},
        {'title': 'QC2', 'route': '/qc2'},
        {'title': 'Listing', 'route': '/listing'},
        {'title': 'Sales', 'route': '/sales'},
        {'title': 'Scrap', 'route': '/scrap'},
        {'title': 'GST Calculation', 'route': '/gst_calculation'},
        {'title': 'All Products', 'route': '  /all_products'},
      ];
    } else if (authStore.role == 'user') {
      tileList = [
        {'title': 'Sales', 'route': '/sales'},
        {'title': 'Listing', 'route': '/listing'},
      ];
    }

    return CentredView(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _logout(context, authStore);
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 50),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 4.0,
            ),
            itemCount: tileList.length,
            itemBuilder: (context, index) {
              return _buildTile(context, tileList[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, Map<String, String> tile) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, tile['route']!);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              tile['title']!,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthStore authStore) async {
    const logoutUrl = 'http://35.154.252.161:8080/api/auth/logout';

    try {
      final response = await http.post(
        Uri.parse(logoutUrl),
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        authStore.logout(); // Clear user state
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showError(context, 'Logout failed with status ${response.statusCode}');
      }
    } catch (e) {
      _showError(context, 'Logout error: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

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
    final theme = Theme.of(context);

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
        {'title': 'All Products', 'route': '/all_products'},
      ];
    } else if (authStore.role == 'user') {
      tileList = [
        {'title': 'Sales', 'route': '/sales'},
        {'title': 'Listing', 'route': '/listing'},
      ];
    }

    return CentredView(
      child: Scaffold(
        appBar: CustomAppBar(appBarTitle: 'My Home'),
        body: Container(
          color: theme.colorScheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${authStore.username ?? 'User'}!',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your tasks and activities',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24.0,
                    mainAxisSpacing: 24.0,
                    childAspectRatio: 4.0,
                  ),
                  itemCount: tileList.length,
                  itemBuilder: (context, index) {
                    return _buildTile(context, tileList[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, Map<String, String> tile) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, tile['route']!),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(
                _getIconForTitle(tile['title']!),
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  tile['title']!,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'purchases':
        return Icons.shopping_cart;
      case 'qc1':
      case 'qc2':
        return Icons.check_circle;
      case 'factory':
        return Icons.factory;
      case 'listing':
        return Icons.list;
      case 'sales':
        return Icons.point_of_sale;
      case 'scrap':
        return Icons.delete;
      case 'gst calculation':
        return Icons.calculate;
      case 'all products':
        return Icons.inventory;
      default:
        return Icons.circle;
    }
  }

  Future<void> _logout(BuildContext context, AuthStore authStore) async {
    const logoutUrl = 'https://api.abcoped.shop/api/auth/logout';

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

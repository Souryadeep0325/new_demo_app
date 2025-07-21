import 'package:flutter/material.dart';
import 'package:news_app/user_profile_panel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:http/http.dart' as http;
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarTitle;
  final List<Widget>? actions;
  @override
  final Size preferredSize;

  const CustomAppBar({super.key, required this.appBarTitle, this.actions})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final theme = Theme.of(context);
    final isAuthenticated = authStore.isAuthenticated;
    final username = authStore.username ?? '';
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      elevation: 0,
      title: Row(
        children: [
          if (appBarTitle == 'My Home')
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.access_time_filled, color: Colors.white)),
          const SizedBox(width: 8),
          Text(
            appBarTitle,
            style: theme.appBarTheme.titleTextStyle,
          ),
        ],
      ),
      actions: [
        ...?actions,
        if (isAuthenticated) ...[
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                username,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () {
                  _logout(context,authStore);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  final authStore = Provider.of<AuthStore>(context, listen: false);

                  showDialog(
                    context: context,
                    builder: (_) => UserProfilePanel(token: authStore.token),
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
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

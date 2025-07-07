import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth.dart';

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
                  authStore.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                tooltip: 'Notifications',
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _showAlertDialog(context),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showAlertDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Menu Options', style: theme.textTheme.titleLarge),
          content: Text(
            'This is the menu option, add your content here!',
            style: theme.textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarTitle;
  @override
  final Size preferredSize;

  const CustomAppBar({super.key, required this.appBarTitle})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    return AppBar(
      backgroundColor: Colors.blue, // Blue theme
      title: Row(
        children: [
          // Left side: Logo with Name
          appBarTitle == 'My Home' ? IconButton(onPressed: (){}, icon: Icon(Icons.access_time_filled))
              :const SizedBox(),
          const SizedBox(width: 8),
           Text(
            appBarTitle, // Your app name here
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
      actions: [
        // Right side: Hamburger Menu
        authStore.isAuthenticated // Check if the user is authenticated
            ? IconButton(
          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
          icon: const Icon(Icons.menu),
          onPressed: () {
            // When the menu icon is clicked, show an alert dialog
            _showAlertDialog(context);
          },
        )
            : Container(),
      ],
    );
  }

  // Function to show an alert dialog with some information
  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Menu Clicked'),
          content: const Text('This is the menu option, add your content here!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:news_app/centred_view.dart';
import 'auth.dart';
import 'package:provider/provider.dart';
import 'custom_appbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for changes in AuthStore using Provider
    final authStore = Provider.of<AuthStore>(context);

    // List of tiles for admin and user roles
    List<Map<String, String>> tileList = [];

    // If the role is admin, show all tiles, otherwise, only show the ones relevant for user
    if (authStore.role == 'admin') {
      tileList = [
        {'title': 'Purchases', 'route': '/purchases'},
        {'title': 'QC1', 'route': '/qc1'},
        {'title': 'Factory', 'route': '/factory'},
        {'title': 'QC2', 'route': '/qc2'},
        {'title': 'Listing', 'route': '/listing'},
        {'title': 'Sales', 'route': '/sales'},
        {'title': 'Scrap', 'route': '/scrap'},
      ];
    } else if (authStore.role == 'user') {
      tileList = [
        {'title': 'Sales', 'route': '/sales'},
        {'title': 'Listing', 'route': '/listing'},
      ];
    }

    return CentredView(
      child: Scaffold(
        appBar: const CustomAppBar(appBarTitle: 'My Home',),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100,vertical: 50), // Apply 100px padding left and right
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns
              crossAxisSpacing: 16.0, // Space between columns
              mainAxisSpacing: 16.0, // Space between rows
              childAspectRatio: 4.0, // Aspect ratio of each tile
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
          color: Colors.grey[200], // Grey background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color
              blurRadius: 8, // Spread of the shadow
              offset: const Offset(0, 4), // Shadow position
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
}

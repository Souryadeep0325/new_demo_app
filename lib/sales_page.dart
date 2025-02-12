import 'package:flutter/material.dart';
import 'package:news_app/centred_view.dart';
import 'package:news_app/custom_appbar.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  // List of orders (sample data)
  final List<Map<String, String>> orders = [
    {'orderId': '101', 'name': 'Order 101', 'details': 'Details of Order 101'},
    {'orderId': '102', 'name': 'Order 102', 'details': 'Details of Order 102'},
    {'orderId': '103', 'name': 'Order 103', 'details': 'Details of Order 103'},
    {'orderId': '104', 'name': 'Order 104', 'details': 'Details of Order 104'},
  ];

  // Search query to filter the orders
  String searchQuery = '';

  // Method to filter orders based on search query
  List<Map<String, String>> get filteredOrders {
    return orders
        .where((order) => order['orderId']!
        .toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CentredView(
      child: Scaffold(
        appBar: const CustomAppBar(appBarTitle: 'Sales',),
        body: Column(
          children: [
            // Top Section: Search Field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search Order ID',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
      
            // Bottom Section: List of Orders
            Expanded(
              child: ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text(order['name'] ?? 'No Name'),
                      subtitle: Text(order['details'] ?? 'No Details'),
                      leading: CircleAvatar(
                        child: Text(order['orderId'] ?? 'N/A'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/centred_view.dart';
import 'package:news_app/custom_appbar.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  // List of orders (sample data with extended fields for ticketId, status, etc.)
  final List<Map<String, dynamic>> orders = [
    {
      'ticketId': 'TCKT0001',
      'status': 'qc1',
      'itemName': 'Smartphone XYZ',
      'itemPrice': 19999.99,
      'creationDate': DateTime(2025, 02, 01),
    },
    {
      'ticketId': 'TCKT0002',
      'status': 'qc2',
      'itemName': 'Laptop ABC',
      'itemPrice': 34999.99,
      'creationDate': DateTime(2025, 02, 02),
    },
    {
      'ticketId': 'TCKT0003',
      'status': 'factory',
      'itemName': 'Headphones ABC',
      'itemPrice': 2999.99,
      'creationDate': DateTime(2025, 02, 03),
    },
    {
      'ticketId': 'TCKT0004',
      'status': 'listing',
      'itemName': 'Smartwatch DEF',
      'itemPrice': 4999.99,
      'creationDate': DateTime(2025, 02, 04),
    },
    {
      'ticketId': 'TCKT0005',
      'status': 'sold',
      'itemName': 'Tablet XYZ',
      'itemPrice': 15999.99,
      'creationDate': DateTime(2025, 02, 05),
    },
  ];

  // Variables for search query and date range filter
  String searchQuery = '';
  DateTimeRange? selectedDateRange;

  // Method to filter orders based on search query and date range
  List<Map<String, dynamic>> get filteredOrders {
    return orders
        .where((order) {
      bool matchesSearchQuery = order['ticketId']!
          .toLowerCase()
          .contains(searchQuery.toLowerCase()) ||
          order['itemName']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
      bool matchesDateRange = true;

      if (selectedDateRange != null) {
        DateTime orderDate = order['creationDate'];
        matchesDateRange = orderDate.isAfter(selectedDateRange!.start) &&
            orderDate.isBefore(selectedDateRange!.end);
      }

      return matchesSearchQuery && matchesDateRange;
    })
        .toList();
  }

  // Function to pick date range
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: selectedDateRange,
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  // Clear all filters
  void _clearFilters() {
    setState(() {
      searchQuery = '';
      selectedDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CentredView(
      child: Scaffold(
        appBar: const CustomAppBar(appBarTitle: 'Sales'),
        body: Column(
          children: [
            // Top Section: Search Field and Date Range Picker
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search Ticket ID or Item Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Range Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDateRange == null
                            ? 'Select Date Range'
                            : 'From: ${DateFormat('MM/dd/yyyy').format(selectedDateRange!.start)} To: ${DateFormat('MM/dd/yyyy').format(selectedDateRange!.end)}',
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDateRange(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Clear Filters Button
                  ElevatedButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
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
                      title: Text(order['ticketId'] ?? 'No Ticket ID'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order['itemName'] ?? 'No Item Name'),
                          Text('Status: ${order['status']}'),
                          Text('Price: \$${order['itemPrice']}'),
                          Text('Created on: ${DateFormat('MM/dd/yyyy').format(order['creationDate'])}'),
                        ],
                      ),
                      leading: CircleAvatar(
                        child: Text(order['ticketId']?.substring(0, 4) ?? 'N/A'),
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

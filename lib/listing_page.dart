import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'centred_view.dart';
import 'custom_appbar.dart';

class ListingPage extends StatefulWidget {
  const ListingPage({super.key});

  @override
  _ListingPageState createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  final List<Map<String, dynamic>> orders = [
    {
      'ticketId': 'TCKT0001',
      'status': 'qc1',
      'itemName': 'Smartphone XYZ',
      'itemPrice': 19999.99,
      'brand': 'Brand A',
      'batteryPercentage': 80,
      'warranty': '2 Years',
      'costPrice': 15000.00,
      'creationDate': DateTime(2025, 02, 01),
    },
    {
      'ticketId': 'TCKT0002',
      'status': 'qc2',
      'itemName': 'Laptop ABC',
      'itemPrice': 34999.99,
      'brand': 'Brand B',
      'batteryPercentage': 75,
      'warranty': '1 Year',
      'costPrice': 25000.00,
      'creationDate': DateTime(2025, 02, 02),
    },
    {
      'ticketId': 'TCKT0003',
      'status': 'factory',
      'itemName': 'Headphones ABC',
      'itemPrice': 2999.99,
      'brand': 'Brand C',
      'batteryPercentage': 90,
      'warranty': '6 Months',
      'costPrice': 2000.00,
      'creationDate': DateTime(2025, 02, 03),
    },
    {
      'ticketId': 'TCKT0004',
      'status': 'listing',
      'itemName': 'Smartwatch DEF',
      'itemPrice': 4999.99,
      'brand': 'Brand D',
      'batteryPercentage': 85,
      'warranty': '1 Year',
      'costPrice': 3500.00,
      'creationDate': DateTime(2025, 02, 04),
    },
    {
      'ticketId': 'TCKT0005',
      'status': 'sold',
      'itemName': 'Tablet XYZ',
      'itemPrice': 15999.99,
      'brand': 'Brand E',
      'batteryPercentage': 95,
      'warranty': '2 Years',
      'costPrice': 12000.00,
      'creationDate': DateTime(2025, 02, 05),
    },
  ];

  String searchQuery = '';
  DateTimeRange? selectedDateRange;

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

  void _clearFilters() {
    setState(() {
      searchQuery = '';
      selectedDateRange = null;
    });
  }

  // Function to change the status of an order
  void _changeStatus(String ticketId, String newStatus) {
    setState(() {
      final order = orders.firstWhere((order) => order['ticketId'] == ticketId);
      order['status'] = newStatus;
    });
  }

  // Function to show the dialog for changing the status
  Future<void> _showChangeStatusDialog(String ticketId) async {
    String selectedStatus = orders
        .firstWhere((order) => order['ticketId'] == ticketId)['status'];

    // The dropdown selection is updated by an onChanged callback
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Status for $ticketId'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedStatus,
                onChanged: (String? newStatus) {
                  if (newStatus != null) {
                    setState(() {
                      // Update selectedStatus immediately in the state
                      selectedStatus = newStatus;
                    });
                  }
                },
                items: ['qc1', 'qc2', 'factory', 'listing', 'sold']
                    .map((status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Update the order's status in the list based on the selected status
                  final order = orders.firstWhere(
                          (order) => order['ticketId'] == ticketId);
                  order['status'] = selectedStatus; // Update status here
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Update Status'),
            ),
          ],
        );
      },
    );
  }


  // Function to show the Create Bill dialog and change status to sold
  Future<void> _createBillDialog(String ticketId) async {
    TextEditingController customerNameController = TextEditingController();
    TextEditingController customerAddressController = TextEditingController();
    TextEditingController customerContactController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Bill for $ticketId'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerNameController,
                decoration: InputDecoration(labelText: 'Customer Name'),
              ),
              TextField(
                controller: customerAddressController,
                decoration: InputDecoration(labelText: 'Customer Address'),
              ),
              TextField(
                controller: customerContactController,
                decoration: InputDecoration(labelText: 'Customer Contact'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final customerName = customerNameController.text;
                final customerAddress = customerAddressController.text;
                final customerContact = customerContactController.text;

                if (customerName.isNotEmpty && customerAddress.isNotEmpty && customerContact.isNotEmpty) {
                  final order = orders.firstWhere((order) => order['ticketId'] == ticketId);
                  final billDetails = '''
                    Bill for ${order['itemName']} (Ticket ID: $ticketId)
                    Customer: $customerName
                    Address: $customerAddress
                    Contact: $customerContact
                    Price: \$${order['itemPrice']}
                    Date: ${DateFormat('MM/dd/yyyy').format(order['creationDate'])}
                    Status: Sold
                  ''';

                  // Show bill and change status
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Sample Bill'),
                        content: SingleChildScrollView(child: Text(billDetails)),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _changeStatus(ticketId, 'sold');
                              });
                              Navigator.of(context).pop(); // Close bill dialog
                              Navigator.of(context).pop(); // Close create bill dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Bill created for $ticketId')),
                              );
                            },
                            child: Text('Proceed'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all the details')),
                  );
                }
              },
              child: Text('Create Bill'),
            ),
          ],
        );
      },
    );
  }

  // Function to show product details
  Future<void> _showProductDetailsDialog(Map<String, dynamic> order) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Product Details for ${order['ticketId']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item Name: ${order['itemName']}'),
              Text('Brand: ${order['brand'] ?? 'N/A'}'),
              Text('Battery: ${order['batteryPercentage'] ?? 'N/A'}%'),
              Text('Warranty: ${order['warranty'] ?? 'N/A'}'),
              Text('Cost Price: \$${order['costPrice'] ?? 'N/A'}'),
              Text('Price: \$${order['itemPrice']}'),
              Text('Created on: ${DateFormat('MM/dd/yyyy').format(order['creationDate'])}'),
              Text('Status: ${order['status']}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the product details dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CentredView(
      child: Scaffold(
        appBar: const CustomAppBar(appBarTitle: 'Sales'),
        backgroundColor: Colors.blue[50],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Ticket ID or Item Name',
                      labelStyle: TextStyle(color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDateRange == null
                            ? 'Select Date Range'
                            : 'From: ${DateFormat('MM/dd/yyyy').format(selectedDateRange!.start)} To: ${DateFormat('MM/dd/yyyy').format(selectedDateRange!.end)}',
                        style: TextStyle(color: Colors.blue),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Colors.blue),
                        onPressed: () => _selectDateRange(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _clearFilters,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(order['ticketId'] ?? 'No Ticket ID'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order['itemName'] ?? 'No Item Name'),
                          Row(
                            children: [
                              Text('Status: ${order['status']}'),
                              const Spacer(),  // Ensures everything stays to the left
                              ElevatedButton(
                                onPressed: () {
                                  _showChangeStatusDialog(order['ticketId']);
                                },
                                child: Text('Edit Status'),
                              ),
                              SizedBox(width: 8),  // Optional: Adds space between the buttons
                              IconButton(
                                icon: Icon(Icons.info, color: Colors.blue),
                                onPressed: () {
                                  _showProductDetailsDialog(order); // Show product details dialog
                                },
                              ),

                                // This will remain towards the right if you use Spacer()
                            ],
                          ),
                          Text('Price: \$${order['itemPrice']}'),
                          Text('Created on: ${DateFormat('MM/dd/yyyy').format(order['creationDate'])}'),
                        ],
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(order['ticketId']?.substring(0, 4) ?? 'N/A', style: TextStyle(color: Colors.white)),
                      ),
                      trailing: order['status'] == 'listing'
                          ? ElevatedButton(
                        onPressed: () {
                          _createBillDialog(order['ticketId']);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text('Create Bill'),
                      )
                          : null,
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

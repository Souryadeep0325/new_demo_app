import 'package:flutter/material.dart';

class ListingPage extends StatefulWidget {
  const ListingPage({super.key});

  @override
  _ListingPageState createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  // List of products with status
  final List<Map<String, dynamic>> products = [
    {'id': '001', 'name': 'Product A', 'price': 100, 'status': 'available'},
    {'id': '002', 'name': 'Product B', 'price': 150, 'status': 'available'},
    {'id': '003', 'name': 'Product C', 'price': 200, 'status': 'available'},
  ];

  // Controllers for bill creation
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  // Method to create a bill for a product
  void _createBill(Map<String, dynamic> product) {
    final customerName = _customerNameController.text;
    final customerAddress = _customerAddressController.text;
    final customerPhone = _customerPhoneController.text;

    // Validate customer details
    if (customerName.isEmpty || customerAddress.isEmpty || customerPhone.isEmpty) {
      _showAlertDialog('Please fill in all customer details.');
    } else {
      // Mark product as sold
      setState(() {
        product['status'] = 'sold';
      });

      // Clear the form fields
      _customerNameController.clear();
      _customerAddressController.clear();
      _customerPhoneController.clear();

      // Navigate to the bill page to view the bill
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillPage(
            product: product,
            customerName: customerName,
            customerAddress: customerAddress,
            customerPhone: customerPhone,
          ),
        ),
      );
    }
  }

  // Method to show an alert dialog
  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listing')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(product['name']),
              subtitle: Text('Price: \$${product['price']}'),
              leading: CircleAvatar(
                child: Text(product['id']),
              ),
              trailing: product['status'] == 'available'
                  ? ElevatedButton(
                onPressed: () {
                  _showBillForm(context, product);
                },
                child: const Text('Create Bill'),
              )
                  : const Text('Sold', style: TextStyle(color: Colors.green)),
            ),
          );
        },
      ),
    );
  }

  // Show Bill Creation Form when 'Create Bill' is pressed
  void _showBillForm(BuildContext context, Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Customer Name
              TextField(
                controller: _customerNameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              const SizedBox(height: 10),

              // Customer Address
              TextField(
                controller: _customerAddressController,
                decoration: const InputDecoration(labelText: 'Customer Address'),
              ),
              const SizedBox(height: 10),

              // Customer Phone
              TextField(
                controller: _customerPhoneController,
                decoration: const InputDecoration(labelText: 'Customer Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  _createBill(product);
                },
                child: const Text('Create Bill'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BillPage extends StatelessWidget {
  final Map<String, dynamic> product;
  final String customerName;
  final String customerAddress;
  final String customerPhone;

  const BillPage({
    super.key,
    required this.product,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Product: ${product['name']}'),
            Text('Price: \$${product['price']}'),
            Text('Customer Name: $customerName'),
            Text('Customer Address: $customerAddress'),
            Text('Customer Phone: $customerPhone'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the listing page
              },
              child: const Text('Back to Listings'),
            ),
          ],
        ),
      ),
    );
  }
}

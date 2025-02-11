import 'package:flutter/material.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  _PurchasesPageState createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  // List of products (sample data)
  final List<Map<String, String>> products = [];

  // Controllers for product fields
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();

  // Method to add product to the list
  void _addProduct() {
    final productId = _productIdController.text;
    final productName = _productNameController.text;
    final productPrice = _productPriceController.text;

    // Check if any field is empty
    if (productId.isEmpty || productName.isEmpty || productPrice.isEmpty) {
      _showAlertDialog('Please fill in all fields.');
    } else {
      // Add the new product to the list
      setState(() {
        products.add({
          'id': productId,
          'name': productName,
          'price': productPrice,
        });
      });

      // Clear the text fields
      _productIdController.clear();
      _productNameController.clear();
      _productPriceController.clear();
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
                Navigator.pop(context);  // Close the dialog
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
      appBar: AppBar(title: const Text('Purchases')),
      body: Column(
        children: [
          // Top Section: Product Entry Form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Product ID Field
                TextField(
                  controller: _productIdController,
                  decoration: const InputDecoration(
                    labelText: 'Product ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),

                // Product Name Field
                TextField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                // Product Price Field
                TextField(
                  controller: _productPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Product Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                // Add Product Button
                ElevatedButton(
                  onPressed: _addProduct,
                  child: const Text('Add Product'),
                ),
              ],
            ),
          ),

          // Bottom Section: List of Products
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(product['name'] ?? 'No Name'),
                    subtitle: Text('Price: \$${product['price']}'),
                    leading: CircleAvatar(
                      child: Text(product['id'] ?? 'N/A'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

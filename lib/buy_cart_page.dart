import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'auth.dart';

class BuyCartPage extends StatefulWidget {
  const BuyCartPage({super.key});

  @override
  State<BuyCartPage> createState() => _BuyCartPageState();
}

class _BuyCartPageState extends State<BuyCartPage> {
  List<dynamic> cartItems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() => isLoading = true);
    final authStore = Provider.of<AuthStore>(context, listen: false);

    final url = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items?cartType=BUY');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${authStore.token}'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() => cartItems = data['content'] ?? []);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch cart items')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> removeCartItem(int detailId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final url = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items/clear/$detailId');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer ${authStore.token}'},
    );

    if (response.statusCode == 200) {
      fetchCartItems(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove item')),
      );
    }
  }

  Future<void> clearCart() async {
    final url = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items/clear?cartType=BUY');
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer ${authStore.token}'},
    );

    if (response.statusCode == 200) {
      fetchCartItems(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear Cart',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear Cart?'),
                  content: const Text('Are you sure you want to clear the cart?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
                  ],
                ),
              );

              if (confirm == true) await clearCart();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          final List<dynamic> details = item['details'] ?? [];

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item ID: ${item['itemId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  ...details.map((detail) {
                    return ListTile(
                      title: Text(detail['productName'] ?? 'No name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Brand: ${detail['brand']}'),
                          Text('IMEI: ${detail['imeiNo']}'),
                          Text('Battery: ${detail['batteryHealth']}'),
                          Text('RAM/ROM: ${detail['ramRomSpecs']}'),
                          Text('Color: ${detail['colorSpecs'] ?? 'N/A'}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => removeCartItem(detail['id']),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

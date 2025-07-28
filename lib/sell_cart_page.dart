import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

import 'auth.dart';

class SellCartPage extends StatefulWidget {
  const SellCartPage({super.key});

  @override
  State<SellCartPage> createState() => _SellCartPageState();
}

class _SellCartPageState extends State<SellCartPage> {
  List<dynamic> cartItems = [];
  bool isLoading = false;
  double totalSellValue = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() => isLoading = true);
    final authStore = Provider.of<AuthStore>(context, listen: false);

    final url = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items?cartType=SELL');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${authStore.token}'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      cartItems = data['content'] ?? [];

      totalSellValue = 0.0;
      for (var item in cartItems) {
        for (var detail in item['details']) {
          totalSellValue += (detail['acquisitionCost'] ?? 0).toDouble();
        }
      }

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch sell cart items')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> removeCartItem(int detailId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final url = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items/clear/SELL/$detailId');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer ${authStore.token}'},
    );

    if (response.statusCode == 200) {
      fetchCartItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove item')),
      );
    }
  }

  Future<void> clearCart() async {
    final url = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items/clear?cartType=SELL');
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer ${authStore.token}'},
    );

    if (response.statusCode == 200) {
      fetchCartItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear cart')),
      );
    }
  }

  Future<void> checkoutCart() async {
    final formData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _BillingFormDialog(),
    );

    if (formData == null) return;

    // Add additional required fields
    formData['placeOfSale'] = 'Kolkata';
    formData['profit'] = 1500.75;

    final authStore = Provider.of<AuthStore>(context, listen: false);
    final response = await http.post(
      Uri.parse('https://api.abcoped.shop/api/ticket/cart/items/sell/checkout'),
      headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode(formData),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // go back or refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear Cart',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear Cart?'),
                  content: const Text('Are you sure you want to clear the sell cart?'),
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
          ? const Center(child: Text('Sell cart is empty'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Item ID: ${item['itemId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => removeCartItem(item['itemId']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: checkoutCart,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text('Checkout from Sell Cart'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
class _BillingFormDialog extends StatefulWidget {
  const _BillingFormDialog({super.key});

  @override
  State<_BillingFormDialog> createState() => _BillingFormDialogState();
}

class _BillingFormDialogState extends State<_BillingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _gstIdController = TextEditingController();
  final _billNumberController = TextEditingController();
  final _billDateController = TextEditingController();
  final List<PaymentEntry> _payments = [PaymentEntry()];

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    _gstIdController.dispose();
    _billNumberController.dispose();
    _billDateController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = {
        'customerName': _customerNameController.text,
        'phoneNumber': _phoneNumberController.text,
        'gstId': _gstIdController.text.isNotEmpty ? _gstIdController.text : null,
        'billNumber': _billNumberController.text,
        'billDate': _billDateController.text,
        'payments': _payments.map((p) => p.toJson()).toList(),
      };

      Navigator.of(context).pop(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Billing Details'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _gstIdController,
                decoration: const InputDecoration(labelText: 'GST ID (optional)'),
              ),
              TextFormField(
                controller: _billNumberController,
                decoration: const InputDecoration(labelText: 'Bill Number'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _billDateController,
                decoration: const InputDecoration(labelText: 'Bill Date (YYYY-MM-DD)'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const Text('Payments', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._payments.asMap().entries.map((entry) {
                final index = entry.key;
                final payment = entry.value;
                return PaymentEntryWidget(
                  key: ValueKey(index),
                  entry: payment,
                  onRemove: _payments.length > 1
                      ? () => setState(() => _payments.removeAt(index))
                      : null,
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _payments.add(PaymentEntry())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Payment Mode'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submitForm, child: const Text('Submit')),
      ],
    );
  }
}

class PaymentEntry {
  String? modeOfPayment;
  double? amount;
  String? transactionId;
  String? paidAt;

  Map<String, dynamic> toJson() {
    final map = {
      'modeOfPayment': modeOfPayment,
      'amount': amount,
    };
    if (transactionId != null && transactionId!.isNotEmpty) {
      map['transactionId'] = transactionId;
    }
    if (paidAt != null && paidAt!.isNotEmpty) {
      map['paidAt'] = paidAt;
    }
    return map;
  }
}

class PaymentEntryWidget extends StatelessWidget {
  final PaymentEntry entry;
  final VoidCallback? onRemove;

  const PaymentEntryWidget({
    super.key,
    required this.entry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: entry.modeOfPayment,
          items: const [
            DropdownMenuItem(value: 'CASH', child: Text('Cash')),
            DropdownMenuItem(value: 'UPI', child: Text('UPI')),
            DropdownMenuItem(value: 'CARD', child: Text('Card')),
            DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
          ],
          onChanged: (val) => entry.modeOfPayment = val,
          decoration: const InputDecoration(labelText: 'Mode of Payment'),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
          onChanged: (val) => entry.amount = double.tryParse(val),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Transaction ID (optional)'),
          onChanged: (val) => entry.transactionId = val,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Paid At (optional)'),
          onChanged: (val) => entry.paidAt = val,
        ),
        if (onRemove != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              label: const Text('Remove'),
            ),
          ),
        const Divider(),
      ],
    );
  }
}

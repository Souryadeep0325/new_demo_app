import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart'; // Assuming AuthStore is defined here

class ProductFormDialog extends StatefulWidget {
  final int itemId;

  const ProductFormDialog({super.key, required this.itemId});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final TextEditingController invoiceNumberController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  String purchaseType = 'UPI';
  final List<String> purchaseTypes = ['UPI', 'CARD', 'CASH']; // Add more if needed

  bool isSubmitting = false;

  Future<void> _submitForm() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);

    final body = {
      "itemId": widget.itemId,
      "invoiceNumber": int.tryParse(invoiceNumberController.text) ?? 0,
      "invoiceDate": DateTime.now().toIso8601String().split("T").first,
      "customerName": customerNameController.text,
      "productPurchaseType": purchaseType,
    };

    setState(() => isSubmitting = true);

    final response = await http.post(
      Uri.parse('http://35.154.252.161:8080/api/ticket/create-ticket'),
      headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    setState(() => isSubmitting = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket created successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Ticket for Item ID ${widget.itemId}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: invoiceNumberController,
              decoration: const InputDecoration(labelText: 'Invoice Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: customerNameController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            DropdownButtonFormField<String>(
              value: purchaseType,
              items: purchaseTypes
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => purchaseType = val);
              },
              decoration: const InputDecoration(labelText: 'Purchase Type'),
            ),
            const SizedBox(height: 8),
            Text("Invoice Date: ${DateTime.now().toIso8601String().split("T").first}"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submitForm,
          child: isSubmitting
              ? const CircularProgressIndicator()
              : const Text('Submit'),
        ),
      ],
    );
  }
}

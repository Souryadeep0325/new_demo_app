import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
          totalSellValue += (detail['sellingCost'] ?? 0).toDouble();
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
      builder: (_) => _BillingFormDialog(totalAmount: totalSellValue),
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
      await authStore.fetchTicketStatusCounts();
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
      // body: isLoading
      //     ? const Center(child: CircularProgressIndicator())
      //     : cartItems.isEmpty
      //     ? const Center(child: Text('Sell cart is empty'))
      //     : Column(
      //   children: [
      //     Expanded(
      //       child: ListView.builder(
      //         itemCount: cartItems.length,
      //         itemBuilder: (context, index) {
      //           final item = cartItems[index];
      //
      //           return Card(
      //             margin: const EdgeInsets.all(8),
      //             child: Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Text('Item ID: ${item['itemId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
      //                   const Divider(),
      //                   IconButton(
      //                     icon: const Icon(Icons.remove_circle, color: Colors.red),
      //                     onPressed: () => removeCartItem(item['itemId']),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           );
      //         },
      //       ),
      //     ),
      //     ElevatedButton.icon(
      //       onPressed: checkoutCart,
      //       icon: const Icon(Icons.shopping_cart_checkout),
      //       label: const Text('Checkout from Sell Cart'),
      //       style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
      //     ),
      //     const SizedBox(height: 10),
      //   ],
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(child: Text('Sell cart is empty'))
          : Center(
            child: Column(
                    children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                    columnSpacing: 28,
                    headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    border: TableBorder.all(
                        color: Colors.grey.shade300, width: 1),
                    columns: const [
                      DataColumn(label: Text("Item ID")),
                      DataColumn(label: Text("Serial No")),
                      DataColumn(label: Text("IMEI")),
                      DataColumn(label: Text("Product")),
                      DataColumn(label: Text("Brand")),
                      DataColumn(label: Text("RAM/ROM")),
                      DataColumn(label: Text("Battery")),
                      DataColumn(label: Text("Warranty")),
                      DataColumn(label: Text("Acquisition Cost")),
                      DataColumn(label: Text("Refurbished Cost")),
                      DataColumn(label: Text("Selling Cost")),
                      DataColumn(label: Text("Actions")),
                    ],
                    rows: cartItems.expand((item) {
                      return (item['details'] as List).map((detail) {
                        return DataRow(cells: [
                          DataCell(Text(item['itemId'].toString())),
                          DataCell(Text(detail['itemSerialNo'] ?? '-')),
                          DataCell(Text(detail['imeiNo'] ?? '-')),
                          DataCell(Text(detail['productName'] ?? '-')),
                          DataCell(Text(detail['brand'] ?? '-')),
                          DataCell(Text(detail['ramRomSpecs'] ?? '-')),
                          DataCell(Text(detail['batteryHealth'] ?? '-')),
                          DataCell(Text(detail['warranty'] ?? '-')),
                          DataCell(Text("₹${detail['acquisitionCost'] ?? 0}")),
                          DataCell(Text("₹${detail['refurbishedCost'] ?? 0}")),
                          DataCell(Text("₹${detail['sellingCost'] ?? 0}")),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_note, color: Colors.black),
                                  tooltip: "Edit Item ",
                                  onPressed: () => showEditCartDialog(context, item['id'],detail['id'],item["itemId"]),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  tooltip: "Remove Item",
                                  onPressed: () => removeCartItem(item['itemId']),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList();
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Total Sell Value: ₹${totalSellValue.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: checkoutCart,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Checkout from Sell Cart'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 10),
                    ],
                  ),
          ),
    );
  }

  Future<void> showEditCartDialog(
      BuildContext context, int cartItemId, int detailId,int productMasterId) async {
    final token = Provider.of<AuthStore>(context, listen: false).token;

    final sellingCostController = TextEditingController();


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Cart Item"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Acquisition Cost
                    TextField(
                      controller: sellingCostController,
                      decoration: const InputDecoration(
                        labelText: "Selling Cost",
                      ),
                      keyboardType: TextInputType.number,
                    ),

                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final sellingCost =
                int.tryParse(sellingCostController.text.trim());



                final details = [
                  {
                    "id": detailId,
                    "sellingCost": sellingCost
                  },
                ];

                await editCartItem(context,cartItemId, details);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
  Future<void> editCartItem(BuildContext context, int cartItemId, List<Map<String, dynamic>> details) async {
    final token = Provider.of<AuthStore>(context, listen: false).token;

    final url = Uri.parse("https://api.abcoped.shop/api/ticket/SELL/items/$cartItemId");

    final body = jsonEncode({
      "details": details,
    });

    final response = await http.patch(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: body,
    );

    if (response.statusCode == 200) {
      fetchCartItems();
      // Navigator.of(context).pop(true); // close dialog and return success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Cart item updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Update failed: ${response.statusCode}")),
      );
    }
  }

}

class _BillingFormDialog extends StatefulWidget {
  final double totalAmount;

  const _BillingFormDialog({required this.totalAmount});

  @override
  State<_BillingFormDialog> createState() => _BillingFormDialogState();
}

class _BillingFormDialogState extends State<_BillingFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> _formData = {
    'phoneNumber': '',
    'customerName': '',
    'gstNumber': '',
    'gstId': '',
    // 'Document Type': null,
    // 'Document ID': '',
    'storeId': '',
  };

  String? _validateRequired(String? val) =>
      val == null || val.trim().isEmpty ? 'Required' : null;



  List<Map<String, dynamic>> payments = [
    {
      'modeOfPayment': 'CASH',
      'amount': 0.0,
      'transactionId': '',
      'paidAt': null,
    },
  ];

  double get totalPaid =>
      payments.fold(0.0, (sum, p) => sum + (p['amount'] ?? 0.0));

  double get remainingAmount => widget.totalAmount - totalPaid;

  bool get isPaymentComplete =>
      (totalPaid - widget.totalAmount).abs() < 0.01;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Billing Details'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._formData.keys.map((key) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      decoration: InputDecoration(labelText: key == 'storeId'
                          ? 'Store ID'
                          : key == 'customerAadharId'
                          ? 'Customer AadharId'
                          : key == 'phoneNumber'
                          ? 'Phone Number'
                          : key == 'gstNumber'
                          ? 'GST Number'
                          : key == 'gstId'
                          ? 'Business Name'
                          : key == 'customerName' ? 'Customer Name' :key),
                      keyboardType: (key == 'storeId' ||
                          key == 'customerAadharId')
                          ? TextInputType.number
                          : TextInputType.text,
                      onChanged: (val) => _formData[key] = val.trim(),
                      validator: (val) {
                        if ([ 'customerAadharId', 'customerName']
                            .contains(key)) {
                          return (val == null || val.isEmpty)
                              ? 'Required'
                              : null;
                        }
                        if (key == 'phoneNumber') {
                          if (val == null || val.isEmpty) return 'Required';
                          final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                          if (!phoneRegex.hasMatch(val.trim())) return 'Enter a valid 10-digit mobile number';
                          return null;
                        }
                        return null;
                      },
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Cost: ₹${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Remaining: ₹${remainingAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isPaymentComplete
                            ? Colors.green
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),

                const Text('Payment Methods',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                ...payments.asMap().entries.map((entry) {
                  int index = entry.key;
                  var payment = entry.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: payment['modeOfPayment'],
                            items: [
                              'CASH',
                              'CARD',
                              'CHEQUE',
                              'NET_BANKING',
                              'UPI',
                              'CREDIT'
                            ].map((mode) {
                              return DropdownMenuItem(
                                  value: mode, child: Text(mode));
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => payment['modeOfPayment'] = value),
                            decoration:
                            const InputDecoration(labelText: 'Mode of Payment'),
                          ),


                          if (['UPI', 'CARD', 'NET_BANKING', 'CHEQUE','CREDIT']
                              .contains(payment['modeOfPayment']))
                            TextFormField(
                              initialValue: payment['transactionId'],
                              decoration:
                              const InputDecoration(labelText: 'Transaction ID'),
                              onChanged: (val) =>
                              payment['transactionId'] = val.trim(),
                            ),

                          TextFormField(
                            initialValue: payment['amount'].toString(),
                            decoration:
                            const InputDecoration(labelText: 'Amount'),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => setState(() =>
                            payment['amount'] = double.tryParse(val) ?? 0.0),
                          ),

                          if (index > 0)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.delete),
                                label: const Text('Remove'),
                                onPressed: () {
                                  setState(() => payments.removeAt(index));
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment Method'),
                    onPressed: () {
                      setState(() {
                        payments.add({
                          'modeOfPayment': 'CASH',
                          'amount': 0.0,
                          'transactionId': '',
                          'paidAt': null,
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isPaymentComplete
              ? () {
            if (!_formKey.currentState!.validate()) return;

            final sanitizedPayments = payments.map((p) {
              final map = {
                'modeOfPayment': p['modeOfPayment'],
                'amount': p['amount'],
              };
              if ((p['transactionId'] ?? '').isNotEmpty) {
                map['transactionId'] = p['transactionId'];
              }
              if (p['paidAt'] != null) {
                map['paidAt'] = p['paidAt'];
              }
              return map;
            }).toList();

            _formData['payments'] = sanitizedPayments;
            _formData['storeId'] =
                int.tryParse(_formData['storeId'] ?? '') ?? 0;
            _formData['customerAadharId'] =
                int.tryParse(_formData['customerAadharId'] ?? '') ?? 0;

            Navigator.pop(context, _formData);
          }
              : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
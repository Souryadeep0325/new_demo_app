import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
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
  double totalAcquisitionCost = 0.0;


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
      // setState(() => cartItems = data['content'] ?? []);
      cartItems = data['content'] ?? [];

      totalAcquisitionCost = 0.0;
      for (var item in cartItems) {
        for (var detail in item['details']) {
          totalAcquisitionCost += (detail['acquisitionCost'] ?? 0).toDouble();
        }
      }

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch cart items')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> removeCartItem(int detailId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final url = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items/clear/BUY/$detailId');
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
    final url = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items/clear?cartType=BUY');
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
      builder: (_) => _BillingFormDialog(totalAmount: totalAcquisitionCost),
    );

    if (formData == null) return;

    final authStore = Provider.of<AuthStore>(context, listen: false);
    final response = await http.post(
      Uri.parse('https://api.abcoped.shop/api/ticket/cart/items/buy/checkout'),
      headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode(formData),
    );

    if (response.statusCode == 200) {
      //final data = json.decode(response.body);
     // generateAndDownloadPdf(data);
      await authStore.fetchTicketStatusCounts();
      Navigator.pop(context); // Navigate back after opening the PDF

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout failed')),
      );
    }
  }

  void generateAndDownloadPdf(dynamic data) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Customer: ${data['customerName'] ?? ''}'),
              pw.Text('Phone: ${data['phoneNumber'] ?? ''}'),
              pw.Text('Store ID: ${data['storeId'] ?? ''}'),
              pw.SizedBox(height: 10),
              pw.Text('Items:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...((data['items'] ?? []) as List).map((item) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ${item['productName'] ?? 'Unknown'}'),
                    pw.Text('  IMEI: ${item['imeiNo'] ?? 'N/A'}'),
                    pw.Text('  Price: ₹${item['acquisitionCost'] ?? 0}'),
                    pw.SizedBox(height: 4),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );

    final bytes = await doc.save();
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'bill.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
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
      // body: isLoading
      //     ? const Center(child: CircularProgressIndicator())
      //     : cartItems.isEmpty
      //     ? const Center(child: Text('Cart is empty'))
      //     : Column(
      //   children: [
      //     Expanded(
      //       child: ListView.builder(
      //         itemCount: cartItems.length,
      //         itemBuilder: (context, index) {
      //           final item = cartItems[index];
      //           final List<dynamic> details = item['details'] ?? [];
      //
      //           return Card(
      //             margin: const EdgeInsets.all(8),
      //             child: Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   //Text('Item ID: ${item['itemId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
      //                   const Divider(),
      //                   ...details.map((detail) {
      //                     return ListTile(
      //                       title: Text(detail['productName'] ?? 'No name'),
      //                       subtitle: Column(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: [
      //                           Text('Brand: ${detail['brand']}'),
      //                           Text('IMEI: ${detail['imeiNo']}'),
      //                           Text('Battery: ${detail['batteryHealth']}'),
      //                           Text('RAM/ROM: ${detail['ramRomSpecs']}'),
      //                           Text('Color: ${detail['colorSpecs'] ?? 'N/A'}'),
      //                           Text('Acquisition Cost: ${detail['acquisitionCost'] ?? 'N/A'}'),
      //
      //                         ],
      //                       ),
      //                       trailing: IconButton(
      //                         icon: const Icon(Icons.remove_circle, color: Colors.red),
      //                         onPressed: () => removeCartItem(detail['id']),
      //                       ),
      //                     );
      //                   }).toList(),
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
      //       label: const Text('Checkout from Cart'),
      //       style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
      //     ),
      //     const SizedBox(height: 10),
      //   ],
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(child: Text('Cart is empty'))
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
                      DataColumn(label: Text("Color")),
                      DataColumn(label: Text("Acquisition Cost")),
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
                          DataCell(Text(detail['colorSpecs'] ?? 'N/A')),
                          DataCell(Text("₹${detail['acquisitionCost'] ?? 0}")),
                          DataCell(

                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_note, color: Colors.black),
                                  tooltip: "Remove Item",
                                  onPressed: () => showEditCartDialog(context, item['id'],detail['id'],item["itemId"]),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  tooltip: "Remove Item",
                                  onPressed: () => removeCartItem(detail['id']),
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
              "Total Acquisition Cost: ₹${totalAcquisitionCost.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: checkoutCart,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Checkout from Cart'),
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

    List<String> colorOptions = [];
    List<String> ramRomOptions = [];

    String? selectedColor;
    String? selectedRamRom;
    final acquisitionCostController = TextEditingController();

    // 🔹 Fetch specs from API
    try {
      final url = Uri.parse(
          "https://api.abcoped.shop/api/product/select-specs/$productMasterId");

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        colorOptions = List<String>.from(data["Color specs"] ?? []);
        ramRomOptions = List<String>.from(data["RAM-ROM specs"] ?? []);
      } else {
        print("❌ Failed to fetch specs: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching specs: $e");
    }

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
                      controller: acquisitionCostController,
                      decoration: const InputDecoration(
                        labelText: "Acquisition Cost",
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 12),

                    // Color Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedColor,
                      decoration: const InputDecoration(labelText: "Color"),
                      items: colorOptions.isNotEmpty
                          ? colorOptions
                          .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                          .toList()
                          : [
                        const DropdownMenuItem(
                            value: null, child: Text("Enter manually"))
                      ],
                      onChanged: (val) => setState(() => selectedColor = val),
                    ),

                    if (colorOptions.isEmpty)
                      TextField(
                        onChanged: (val) => selectedColor = val,
                        decoration:
                        const InputDecoration(labelText: "Enter Color"),
                      ),

                    const SizedBox(height: 12),

                    // RAM-ROM Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedRamRom,
                      decoration: const InputDecoration(labelText: "RAM-ROM"),
                      items: ramRomOptions.isNotEmpty
                          ? ramRomOptions
                          .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r)))
                          .toList()
                          : [
                        const DropdownMenuItem(
                            value: null, child: Text("Enter manually"))
                      ],
                      onChanged: (val) => setState(() => selectedRamRom = val),
                    ),

                    if (ramRomOptions.isEmpty)
                      TextField(
                        onChanged: (val) => selectedRamRom = val,
                        decoration:
                        const InputDecoration(labelText: "Enter RAM-ROM"),
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
                final acquisitionCost =
                int.tryParse(acquisitionCostController.text.trim());



                final details = [
                  {
                    "id": detailId,
                    "acquisitionCost": acquisitionCost,
                    "colorSpecs": selectedColor,
                    "ramRomSpecs": selectedRamRom,
                  }
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

    final url = Uri.parse("https://api.abcoped.shop/api/ticket/BUY/items/$cartItemId");

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
    'customerDocumentId': '',
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
                // ..._formData.keys.map((key) {
                //   return Padding(
                //     padding: const EdgeInsets.only(bottom: 10),
                //     child: TextFormField(
                //       decoration: InputDecoration(labelText: key == 'storeId'
                //           ? 'Store ID'
                //           :key == 'phoneNumber'
                //           ? 'Phone Number'
                //           : key == 'gstNumber'
                //           ? 'GST Number'
                //           : key == 'gstId'
                //           ? 'Business Name' :key == 'customerDocumentId' ? 'Customer Document Id'
                //           : key == 'customerName' ? 'Customer Name' : key == 'documentType' ? '':key),
                //       keyboardType: (key == 'storeId' ||
                //           key == 'customerAadharId')
                //           ? TextInputType.number
                //           : TextInputType.text,
                //       onChanged: (val) => _formData[key] = val.trim(),
                //       validator: (val) {
                //         if (['storeId', 'customerAadharId', 'customerName']
                //             .contains(key)) {
                //           return (val == null || val.isEmpty)
                //               ? 'Required'
                //               : null;
                //         }
                //         if (key == 'phoneNumber') {
                //           if (val == null || val.isEmpty) return 'Required';
                //           final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                //           if (!phoneRegex.hasMatch(val.trim())) return 'Enter a valid 10-digit mobile number';
                //           return null;
                //         }
                //         return null;
                //       },
                //     ),
                //   );
                // }).toList(),

                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        onChanged: (val) => _formData['phoneNumber'] = val.trim(),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                          if (!phoneRegex.hasMatch(val.trim())) return 'Enter a valid 10-digit mobile number';
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Customer Name'),
                        keyboardType: TextInputType.text,
                        onChanged: (val) => _formData['customerName'] = val.trim(),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'GST Number'),
                        keyboardType: TextInputType.text,
                        onChanged: (val) => _formData['gstNumber'] = val.trim(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Business Name'),
                        keyboardType: TextInputType.text,
                        onChanged: (val) => _formData['gstId'] = val.trim(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Customer Document Id'),
                        keyboardType: TextInputType.text,
                        onChanged: (val) => _formData['customerDocumentId'] = val.trim(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Store ID'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _formData['storeId'] = val.trim(),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Divider(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Document Type'),
                    initialValue: _formData['documentType'],
                    items: ['DRIVING_LICENSE', 'VOTER_ID', 'PAN', 'AADHAAR', 'PASSPORT']
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (val) => setState(() =>
                    _formData['documentType'] = val),

                    validator: (val) =>
                    val == null ? 'Please select a document type' : null,
                  ),
                ),
                const SizedBox(height: 10),
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

                const Text('Payment Methods',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // if (_formData['documentType'] != null)
                //   Padding(
                //     padding: const EdgeInsets.only(bottom: 10),
                //     child: TextFormField(
                //       decoration: const InputDecoration(labelText: 'Document ID'),
                //     ),
                //   ),

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
                            initialValue: payment['modeOfPayment'],
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

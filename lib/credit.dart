// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'auth.dart';
// import 'package:provider/provider.dart';
//
// class CreditPage extends StatefulWidget {
//   const CreditPage({Key? key}) : super(key: key);
//
//   @override
//   State<CreditPage> createState() => _CreditPageState();
// }
//
// class _CreditPageState extends State<CreditPage> {
//   late Future<Map<String, List<dynamic>>> _futureCredits;
//   final List<String> paymentModes = [
//     'CASH',
//     'CARD',
//     'CHEQUE',
//     'NET_BANKING',
//     'UPI',
//     'CREDIT'
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _futureCredits = fetchCredits();
//   }
//
//   Future<Map<String, List<dynamic>>> fetchCredits() async {
//     final authStore = Provider.of<AuthStore>(context, listen: false);
//     const invoiceUrl = 'https://api.abcoped.shop/api/payments/invoice/credit';
//     const buyUrl = 'https://api.abcoped.shop/api/payments/bill/credit';
//
//     try {
//       final invoiceRes = await http.get(
//         Uri.parse(invoiceUrl),
//         headers: {
//           'Authorization': 'Bearer ${authStore.token}',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       final buyRes = await http.get(
//         Uri.parse(buyUrl),
//         headers: {
//           'Authorization': 'Bearer ${authStore.token}',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (invoiceRes.statusCode != 200 || buyRes.statusCode != 200) {
//         throw Exception('Failed to load data');
//       }
//
//       final invoiceData = jsonDecode(invoiceRes.body) as List<dynamic>;
//       final buyData = jsonDecode(buyRes.body) as List<dynamic>;
//
//       return {
//         'invoiceCredit': invoiceData,
//         'buyCredit': buyData,
//       };
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }
//
//   Future<void> repayCredit({
//     required String creditType,
//     required int id,
//     required int invoiceOrBillId,
//     required int ticketId,
//     required String modeOfPayment,
//     required String customerName,
//     required double amount,
//     required String transactionId,
//   }) async {
//     final authStore = Provider.of<AuthStore>(context, listen: false);
//
//     const repayUrl =
//         'https://api.abcoped.shop/api/payments/credit/invoice/repayment';
//
//     final body = {
//       "creditType": 'BUY',
//       "id": id,
//       "invoiceOrBillId": invoiceOrBillId,
//       "ticketId": ticketId,
//       "modeOfPayment": modeOfPayment,
//       "customerName": customerName,
//       "amount": amount,
//       "transactionId": transactionId
//     };
//
//     final res = await http.post(
//       Uri.parse(repayUrl),
//       headers: {
//         'Authorization': 'Bearer ${authStore.token}',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(body),
//     );
//
//     if (res.statusCode != 200) {
//       throw Exception('Failed to update payment: ${res.body}');
//     }
//   }
//
//   Future<void> repayCreditBill({
//     required String creditType,
//     required int id,
//     required int invoiceOrBillId,
//     required int ticketId,
//     required String modeOfPayment,
//     required String customerName,
//     required double amount,
//     required String transactionId,
//   }) async {
//     final authStore = Provider.of<AuthStore>(context, listen: false);
//
//     const repayUrl =
//         'https://api.abcoped.shop/api/payments/credit/bill/repayment';
//
//     final body = {
//       "creditType": 'SELL',
//       "id": id,
//       "invoiceOrBillId": invoiceOrBillId,
//       "ticketId": ticketId,
//       "modeOfPayment": modeOfPayment,
//       "customerName": customerName,
//       "amount": amount,
//       "transactionId": transactionId
//     };
//
//     final res = await http.post(
//       Uri.parse(repayUrl),
//       headers: {
//         'Authorization': 'Bearer ${authStore.token}',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(body),
//     );
//
//     if (res.statusCode != 200) {
//       throw Exception('Failed to update payment: ${res.body}');
//     }
//   }
//
//   void _showEditDialog(Map<String, dynamic> credit, bool isInvoice) {
//     final formKey = GlobalKey<FormState>();
//     String selectedMode = paymentModes.first;
//     String customerName = credit["customerName"] ?? "";
//     String transactionId = "";
//     String amountStr = "";
//
//     // In case there are multiple products, pick the first ticketId
//     int ticketId = (credit["products"] as List).isNotEmpty
//         ? credit["products"][0]["ticketId"]
//         : 0;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Edit Payment"),
//           content: Form(
//             key: formKey,
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Text(
//                     'Remaining Credit: ${credit["remainingCredit"]}',
//                   ),
//                   DropdownButtonFormField<String>(
//                     value: selectedMode,
//                     items: paymentModes
//                         .map((m) => DropdownMenuItem(
//                       value: m,
//                       child: Text(m),
//                     ))
//                         .toList(),
//                     onChanged: (val) {
//                       if (val != null) {
//                         selectedMode = val;
//                       }
//                     },
//                     decoration:
//                     const InputDecoration(labelText: "Mode of Payment"),
//                   ),
//                   TextFormField(
//                     initialValue: customerName,
//                     decoration:
//                     const InputDecoration(labelText: "Customer Name"),
//                     validator: (val) =>
//                     val == null || val.isEmpty ? "Required" : null,
//                     onChanged: (val) => customerName = val,
//                   ),
//                   TextFormField(
//                     decoration:
//                     const InputDecoration(labelText: "Transaction ID"),
//                     onChanged: (val) => transactionId = val,
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(labelText: "Amount"),
//                     keyboardType: TextInputType.number,
//                     validator: (val) {
//                       if (val == null || val.isEmpty) return "Required";
//                       if (double.tryParse(val) == null) {
//                         return "Invalid number";
//                       }
//                       return null;
//                     },
//                     onChanged: (val) => amountStr = val,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: const Text("Cancel"),
//               onPressed: () => Navigator.pop(context),
//             ),
//             ElevatedButton(
//               child: const Text("Save"),
//               onPressed: () async {
//                 if (formKey.currentState!.validate()) {
//                   try {
//                     isInvoice ?  await repayCredit(
//                       creditType: isInvoice ? "INVOICE" : "BUY",
//                       id: credit["id"] ?? credit["billId"] ?? credit["invoiceId"],
//                       invoiceOrBillId: isInvoice
//                           ? credit["invoiceId"]
//                           : credit["billId"],
//                       ticketId: ticketId,
//                       modeOfPayment: selectedMode,
//                       customerName: customerName,
//                       amount: double.parse(amountStr),
//                       transactionId: transactionId,
//                     ) : await repayCreditBill(
//                       creditType: isInvoice ? "INVOICE" : "BUY",
//                       id: credit["id"] ?? credit["billId"] ?? credit["invoiceId"],
//                       invoiceOrBillId: isInvoice
//                           ? credit["invoiceId"]
//                           : credit["billId"],
//                       ticketId: ticketId,
//                       modeOfPayment: selectedMode,
//                       customerName: customerName,
//                       amount: double.parse(amountStr),
//                       transactionId: transactionId,
//                     );
//                     Navigator.pop(context);
//                     setState(() {
//                       _futureCredits = fetchCredits();
//                     });
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text(e.toString())),
//                     );
//                   }
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildCreditCard(Map<String, dynamic> credit) {
//     final isInvoice = credit.containsKey("invoiceId");
//     final id = isInvoice ? credit["invoiceId"] : credit["billId"];
//     final date = isInvoice ? credit["invoiceDate"] : credit["billDate"];
//     final titlePrefix = isInvoice ? "Invoice" : "Bill";
//
//
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       child: ExpansionTile(
//         title: Text(
//           '$titlePrefix #$id',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           'Remaining Credit: ${credit["remainingCredit"]}, Date: $date',
//         ),
//         trailing: IconButton(
//           icon: const Icon(Icons.edit),
//           onPressed: () => _showEditDialog(credit, isInvoice),
//         ),
//         children: [
//           if (!isInvoice) ...[
//
//             ListTile(
//               title: const Text("Customer"),
//               subtitle: Text(
//                 "${credit["customerName"] ?? ""} (${credit["phoneNumber"] ?? ""})",
//               ),
//             ),
//             ListTile(
//               title: const Text("GST Details"),
//               subtitle: Text(
//                 "GST No: ${credit["gstNumber"] ?? ""}, GST ID: ${credit["gstId"] ?? ""}",
//               ),
//             ),
//             ListTile(
//               title: const Text("Sale Info"),
//               subtitle: Text(
//                 "Place: ${credit["placeOfSale"] ?? ""}, Profit: ${credit["profit"] ?? 0}",
//               ),
//             ),
//           ],
//           ListTile(
//             title: const Text('Products'),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: (credit["products"] as List<dynamic>).map((p) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Text(
//                     '${p["productName"]} (${p["brand"]}) - '
//                         '${p["ramRomSpecs"] ?? ""}, ${p["colorSpecs"] ?? ""}',
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           ListTile(
//             title: const Text('Payments'),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: (credit["payments"] as List<dynamic>).map((pay) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 2),
//                   child: Text(
//                     '${pay["modeOfPayment"]}: ${pay["amount"]} on ${pay["paidAt"]}',
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Credit Details'),
//       ),
//       body: FutureBuilder<Map<String, List<dynamic>>>(
//         future: _futureCredits,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text(snapshot.error.toString()));
//           }
//
//           final invoiceCredits = snapshot.data?['invoiceCredit'] ?? [];
//           final buyCredits = snapshot.data?['buyCredit'] ?? [];
//
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Text(
//                     'Invoice Credit',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 ...invoiceCredits.map((c) =>
//                     _buildCreditCard(c as Map<String, dynamic>)),
//                 const Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Text(
//                     'Buy Credit',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 ...buyCredits.map((c) =>
//                     _buildCreditCard(c as Map<String, dynamic>)),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth.dart';
import 'package:provider/provider.dart';

class CreditPage extends StatefulWidget {
  const CreditPage({Key? key}) : super(key: key);

  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  late Future<Map<String, List<dynamic>>> _futureCredits;
  final List<String> paymentModes = [
    'CASH',
    'CARD',
    'CHEQUE',
    'NET_BANKING',
    'UPI',
    'CREDIT'
  ];

  // Search controllers
  final TextEditingController _searchIdController = TextEditingController();
  final TextEditingController _searchCustomerController = TextEditingController();
  String? searchId;
  String? searchCustomer;

  @override
  void initState() {
    super.initState();
    _futureCredits = fetchCredits();
  }

  Future<Map<String, List<dynamic>>> fetchCredits() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    const invoiceUrl = 'https://api.abcoped.shop/api/payments/invoice/credit';
    const buyUrl = 'https://api.abcoped.shop/api/payments/bill/credit';

    try {
      final invoiceRes = await http.get(
        Uri.parse(invoiceUrl),
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Content-Type': 'application/json',
        },
      );

      final buyRes = await http.get(
        Uri.parse(buyUrl),
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Content-Type': 'application/json',
        },
      );

      if (invoiceRes.statusCode != 200 || buyRes.statusCode != 200) {
        throw Exception('Failed to load data');
      }

      final invoiceData = jsonDecode(invoiceRes.body) as List<dynamic>;
      final buyData = jsonDecode(buyRes.body) as List<dynamic>;

      return {
        'invoiceCredit': invoiceData,
        'buyCredit': buyData,
      };
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ---- KEEPING YOUR REPAY FUNCTIONS INTACT ----
  Future<void> repayCredit({
    required String creditType,
    required int id,
    required int invoiceOrBillId,
    required int ticketId,
    required String modeOfPayment,
    required String customerName,
    required double amount,
    required String transactionId,
  }) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);

    const repayUrl =
        'https://api.abcoped.shop/api/payments/credit/invoice/repayment';

    final body = {
      "creditType": 'BUY',
      "id": id,
      "invoiceOrBillId": invoiceOrBillId,
      "ticketId": ticketId,
      "modeOfPayment": modeOfPayment,
      "customerName": customerName,
      "amount": amount,
      "transactionId": transactionId
    };

    final res = await http.post(
      Uri.parse(repayUrl),
      headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update payment: ${res.body}');
    }
  }

  Future<void> repayCreditBill({
    required String creditType,
    required int id,
    required int invoiceOrBillId,
    required int ticketId,
    required String modeOfPayment,
    required String customerName,
    required double amount,
    required String transactionId,
  }) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);

    const repayUrl =
        'https://api.abcoped.shop/api/payments/credit/bill/repayment';

    final body = {
      "creditType": 'SELL',
      "id": id,
      "invoiceOrBillId": invoiceOrBillId,
      "ticketId": ticketId,
      "modeOfPayment": modeOfPayment,
      "customerName": customerName,
      "amount": amount,
      "transactionId": transactionId
    };

    final res = await http.post(
      Uri.parse(repayUrl),
      headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update payment: ${res.body}');
    }
  }
  // ---- END OF YOUR REPAY FUNCTIONS ----

  // ========== ADDED: CHECK INVOICE / BILL ==========
  Future<void> _checkInvoice(int invoiceId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final url = 'https://api.abcoped.shop/api/invoice/check-invoice/$invoiceId';
    try {
      final res = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      });
      if (res.statusCode != 200) {
        throw Exception('Failed to fetch invoice details: ${res.body}');
      }
      final data = jsonDecode(res.body);
      _showInfoDialog('Invoice #$invoiceId', data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _checkBill(int billId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final url = 'https://api.abcoped.shop/api/bill/check-bill/$billId';
    try {
      final res = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      });
      if (res.statusCode != 200) {
        throw Exception('Failed to fetch bill details: ${res.body}');
      }
      final data = jsonDecode(res.body);
      _showInfoDialog('Bill #$billId', data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showInfoDialog(String title, dynamic data) {
    final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: SelectableText(
            prettyJson,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }
  // =================================================

  List<dynamic> _applyFilters(List<dynamic> data, bool isInvoice) {
    return data.where((item) {
      final id = isInvoice ? item['invoiceId'].toString() : item['billId'].toString();
      final customer = (item['customerName'] ?? "").toString();

      final matchesId = searchId == null || searchId!.isEmpty || id.contains(searchId!);
      final matchesCustomer = searchCustomer == null || searchCustomer!.isEmpty ||
          customer.toLowerCase().contains(searchCustomer!.toLowerCase());

      return matchesId && matchesCustomer;
    }).toList();
  }
  void _showDetailsDialog(Map<String, dynamic> credit, String type) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Payment Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),
                if (credit['payments'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Payments:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...List.generate(
                        credit['payments'].length,
                            (i) {
                          final p = credit['payments'][i];
                          //return  Text("- ${p['modeOfPayment']} : ${p['amount']}");
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("- ${p['modeOfPayment']} : ${p['amount']}"),
                              if (p['paidAt'] != null && p['paidAt'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text("  Paid At: ${p['paidAt']}"),
                                ),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
          ],
        );
      },
    );
  }


  Widget _buildTable(List<dynamic> data, bool isInvoice) {
    final filteredData = _applyFilters(data, isInvoice);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey[300]),
        columns: const [
          DataColumn(label: Text("ID")),
          DataColumn(label: Text("Customer")),
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("Remaining Credit")),
          DataColumn(label: Text("Action")),
        ],
        rows: filteredData.map((credit) {
          final id = isInvoice ? credit['invoiceId'] : credit['billId'];
          final date = isInvoice ? credit['invoiceDate'] : credit['billDate'];
          final customer = credit['customerName'] ?? '';
          final remaining = credit['remainingCredit'] ?? 0;

          return DataRow(cells: [
            DataCell(Text(id.toString())),
            DataCell(Text(customer)),
            DataCell(Text(date.toString())),
            DataCell(Text(remaining.toString())),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ADDED: Info button
                  IconButton(
                    tooltip: 'View Details',
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showDetailsDialog(credit, isInvoice ? "Invoice" : "Bill");
                    },
                  ),
                  // Existing edit (repay) button
                  IconButton(
                    tooltip: 'Repay',
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(credit, isInvoice),
                  ),
                ],
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> credit, bool isInvoice) {
    final formKey = GlobalKey<FormState>();
    String selectedMode = paymentModes.first;
    String customerName = credit["customerName"] ?? "";
    String transactionId = "";
    String amountStr = "";

    int ticketId = (credit["products"] as List).isNotEmpty
        ? credit["products"][0]["ticketId"]
        : 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Repay Credit"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text('Remaining Credit: ${credit["remainingCredit"]}'),
                  DropdownButtonFormField<String>(
                    value: selectedMode,
                    items: paymentModes
                        .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m),
                    ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        selectedMode = val;
                      }
                    },
                    decoration: const InputDecoration(labelText: "Mode of Payment"),
                  ),
                  TextFormField(
                    initialValue: customerName,
                    decoration: const InputDecoration(labelText: "Customer Name"),
                    onChanged: (val) => customerName = val,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Transaction ID"),
                    onChanged: (val) => transactionId = val,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Amount"),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Required";
                      if (double.tryParse(val) == null) return "Invalid number";
                      return null;
                    },
                    onChanged: (val) => amountStr = val,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    if (isInvoice) {
                      await repayCredit(
                        creditType: "INVOICE",
                        id: credit["id"] ?? credit["invoiceId"],
                        invoiceOrBillId: credit["invoiceId"],
                        ticketId: ticketId,
                        modeOfPayment: selectedMode,
                        customerName: customerName,
                        amount: double.parse(amountStr),
                        transactionId: transactionId,
                      );
                    } else {
                      await repayCreditBill(
                        creditType: "BILL",
                        id: credit["id"] ?? credit["billId"],
                        invoiceOrBillId: credit["billId"],
                        ticketId: ticketId,
                        modeOfPayment: selectedMode,
                        customerName: customerName,
                        amount: double.parse(amountStr),
                        transactionId: transactionId,
                      );
                    }
                    Navigator.pop(context);
                    setState(() {
                      _futureCredits = fetchCredits();
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Credit Details')),
      body: Column(
        children: [
          // 🔎 Search Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchIdController,
                    decoration: const InputDecoration(
                      labelText: "Invoice/Bill ID",
                    ),
                    onChanged: (val) {
                      setState(() => searchId = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchCustomerController,
                    decoration: const InputDecoration(
                      labelText: "Customer Name",
                    ),
                    onChanged: (val) {
                      setState(() => searchCustomer = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchIdController.clear();
                      _searchCustomerController.clear();
                      searchId = null;
                      searchCustomer = null;
                    });
                  },
                  child: const Text("Clear"),
                )
              ],
            ),
          ),

          // 📋 Data Table
          Expanded(
            child: FutureBuilder<Map<String, List<dynamic>>>(
              future: _futureCredits,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final invoiceCredits = snapshot.data?['invoiceCredit'] ?? [];
                final buyCredits = snapshot.data?['buyCredit'] ?? [];

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Invoice Credits',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildTable(invoiceCredits, true),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Buy Credits',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildTable(buyCredits, false),
                    ],
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

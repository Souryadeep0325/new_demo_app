import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth.dart';
import 'package:provider/provider.dart';

class InvoiceCreditPage extends StatefulWidget {
  const InvoiceCreditPage({Key? key}) : super(key: key);

  @override
  State<InvoiceCreditPage> createState() => _InvoiceCreditPageState();
}

class _InvoiceCreditPageState extends State<InvoiceCreditPage> {
  late Future<List<dynamic>> _futureCredits;
  final List<String> paymentModes = [
    'CASH', 'CARD', 'CHEQUE', 'NET_BANKING', 'UPI', 'CREDIT'
  ];

  @override
  void initState() {
    super.initState();
    _futureCredits = fetchInvoiceCredits();
  }

  Future<List<dynamic>> fetchInvoiceCredits() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    const url = 'https://api.abcoped.shop/api/payments/invoice/credit';

    final res = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load invoice credits');
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<void> repayCredit({
    required int id,
    required int invoiceId,
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
      "invoiceOrBillId": invoiceId,
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

  void _showEditDialog(Map<String, dynamic> credit) {
    final formKey = GlobalKey<FormState>();
    String selectedMode = paymentModes.first;
    String transactionId = "";
    String amountStr = "";
    String customerName = credit["customerName"] ?? "";
    int ticketId = (credit["products"] as List).isNotEmpty
        ? credit["products"][0]["ticketId"]
        : 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Repay Invoice Credit"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedMode,
                items: paymentModes
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => selectedMode = val!,
                decoration:
                const InputDecoration(labelText: "Mode of Payment"),
              ),
              TextFormField(
                initialValue: customerName,
                decoration:
                const InputDecoration(labelText: "Customer Name"),
                validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
                onChanged: (val) => customerName = val,
              ),
              TextFormField(
                decoration:
                const InputDecoration(labelText: "Transaction ID"),
                onChanged: (val) => transactionId = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Required";
                  if (double.tryParse(val) == null) {
                    return "Invalid number";
                  }
                  return null;
                },
                onChanged: (val) => amountStr = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await repayCredit(
                  id: credit["id"],
                  invoiceId: credit["invoiceId"],
                  ticketId: ticketId,
                  modeOfPayment: selectedMode,
                  customerName: customerName,
                  amount: double.parse(amountStr),
                  transactionId: transactionId,
                );
                Navigator.pop(context);
                setState(() {
                  _futureCredits = fetchInvoiceCredits();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice Credits")),
      body: FutureBuilder<List<dynamic>>(
        future: _futureCredits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final credits = snapshot.data ?? [];
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Invoice ID")),
                DataColumn(label: Text("Customer")),
                DataColumn(label: Text("Remaining")),
                DataColumn(label: Text("Action")),
              ],
              rows: credits.map((c) {
                final credit = c as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text("${credit['invoiceId']}")),
                  DataCell(Text(credit['customerName'] ?? "")),
                  DataCell(Text("${credit['remainingCredit']}")),
                  DataCell(
                    ElevatedButton(
                      onPressed: () => _showEditDialog(credit),
                      child: const Text("Repay"),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class BillCreditPage extends StatefulWidget {
  const BillCreditPage({Key? key}) : super(key: key);

  @override
  State<BillCreditPage> createState() => _BillCreditPageState();
}

class _BillCreditPageState extends State<BillCreditPage> {
  List<dynamic> billCredits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBillCredits();
  }

  Future<void> fetchBillCredits() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);

    const url = "https://api.abcoped.shop/api/payments/bill/credit"; // 👈 Replace with your actual GET endpoint
    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer ${authStore.token}'},
    );

    if (res.statusCode == 200) {
      setState(() {
        billCredits = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception('Failed to load bill credits');
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
      "creditType": creditType,
      "id": id,
      "invoiceOrBillId": invoiceOrBillId,
      "ticketId": ticketId,
      "modeOfPayment": modeOfPayment,
      "customerName": customerName,
      "amount": amount,
      "transactionId": transactionId,
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
      throw Exception('Failed to update bill repayment: ${res.body}');
    }
  }

  void showRepayDialog(Map<String, dynamic> credit) {
    final modes = ['CASH', 'CARD', 'CHEQUE', 'NET_BANKING', 'UPI', 'CREDIT'];
    String selectedMode = modes.first;
    final customerCtrl = TextEditingController(text: credit['customerName']);
    final amountCtrl = TextEditingController(text: credit['amount'].toString());
    final transactionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Repay Bill Credit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedMode,
              items: modes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => selectedMode = val!,
              decoration: const InputDecoration(labelText: "Mode of Payment"),
            ),
            TextField(
              controller: customerCtrl,
              decoration: const InputDecoration(labelText: "Customer Name"),
            ),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: transactionCtrl,
              decoration: const InputDecoration(labelText: "Transaction ID"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text("Submit"),
            onPressed: () async {
              await repayCreditBill(
                creditType: "SELL",
                id: credit['id'],
                invoiceOrBillId: credit['invoiceOrBillId'],
                ticketId: credit['ticketId'],
                modeOfPayment: selectedMode,
                customerName: customerCtrl.text,
                amount: double.tryParse(amountCtrl.text) ?? 0,
                transactionId: transactionCtrl.text,
              );
              Navigator.pop(ctx);
              fetchBillCredits();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bill Credits")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("ID")),
            DataColumn(label: Text("Bill ID")),
            DataColumn(label: Text("Ticket ID")),
            DataColumn(label: Text("Customer")),
            DataColumn(label: Text("Amount")),
            DataColumn(label: Text("Actions")),
          ],
          rows: billCredits.map((credit) {
            return DataRow(cells: [
              DataCell(Text("${credit['id']}")),
              DataCell(Text("${credit['invoiceOrBillId']}")),
              DataCell(Text("${credit['ticketId']}")),
              DataCell(Text("${credit['customerName']}")),
              DataCell(Text("${credit['amount']}")),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => showRepayDialog(credit),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}



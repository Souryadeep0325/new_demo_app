import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
import 'auth.dart';
import 'widgets/custom_dialog.dart';

class TicketListPageSold extends StatefulWidget {
  const TicketListPageSold({super.key});

  @override
  State<TicketListPageSold> createState() => _TicketListPageSoldState();
}

class _TicketListPageSoldState extends State<TicketListPageSold> {
  List<dynamic> tickets = [];
  bool isLoading = true;
  double gstAmount = 0.0;
  double cgstAmount = 0.0;
  double sgstAmount = 0.0;
  double margin = 0;

  double totalInvoiceValue = 0.0;
  double outputTax = 0.0;
  double inputTax = 0.0;
  double saleGstValue =0 ;
  double outputTaxableValue =0;
  bool isNewPhone = true;
  bool isITCClaimable = true;
  double taxToGovt = 0;

  TextEditingController productNameController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('https://api.abcoped.shop/api/ticket/search-ticket/SOLD');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          tickets = json.decode(response.body);
          isLoading = false;
        });
      } else {
        showError('Failed to fetch tickets. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('An error occurred: $e');
    }
  }

  Future<void> showTicketInfo(int ticketId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('https://api.abcoped.shop/api/ticket/check-bill/$ticketId');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Accept': 'application/json',
        },
      );
      Navigator.pop(context); // Remove loading
      if (response.statusCode == 200) {
        final bill = json.decode(response.body);
        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            title: 'Bill Details',
            maxWidth: 500,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoSection(
                    title: 'Customer Information',
                    rows: [
                      InfoRow(label: 'Customer Name', value: bill['customerName'] ?? 'N/A'),
                      InfoRow(label: 'Phone Number', value: bill['phoneNumber'] ?? 'N/A'),
                      if (bill['gstId'] != null && bill['gstId'].toString().isNotEmpty)
                        InfoRow(label: 'GST ID', value: bill['gstId']),
                    ],
                  ),
                  InfoSection(
                    title: 'Bill Information',
                    rows: [
                      InfoRow(label: 'Bill Number', value: bill['billNumber'] ?? 'N/A', copyable: true, isHighlighted: true),
                      InfoRow(label: 'Bill Date', value: bill['billDate'] ?? 'N/A'),
                    ],
                  ),
                  InfoSection(
                    title: 'Payment Details',
                    rows: [
                      InfoRow(label: 'Mode of Payment', value: bill['modeOfPayment'] ?? 'N/A'),
                      if (bill['onlineTrxId'] != null && bill['onlineTrxId'].toString().isNotEmpty)
                        InfoRow(label: 'Online Trx ID', value: bill['onlineTrxId']),
                      InfoRow(label: 'Place of Sale', value: bill['placeOfSale'] ?? 'N/A'),
                    ],
                  ),
                  InfoSection(
                    title: 'Financial Details',
                    hasDivider: false,
                    rows: [
                      InfoRow(label: 'Profit', value: bill['profit'] != null ? '\u20b9${bill['profit']}' : 'N/A', isHighlighted: true),
                      InfoRow(label: 'Client ID', value: bill['clientId']?.toString() ?? 'N/A'),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              DialogButton(
                label: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
              DialogButton(
                label: 'Download PDF',
                isPrimary: true,
                onPressed: () {/* TODO: Implement PDF download */},
                icon: Icons.download,
              ),
            ],
          ),
        );
      } else {
        showError('Failed to fetch ticket bill. Status: \\${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context); // Remove loading
      showError('Error fetching ticket bill: $e');
    }
  }

  // Future<void> generatePdf(Map<String, dynamic> bill) async {
  //   final pdf = pw.Document();
  //
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text('Bill Details', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
  //             pw.SizedBox(height: 16),
  //             buildPdfRow('Customer Name', bill['customerName']),
  //             buildPdfRow('Phone Number', bill['phoneNumber']),
  //             buildPdfRow('GST ID', bill['gstId']),
  //             buildPdfRow('Bill Number', bill['billNumber']),
  //             buildPdfRow('Bill Date', bill['billDate']),
  //             buildPdfRow('Mode of Payment', bill['modeOfPayment']),
  //             if (bill['onlineTrxId'] != null && bill['onlineTrxId'].toString().isNotEmpty)
  //               buildPdfRow('Online Trx ID', bill['onlineTrxId']),
  //             buildPdfRow('Place of Sale', bill['placeOfSale']),
  //             buildPdfRow('Profit', "₹${bill['profit']}"),
  //             buildPdfRow('Client ID', bill['clientId'].toString()),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => pdf.save(),
  //     name: 'bill_${bill['billNumber']}.pdf',
  //   );
  // }
  //
  // pw.Widget buildPdfRow(String label, String value) {
  //   return pw.Padding(
  //     padding: const pw.EdgeInsets.symmetric(vertical: 4),
  //     child: pw.Row(
  //       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //       children: [
  //         pw.Text('$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //         pw.Expanded(child: pw.Text(value)),
  //       ],
  //     ),
  //   );
  // }

  Future<void> showTicketDetails(int ticketId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('https://api.abcoped.shop/api/ticket/check-ticket/$ticketId');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final ticket = json.decode(response.body);
        final totalCost = ticket['refurbishedCost'] != null &&
            ticket['refurbishedCost'] != 0
            ? ticket['acquisitionCost'] + ticket['refurbishedCost']
            : ticket['acquisitionCost'];

        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            title: 'Ticket Details',
            maxWidth: 500,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoSection(
                  title: 'Product Information',
                  rows: [
                    InfoRow(
                      label: 'Product Name',
                      value: ticket['productName'],
                    ),
                    InfoRow(
                      label: 'New Phone',
                      value: ticket['sealedFlag'] == 'Y' ? 'Yes' : 'No',
                      isHighlighted: true,
                    ),
                  ],
                ),
                InfoSection(
                  title: 'Cost Details',
                  rows: [
                    InfoRow(
                      label: 'Acquisition Cost',
                      value: '₹${ticket['acquisitionCost']}',
                    ),
                    InfoRow(
                      label: 'Refurbished Cost',
                      value: ticket['refurbishedCost'] != null ? '₹${ticket['refurbishedCost']}' : 'N/A',
                    ),
                    InfoRow(
                      label: 'Total Cost',
                      value: '₹$totalCost',
                      isHighlighted: true,
                    ),
                  ],
                ),
                if (ticket['comment'] != null && ticket['comment'].toString().isNotEmpty)
                  InfoSection(
                    title: 'Additional Information',
                    hasDivider: false,
                    rows: [
                      InfoRow(
                        label: 'Comment',
                        value: ticket['comment'],
                      ),
                    ],
                  ),
              ],
            ),
            actions: [
              DialogButton(
                label: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        showError('Failed to fetch ticket details. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error fetching ticket details: $e');
    }
  }

  Future<void> showGstDetails(int ticketId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('https://api.abcoped.shop/api/ticket/check-ticket/$ticketId');
    late final totalCost;
    late final totalSellingCost;
    late final isNew;
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final ticket = json.decode(response.body);
        totalCost =ticket['refurbishedCost']!= null &&
            ticket['refurbishedCost']!=0? ticket['acquisitionCost'] + ticket['refurbishedCost'] :ticket['acquisitionCost'];
      isNew = ticket['sealedFlag'];
      } else {
        showError('Failed to fetch ticket details. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error fetching ticket details: $e');
    }

    final url = Uri.parse('https://api.abcoped.shop/api/ticket/check-bill/$ticketId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final bill = json.decode(response.body);
        final profit =  bill["profit"];
        totalSellingCost = totalCost + profit;


      } else {
        showError('Failed to fetch ticket bill. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error fetching ticket bill: $e');
    }
    if(isNew == 'Y')
      {
        _calculateGST(totalCost, totalSellingCost, totalSellingCost-totalCost, 'Y');

        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            title: 'GST Details (New Phone)',
            maxWidth: 500,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoSection(
                  title: 'Product Status',
                  rows: [
                    InfoRow(
                      label: 'New Phone',
                      value: isNew,
                      isHighlighted: true,
                    ),
                  ],
                ),
                InfoSection(
                  title: 'Cost Information',
                  rows: [
                    InfoRow(
                      label: 'Total Cost',
                      value: '₹${totalCost.toStringAsFixed(2)}',
                    ),
                    InfoRow(
                      label: 'Selling Price',
                      value: '₹${totalSellingCost.toStringAsFixed(2)}',
                    ),
                    InfoRow(
                      label: 'Profit Margin',
                      value: '₹${margin.toStringAsFixed(2)}',
                      isHighlighted: true,
                    ),
                  ],
                ),
                InfoSection(
                  title: 'GST Details',
                  hasDivider: false,
                  rows: [
                    InfoRow(
                      label: 'Applicable GST on Margin',
                      value: '₹${taxToGovt.toStringAsFixed(2)}',
                      isHighlighted: true,
                    ),
                    InfoRow(
                      label: 'HSN Code',
                      value: '8517',
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              DialogButton(
                label: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );

      }

    else
      {
        _calculateGST(totalCost, totalSellingCost, totalSellingCost-totalCost, 'N');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('GST Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("New Phone: $isNew"),
                Text("Acquisition Cost: ₹$totalCost"),
                Text("Selling Price: ₹$totalSellingCost"),
                Text("Profit Margin: ₹${totalSellingCost - totalCost}"),
                Text("GST on Margin (18%): ₹${taxToGovt.toStringAsFixed(2)}"),
                Text("HSN Code: 8517"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );

      }
  }



  void _calculateGST( double taxableValue,double outputInvoiceValue,double profitMargin,String isNewPhone) {

    final double cp = taxableValue;
    final double sp = outputInvoiceValue;

    // Calculate taxable value for new phones
    if (isNewPhone == 'Y') {
      totalInvoiceValue = ((18/100)*taxableValue) + taxableValue;
      gstAmount = totalInvoiceValue - taxableValue;

      // ITC is available for new phones
      cgstAmount = gstAmount / 2; // 9% CGST and 9% SGST for ITC
      sgstAmount = cgstAmount;
      // Output tax for new phones
      inputTax = gstAmount;
      outputTaxableValue = (outputInvoiceValue*100)/(100+18);
      saleGstValue = outputInvoiceValue - outputTaxableValue;

      outputTax = saleGstValue;
      taxToGovt = outputTax >= inputTax ? outputTax - inputTax : 0;

    }
    else {
      margin = profitMargin == 0 ? sp - cp : profitMargin;

      taxToGovt = margin >= 0 ? (18 / 100) * margin : 0;
    }
    }

  void showError(String message) {
    setState(() => isLoading = false);
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Error',
        maxWidth: 400,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          DialogButton(
            label: 'OK',
            isPrimary: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: productNameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dateFrom ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => dateFrom = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date From'),
                child: Text(dateFrom != null ? dateFrom!.toIso8601String().split('T').first : 'Select date'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dateTo ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => dateTo = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date To'),
                child: Text(dateTo != null ? dateTo!.toIso8601String().split('T').first : 'Select date'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              // Implement filter logic here
              setState(() {});
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: buildSearchSection(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Ticket ID')),
                                  DataColumn(label: Text('Product Name')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Cost')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: tickets.map((ticket) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(ticket['ticketId']?.toString() ?? '')),
                                      DataCell(Text(ticket['productName'] ?? '')),
                                      DataCell(Text(ticket['status'] ?? '')),
                                      DataCell(Text(ticket['date'] ?? '')),
                                      DataCell(Text(ticket['cost']?.toString() ?? '')),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility),
                                            tooltip: 'View',
                                            onPressed: () => showTicketInfo(ticket['ticketId']),
                                          ),
                                        ],
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
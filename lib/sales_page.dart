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

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final bill = json.decode(response.body);

        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            title: 'Bill Details',
            maxWidth: 500,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoSection(
                  title: 'Customer Information',
                  rows: [
                    InfoRow(
                      label: 'Customer Name',
                      value: bill['customerName'],
                    ),
                    InfoRow(
                      label: 'Phone Number',
                      value: bill['phoneNumber'],
                    ),
                    if (bill['gstId'] != null && bill['gstId'].toString().isNotEmpty)
                      InfoRow(
                        label: 'GST ID',
                        value: bill['gstId'],
                      ),
                  ],
                ),
                InfoSection(
                  title: 'Bill Information',
                  rows: [
                    InfoRow(
                      label: 'Bill Number',
                      value: bill['billNumber'],
                      isHighlighted: true,
                    ),
                    InfoRow(
                      label: 'Bill Date',
                      value: bill['billDate'],
                    ),
                  ],
                ),
                InfoSection(
                  title: 'Payment Details',
                  rows: [
                    InfoRow(
                      label: 'Mode of Payment',
                      value: bill['modeOfPayment'],
                    ),
                    if (bill['onlineTrxId'] != null && bill['onlineTrxId'].toString().isNotEmpty)
                      InfoRow(
                        label: 'Online Trx ID',
                        value: bill['onlineTrxId'],
                      ),
                    InfoRow(
                      label: 'Place of Sale',
                      value: bill['placeOfSale'],
                    ),
                  ],
                ),
                InfoSection(
                  title: 'Financial Details',
                  hasDivider: false,
                  rows: [
                    InfoRow(
                      label: 'Profit',
                      value: '₹${bill['profit']}',
                      isHighlighted: true,
                    ),
                    InfoRow(
                      label: 'Client ID',
                      value: bill['clientId'].toString(),
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
              DialogButton(
                label: 'Download PDF',
                isPrimary: true,
                onPressed: () => {},
                icon: Icons.download,
              ),
            ],
          ),
        );
      } else {
        showError('Failed to fetch ticket bill. Status: ${response.statusCode}');
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sold List")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          final ticketId = ticket['ticketId'];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text("Item ID: ${ticket['itemId']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ticket ID: $ticketId"),
                  Text("Purchase Type: ${ticket['productPurchaseType']}"),
                  Text("Invoice Date: ${ticket['invoiceDate']}"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.info_outline),
                        label: const Text("Check Bill"),
                        onPressed: () => showTicketInfo(ticketId),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.info_outline),
                        label: const Text("Check Ticket"),
                        onPressed: () => showTicketDetails(ticketId),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.calculate),
                        label: const Text("Check GST"),
                        onPressed: () => showGstDetails(ticketId),
                      ),
                    ],

                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
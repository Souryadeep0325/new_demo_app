//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:excel/excel.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
//
// import 'auth.dart';
//
// class CustomerInvoicesPage extends StatefulWidget {
//   const CustomerInvoicesPage({Key? key}) : super(key: key);
//
//   @override
//   State<CustomerInvoicesPage> createState() => _CustomerInvoicesPageState();
// }
//
// class _CustomerInvoicesPageState extends State<CustomerInvoicesPage> {
//   List<dynamic> customers = [];
//   List<dynamic> filteredCustomers = [];
//   bool isLoading = true;
//
//   final TextEditingController _searchController = TextEditingController();
//   DateTime? _startDate;
//   DateTime? _endDate;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchCustomers();
//   }
//
//   Future<void> fetchCustomers() async {
//     const url = 'https://api.abcoped.shop/api/customers/all-invoices';
//     setState(() => isLoading = true);
//     try {
//       final authStore = Provider.of<AuthStore>(context, listen: false);
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'Authorization': 'Bearer ${authStore.token}'},
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           customers = data['customers'] ?? [];
//           filteredCustomers = customers;
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load invoices');
//       }
//     } catch (e) {
//       print("Error: $e");
//       setState(() => isLoading = false);
//     }
//   }
//
//   void _searchCustomer(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredCustomers = customers;
//       } else {
//         filteredCustomers = customers.where((c) {
//           final name = (c['customerName'] ?? '').toLowerCase();
//           final phone = (c['phoneNumber'] ?? '').toLowerCase();
//
//           // search ticket ids
//           final tickets = (c['invoices'] as List)
//               .expand((inv) => inv['tickets'] as List)
//               .map((t) => t['ticketId'].toString())
//               .join(" ");
//
//           final lowerQuery = query.toLowerCase();
//           return name.contains(lowerQuery) ||
//               phone.contains(lowerQuery) ||
//               tickets.contains(lowerQuery);
//         }).toList();
//       }
//     });
//   }
//
//   Future<void> _pickStartDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _startDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() {
//         _startDate = picked;
//       });
//       _filterByDate();
//     }
//   }
//
//   Future<void> _pickEndDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _endDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() {
//         _endDate = picked;
//       });
//       _filterByDate();
//     }
//   }
//
//   void _filterByDate() {
//     if (_startDate == null && _endDate == null) {
//       setState(() {
//         filteredCustomers = customers;
//       });
//       return;
//     }
//
//     setState(() {
//       filteredCustomers = customers.map((c) {
//         final invoices = (c['invoices'] as List).where((inv) {
//           final invDate = DateTime.parse(inv['invoiceDate']);
//           if (_startDate != null && invDate.isBefore(_startDate!)) return false;
//           if (_endDate != null && invDate.isAfter(_endDate!)) return false;
//           return true;
//         }).toList();
//
//         final customerCopy = Map<String, dynamic>.from(c);
//         customerCopy['invoices'] = invoices;
//         return customerCopy;
//       }).where((c) => (c['invoices'] as List).isNotEmpty).toList();
//     });
//   }
//
//   void _clearFilters() {
//     setState(() {
//       _startDate = null;
//       _endDate = null;
//       _searchController.clear();
//       filteredCustomers = customers;
//     });
//   }
//
//   void _showTicketsDialog(List<dynamic> tickets) {
//     showDialog(
//         context: context,
//         builder: (_) {
//           return AlertDialog(
//             title: const Text('Ticket Details'),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: ListView(
//                 shrinkWrap: true,
//                 children: tickets.map<Widget>((t) {
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Ticket ID: ${t['ticketId']}"),
//                           Text("Product: ${t['productName']}"),
//                           Text("Brand: ${t['brand']}"),
//                           Text("Color: ${t['colorSpecs'] ?? '-'}"),
//                           Text("RAM/ROM: ${t['ramRomSpecs']}"),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Close'))
//             ],
//           );
//         });
//   }
//
//   void _showPaymentsDialog(List<dynamic> payments) {
//     showDialog(
//         context: context,
//         builder: (_) {
//           return AlertDialog(
//             title: const Text('Payment Details'),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: DataTable(
//                 headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
//                 columns: const [
//                   DataColumn(label: Text('Mode')),
//                   DataColumn(label: Text('Amount')),
//                   DataColumn(label: Text('Date')),
//                 ],
//                 rows: payments.map<DataRow>((p) {
//                   return DataRow(cells: [
//                     DataCell(Text(p['mode'] ?? '-')),
//                     DataCell(Text('₹${p['amount']}')),
//                     DataCell(Text(p['paidAt'] ?? '-')),
//                   ]);
//                 }).toList(),
//               ),
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Close'))
//             ],
//           );
//         });
//   }
//   double getTotalAmount() {
//     double total = 0;
//     for (var c in filteredCustomers) {
//       for (var inv in c['invoices'] as List) {
//         total += (inv['totalAmount'] ?? 0);
//       }
//     }
//     return total;
//   }
//
//   Future<void> _exportToExcel() async {
//     final excel = Excel.createExcel();
//     final sheet = excel['Invoices'];
//
//     // Header
//     sheet.appendRow([
//       'Customer Name',
//       'Phone Number',
//       'Customer Document ID',
//       'Invoice Date',
//       'Ticket IDs',
//       'Total Amount'
//     ]);
//
//     for (var c in filteredCustomers) {
//       for (var inv in c['invoices'] as List) {
//         final ticketIds = (inv['tickets'] as List)
//             .map((t) => t['ticketId'].toString())
//             .join(", ");
//         sheet.appendRow([
//           c['customerName'] ?? '',
//           c['phoneNumber'] ?? '',
//           c['customerDocumentId'] ?? '-',
//           inv['invoiceDate'],
//           ticketIds,
//           inv['totalAmount'].toString(),
//         ]);
//       }
//     }
//
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/customer_invoices.xlsx');
//     file.writeAsBytesSync(excel.encode()!);
//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Excel exported to ${file.path}')));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Customer Invoices'),
//         actions: [
//           IconButton(
//               onPressed: _exportToExcel,
//               icon: const Icon(Icons.file_download)),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             // Search + Date + Clear row
//             Row(
//               children: [
//                 Expanded(
//                   flex: 4,
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: _searchCustomer,
//                     decoration: InputDecoration(
//                       labelText:
//                       'Search by Name, Phone or Ticket ID',
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _pickStartDate,
//                     child: Text(_startDate == null
//                         ? 'Start Date'
//                         : DateFormat('dd/MM/yyyy').format(_startDate!)),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _pickEndDate,
//                     child: Text(_endDate == null
//                         ? 'End Date'
//                         : DateFormat('dd/MM/yyyy').format(_endDate!)),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _clearFilters,
//                   child: const Text('Clear'),
//                 ),
//                 const SizedBox(width: 12),
//                 // Total Amount Display
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
//                     Text('₹${getTotalAmount().toStringAsFixed(2)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             // Table headers
//             Container(
//               color: Colors.grey.shade300,
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 8, vertical: 6),
//               child: Table(
//                 defaultVerticalAlignment:
//                 TableCellVerticalAlignment.middle,
//                 columnWidths: const {
//                   0: FlexColumnWidth(2),
//                   1: FlexColumnWidth(2),
//                   2: FlexColumnWidth(1.5),
//                   3: FlexColumnWidth(3),
//                   4: FlexColumnWidth(1.5),
//                   5: FlexColumnWidth(1.5),
//                 },
//                 children: [
//                   TableRow(children: [
//                     const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
//                     const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
//                     const Text('Total Items', style: TextStyle(fontWeight: FontWeight.bold)),
//                     const Text('Ticket IDs', style: TextStyle(fontWeight: FontWeight.bold)),
//                     const Text('Document ID', style: TextStyle(fontWeight: FontWeight.bold)),
//                     const Text('Invoice Date / Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
//                   ])
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 6),
//
//             // Table rows
//             Expanded(
//               child: ListView(
//                 children: filteredCustomers.map((c) {
//                   final invoices = c['invoices'] as List;
//                   return Column(
//                     children: invoices.map<Widget>((inv) {
//                       final tickets = inv['tickets'] as List;
//                       return Card(
//                         elevation: 2,
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Table(
//                             defaultVerticalAlignment:
//                             TableCellVerticalAlignment.middle,
//                             columnWidths: const {
//                               0: FlexColumnWidth(2),
//                               1: FlexColumnWidth(2),
//                               2: FlexColumnWidth(1.5),
//                               3: FlexColumnWidth(3),
//                               4: FlexColumnWidth(1.5),
//                               5: FlexColumnWidth(1.5),
//                             },
//                             children: [
//                               TableRow(children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(6),
//                                   child: Text(c['customerName'] ?? ''),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(6),
//                                   child: Text(c['phoneNumber'] ?? ''),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(6),
//                                   child: Text(tickets.length.toString()),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(6),
//                                   child: SingleChildScrollView(
//                                     scrollDirection: Axis.horizontal,
//                                     child: Row(
//                                       children: tickets
//                                           .map((t) => Padding(
//                                         padding:
//                                         const EdgeInsets.only(
//                                             right: 4),
//                                         child: ActionChip(
//                                           label: Text(t['ticketId']
//                                               .toString()),
//                                           onPressed: () =>
//                                               _showTicketsDialog(
//                                                   [t]),
//                                         ),
//                                       ))
//                                           .toList(),
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(6),
//                                   child: Text(
//                                       c['customerDocumentId'] ?? '-'),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(6),
//                                   child: GestureDetector(
//                                     onTap: () => _showPaymentsDialog(
//                                         inv['payments'] as List),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text(DateFormat('dd/MM/yyyy')
//                                             .format(DateTime.parse(
//                                             inv['invoiceDate']))),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                             '₹${inv['totalAmount'].toString()}',
//                                             style: const TextStyle(
//                                                 fontWeight:
//                                                 FontWeight.bold)),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ]),
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'auth.dart';

class CustomerInvoicesPage extends StatefulWidget {
  const CustomerInvoicesPage({Key? key}) : super(key: key);

  @override
  State<CustomerInvoicesPage> createState() => _CustomerInvoicesPageState();
}

class _CustomerInvoicesPageState extends State<CustomerInvoicesPage> {
  List<dynamic> customers = [];
  List<dynamic> filteredCustomers = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    const url = 'https://api.abcoped.shop/api/customers/all-invoices';
    setState(() => isLoading = true);
    try {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${authStore.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          customers = data['customers'] ?? [];
          filteredCustomers = customers;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load invoices');
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void _searchCustomer(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers = customers.where((c) {
          final name = (c['customerName'] ?? '').toLowerCase();
          final phone = (c['phoneNumber'] ?? '').toLowerCase();
          final tickets = (c['invoices'] as List)
              .expand((inv) => inv['tickets'] as List)
              .map((t) => t['ticketId'].toString())
              .join(" ");

          final lowerQuery = query.toLowerCase();
          return name.contains(lowerQuery) ||
              phone.contains(lowerQuery) ||
              tickets.contains(lowerQuery);
        }).toList();
      }
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _filterByDate();
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _filterByDate();
    }
  }

  void _filterByDate() {
    if (_startDate == null && _endDate == null) {
      setState(() {
        filteredCustomers = customers;
      });
      return;
    }

    setState(() {
      filteredCustomers = customers.map((c) {
        final invoices = (c['invoices'] as List).where((inv) {
          final invDate = DateTime.parse(inv['invoiceDate']);
          if (_startDate != null && invDate.isBefore(_startDate!)) return false;
          if (_endDate != null && invDate.isAfter(_endDate!)) return false;
          return true;
        }).toList();

        final customerCopy = Map<String, dynamic>.from(c);
        customerCopy['invoices'] = invoices;
        return customerCopy;
      }).where((c) => (c['invoices'] as List).isNotEmpty).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _searchController.clear();
      filteredCustomers = customers;
    });
  }

  void _showTicketsDialog(List<dynamic> tickets) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Ticket Details'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: tickets.map<Widget>((t) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ticket ID: ${t['ticketId']}"),
                          Text("Product: ${t['productName']}"),
                          Text("Brand: ${t['brand']}"),
                          Text("Color: ${t['colorSpecs'] ?? '-'}"),
                          Text("RAM/ROM: ${t['ramRomSpecs']}"),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'))
            ],
          );
        });
  }

  void _showPaymentsDialog(List<dynamic> payments) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Payment Details'),
            content: SizedBox(
              width: double.maxFinite,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
                columns: const [
                  DataColumn(label: Text('Mode')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Date')),
                ],
                rows: payments.map<DataRow>((p) {
                  return DataRow(cells: [
                    DataCell(Text(p['mode'] ?? '-')),
                    DataCell(Text('₹${p['amount']}')),
                    DataCell(Text(p['paidAt'] ?? '-')),
                  ]);
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'))
            ],
          );
        });
  }

  void _showInvoiceInfo(dynamic invoice) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Invoice ID: ${invoice['invoiceNumber']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Credit Applied: ₹${invoice['creditApplied'] ?? 0}'),
            Text('Balance Due: ₹${invoice['balanceDue'] ?? 0}'),
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

  double getTotalAmount() {
    double total = 0;
    for (var c in filteredCustomers) {
      for (var inv in c['invoices'] as List) {
        total += (inv['totalAmount'] ?? 0);
      }
    }
    return total;
  }

  Future<void> _exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Invoices'];

    // Header
    sheet.appendRow([
      'Invoice ID',
      'Customer Name',
      'Phone Number',
      'Total Items',
      'Ticket IDs',
      'Document ID',
      'Invoice Date',
      'Total Amount'
    ]);

    for (var c in filteredCustomers) {
      for (var inv in c['invoices'] as List) {
        final ticketIds = (inv['tickets'] as List)
            .map((t) => t['ticketId'].toString())
            .join(", ");
        sheet.appendRow([
          inv['invoiceNumber'].toString(),
          c['customerName'] ?? '',
          c['phoneNumber'] ?? '',
          (inv['tickets'] as List).length,
          ticketIds,
          c['customerDocumentId'] ?? '-',
          inv['invoiceDate'],
          inv['totalAmount'].toString(),
        ]);
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/customer_invoices.xlsx');
    file.writeAsBytesSync(excel.encode()!);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel exported to ${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Invoices'),
        actions: [
          IconButton(
              onPressed: _exportToExcel,
              icon: const Icon(Icons.file_download)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search + Date + Clear + Total row
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchCustomer,
                    decoration: InputDecoration(
                      labelText:
                      'Search by Name, Phone or Ticket ID',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStartDate,
                    child: Text(_startDate == null
                        ? 'Start Date'
                        : DateFormat('dd/MM/yyyy').format(_startDate!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEndDate,
                    child: Text(_endDate == null
                        ? 'End Date'
                        : DateFormat('dd/MM/yyyy').format(_endDate!)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('₹${getTotalAmount().toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Table headers
            Container(
              color: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FlexColumnWidth(2), // Invoice ID
                  1: FlexColumnWidth(2), // Name
                  2: FlexColumnWidth(2), // Phone
                  3: FlexColumnWidth(1.5), // Total Items
                  4: FlexColumnWidth(3), // Ticket IDs
                  5: FlexColumnWidth(1.5), // Document ID
                  6: FlexColumnWidth(2), // Invoice Date / Total Amount
                },
                children: [
                  TableRow(children: [
                    const Text('Invoice ID', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Total Items', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Ticket IDs', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Document ID', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Invoice Date / Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                  ])
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Table rows
            Expanded(
              child: ListView(
                children: filteredCustomers.map((c) {
                  final invoices = c['invoices'] as List;
                  return Column(
                    children: invoices.map<Widget>((inv) {
                      final tickets = inv['tickets'] as List;
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Table(
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(1.5),
                              4: FlexColumnWidth(3),
                              5: FlexColumnWidth(1.5),
                              6: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(children: [
                                // Invoice ID
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: GestureDetector(
                                    onTap: () => _showInvoiceInfo(inv),
                                    child: Text(
                                      inv['invoiceNumber'].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),

                                // Name
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(c['customerName'] ?? ''),
                                ),

                                // Phone
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(c['phoneNumber'] ?? ''),
                                ),

                                // Total Items
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(tickets.length.toString()),
                                ),

                                // Ticket IDs
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: tickets
                                          .map((t) => Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: ActionChip(
                                          label: Text(t['ticketId'].toString()),
                                          onPressed: () => _showTicketsDialog([t]),
                                        ),
                                      ))
                                          .toList(),
                                    ),
                                  ),
                                ),

                                // Document ID
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(c['customerDocumentId'] ?? '-'),
                                ),

                                // Invoice Date / Total Amount
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: GestureDetector(
                                    onTap: () => _showPaymentsDialog(inv['payments'] as List),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(DateFormat('dd/MM/yyyy')
                                            .format(DateTime.parse(inv['invoiceDate']))),
                                        const SizedBox(height: 4),
                                        Text('₹${inv['totalAmount'].toString()}',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

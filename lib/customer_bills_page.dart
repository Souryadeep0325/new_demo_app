// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
//
// import 'auth.dart';
// import 'custom_appbar.dart';
//
// class CustomerBillsPage extends StatefulWidget {
//   const CustomerBillsPage({super.key});
//
//   @override
//   State<CustomerBillsPage> createState() => _CustomerBillsPageState();
// }
//
// class _CustomerBillsPageState extends State<CustomerBillsPage> {
//   List<dynamic> customers = [];
//   List<dynamic> filteredCustomers = [];
//   bool isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//
//
//   @override
//   void initState() {
//     super.initState();
//     fetchCustomers();
//   }
//
//   Future<void> fetchCustomers() async {
//
//     const url = 'https://api.abcoped.shop/api/customers/all-bills';
//     setState(() => isLoading = true);
//
//     try {
//       final authStore = Provider.of<AuthStore>(context, listen: false);
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
//         throw Exception('Failed to load bills');
//       }
//     } catch (e) {
//       print("Error fetching bills: $e");
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
//           return name.contains(query.toLowerCase()) ||
//               phone.contains(query.toLowerCase());
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(appBarTitle: 'Customer Bills'),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             // 🔍 Search bar
//             TextField(
//               controller: _searchController,
//               onChanged: _searchCustomer,
//               decoration: InputDecoration(
//                 labelText: 'Search by name or phone number',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//
//             // 📊 Table with expandable bill details
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredCustomers.length,
//                 itemBuilder: (context, index) {
//                   final customer = filteredCustomers[index];
//                   final bills = customer['bills'] ?? [];
//
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 6),
//                     elevation: 3,
//                     child: ExpansionTile(
//                       title: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               customer['customerName'] ?? 'Unknown',
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           Text(
//                             customer['phoneNumber'] ?? '',
//                             style: const TextStyle(
//                                 color: Colors.grey, fontSize: 13),
//                           ),
//                         ],
//                       ),
//                       subtitle: Text(
//                         "Bills: ${bills.length}",
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                       children: [
//                         // Table for each bill
//                         for (var bill in bills)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 5),
//                             child: Card(
//                               color: Colors.grey.shade100,
//                               elevation: 1,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: ExpansionTile(
//                                 title: Text(
//                                   'Bill #${bill['billNumber'] ?? 'N/A'} | ₹${bill['totalAmount'] ?? 0}',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                                 subtitle: Text(
//                                   'Date: ${bill['billDate'] ?? 'N/A'} | Store: ${bill['storeId'] ?? '-'}',
//                                 ),
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                             'Total Paid: ₹${bill['totalPaid'] ?? 0}'),
//                                         Text(
//                                             'Credit Applied: ₹${bill['creditApplied'] ?? 0}'),
//                                         Text(
//                                             'Balance Due: ₹${bill['balanceDue'] ?? 0}'),
//                                         const SizedBox(height: 10),
//
//                                         // 🧾 Tickets under this bill
//                                         const Text('🎟️ Tickets:',
//                                             style: TextStyle(
//                                                 fontWeight:
//                                                 FontWeight.bold)),
//                                         DataTable(
//                                           headingRowColor:
//                                           WidgetStateProperty.all(
//                                               Colors.teal.shade50),
//                                           columns: const [
//                                             DataColumn(
//                                                 label: Text('Ticket ID')),
//                                             DataColumn(
//                                                 label: Text('Product')),
//                                             DataColumn(
//                                                 label: Text('Brand')),
//                                             DataColumn(
//                                                 label: Text('RAM/ROM')),
//                                           ],
//                                           rows: (bill['tickets'] as List)
//                                               .map<DataRow>((t) {
//                                             return DataRow(cells: [
//                                               DataCell(Text(
//                                                   "${t['ticketId'] ??
//                                                       '-'}")),
//                                               DataCell(Text(
//                                                   t['productName'] ??
//                                                       '-')),
//                                               DataCell(
//                                                   Text(t['brand'] ?? '-')),
//                                               DataCell(Text(
//                                                   t['ramRomSpecs'] ??
//                                                       '-')),
//                                             ]);
//                                           }).toList(),
//                                         ),
//                                         const SizedBox(height: 10),
//
//                                         // 💰 Payments under this bill
//                                         const Text('💰 Payments:',
//                                             style: TextStyle(
//                                                 fontWeight:
//                                                 FontWeight.bold)),
//                                         DataTable(
//                                           headingRowColor:
//                                           WidgetStateProperty.all(
//                                               Colors.green.shade50),
//                                           columns: const [
//                                             DataColumn(
//                                                 label: Text('Mode')),
//                                             DataColumn(
//                                                 label: Text('Amount')),
//                                             DataColumn(
//                                                 label: Text('Date')),
//                                           ],
//                                           rows: (bill['payments'] as List)
//                                               .map<DataRow>((p) {
//                                             return DataRow(cells: [
//                                               DataCell(Text(
//                                                   p['mode'] ?? '-')),
//                                               DataCell(Text(
//                                                   '₹${p['amount']}')),
//                                               DataCell(Text(
//                                                   p['paidAt'] ?? '-')),
//                                             ]);
//                                           }).toList(),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';
import 'custom_appbar.dart';

class CustomerBillsPage extends StatefulWidget {
  const CustomerBillsPage({super.key});

  @override
  State<CustomerBillsPage> createState() => _CustomerBillsPageState();
}

class _CustomerBillsPageState extends State<CustomerBillsPage> {
  List<dynamic> customers = [];
  List<dynamic> filteredCustomers = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    const url = 'https://api.abcoped.shop/api/customers/all-bills';
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
          calculateTotal();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load bills');
      }
    } catch (e) {
      print("Error fetching bills: $e");
      setState(() => isLoading = false);
    }
  }

  void calculateTotal() {
    double sum = 0;
    for (var customer in filteredCustomers) {
      for (var bill in customer['bills']) {
        sum += bill['totalPaid'] ?? 0;
      }
    }
    setState(() {
      totalAmount = sum;
    });
  }

  void _searchCustomer(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers = customers.where((c) {
          final name = (c['customerName'] ?? '').toLowerCase();
          final phone = (c['phoneNumber'] ?? '').toLowerCase();
          bool ticketMatch = false;
          for (var bill in c['bills'] ?? []) {
            for (var ticket in bill['tickets'] ?? []) {
              if ((ticket['ticketId']?.toString() ?? '')
                  .contains(query.toLowerCase())) {
                ticketMatch = true;
                break;
              }
            }
          }
          return name.contains(query.toLowerCase()) ||
              phone.contains(query.toLowerCase()) ||
              ticketMatch;
        }).toList();
      }
      calculateTotal();
    });
  }

  void _filterByDate() {
    if (startDate == null || endDate == null) return;

    setState(() {
      filteredCustomers = customers.map((customer) {
        final filteredBills = (customer['bills'] as List)
            .where((bill) {
          final billDate = DateTime.parse(bill['billDate']);
          return billDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
              billDate.isBefore(endDate!.add(const Duration(days: 1)));
        })
            .toList();
        return {...customer, 'bills': filteredBills};
      }).where((c) => (c['bills'] as List).isNotEmpty).toList();
      calculateTotal();
    });
  }

  void _clearFilters() {
    _searchController.clear();
    startDate = null;
    endDate = null;
    setState(() {
      filteredCustomers = customers;
      calculateTotal();
    });
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        startDate = date;
      });
      _filterByDate();
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        endDate = date;
      });
      _filterByDate();
    }
  }

  void _showTicketDetails(dynamic ticket) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ticket ID: ${ticket['ticketId']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${ticket['productName']}'),
            Text('Brand: ${ticket['brand']}'),
            Text('RAM/ROM: ${ticket['ramRomSpecs']}'),
            if (ticket['colorSpecs'] != null) Text('Color: ${ticket['colorSpecs']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showPayments(List payments) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: payments.map<Widget>((p) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${p['mode']}'),
                Text('₹${p['amount']}'),
                Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(p['paidAt']))),
              ],
            );
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showBillInfo(dynamic bill) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Bill ID: ${bill['billNumber']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Profit: ₹${bill['profit']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _downloadBill(String billNumber) {
    // implement your download logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading Bill: $billNumber')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(appBarTitle: 'Customer Bills'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Filters row: Search + Start/End Date + Total Amount + Clear
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchCustomer,
                    decoration: const InputDecoration(
                      labelText: 'Search by name, phone or ticket',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickStartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(startDate == null ? 'Start Date' : DateFormat('dd/MM/yyyy').format(startDate!)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickEndDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(endDate == null ? 'End Date' : DateFormat('dd/MM/yyyy').format(endDate!)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total: ₹$totalAmount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearFilters,
                )
              ],
            ),
            const SizedBox(height: 12),

            // Table header
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: const [
                  Expanded(flex: 1, child: Text('Bill ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('Billed Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Total Items', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text('Ticket IDs', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Credit Applied', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Download', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Table rows
            Expanded(
              child: ListView.builder(
                itemCount: filteredCustomers.length,
                itemBuilder: (context, cIndex) {
                  final customer = filteredCustomers[cIndex];
                  final bills = customer['bills'] ?? [];
                  return Column(
                    children: [
                      for (var bill in bills)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () => _showBillInfo(bill),
                                    child: Text(
                                      '${bill['billNumber']}',
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Expanded(flex: 2, child: Text(customer['customerName'] ?? '-', overflow: TextOverflow.ellipsis)),
                                Expanded(flex: 2, child: Text(customer['phoneNumber'] ?? '-', overflow: TextOverflow.ellipsis)),
                                Expanded(flex: 1, child: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(bill['billDate'])))),
                                Expanded(child: Text('${(bill['tickets'] as List).length}')),
                                Expanded(
                                  flex: 3,
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: (bill['tickets'] as List).map<Widget>((t) {
                                      return GestureDetector(
                                        onTap: () => _showTicketDetails(t),
                                        child: Chip(label: Text('${t['ticketId']}')),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showPayments(bill['payments']),
                                    child: Text(
                                      '₹${bill['totalPaid']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.blue),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '₹${bill['creditApplied'] ?? 0}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () => _downloadBill(bill['billNumber']),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

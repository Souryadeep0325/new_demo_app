import 'dart:convert';
import 'package:flutter/material.dart';
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

  void _searchCustomer(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers = customers.where((c) {
          final name = (c['customerName'] ?? '').toLowerCase();
          final phone = (c['phoneNumber'] ?? '').toLowerCase();
          return name.contains(query.toLowerCase()) ||
              phone.contains(query.toLowerCase());
        }).toList();
      }
    });
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
            // 🔍 Search bar
            TextField(
              controller: _searchController,
              onChanged: _searchCustomer,
              decoration: InputDecoration(
                labelText: 'Search by name or phone number',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 📊 Table with expandable bill details
            Expanded(
              child: ListView.builder(
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  final bills = customer['bills'] ?? [];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 3,
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              customer['customerName'] ?? 'Unknown',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            customer['phoneNumber'] ?? '',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        "Bills: ${bills.length}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      children: [
                        // Table for each bill
                        for (var bill in bills)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Card(
                              color: Colors.grey.shade100,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  'Bill #${bill['billNumber'] ?? 'N/A'} | ₹${bill['totalAmount'] ?? 0}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Date: ${bill['billDate'] ?? 'N/A'} | Store: ${bill['storeId'] ?? '-'}',
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Total Paid: ₹${bill['totalPaid'] ?? 0}'),
                                        Text(
                                            'Credit Applied: ₹${bill['creditApplied'] ?? 0}'),
                                        Text(
                                            'Balance Due: ₹${bill['balanceDue'] ?? 0}'),
                                        const SizedBox(height: 10),

                                        // 🧾 Tickets under this bill
                                        const Text('🎟️ Tickets:',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold)),
                                        DataTable(
                                          headingRowColor:
                                          WidgetStateProperty.all(
                                              Colors.teal.shade50),
                                          columns: const [
                                            DataColumn(
                                                label: Text('Product')),
                                            DataColumn(
                                                label: Text('Brand')),
                                            DataColumn(
                                                label: Text('RAM/ROM')),
                                          ],
                                          rows: (bill['tickets'] as List)
                                              .map<DataRow>((t) {
                                            return DataRow(cells: [
                                              DataCell(Text(
                                                  t['productName'] ??
                                                      '-')),
                                              DataCell(
                                                  Text(t['brand'] ?? '-')),
                                              DataCell(Text(
                                                  t['ramRomSpecs'] ??
                                                      '-')),
                                            ]);
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 10),

                                        // 💰 Payments under this bill
                                        const Text('💰 Payments:',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold)),
                                        DataTable(
                                          headingRowColor:
                                          WidgetStateProperty.all(
                                              Colors.green.shade50),
                                          columns: const [
                                            DataColumn(
                                                label: Text('Mode')),
                                            DataColumn(
                                                label: Text('Amount')),
                                            DataColumn(
                                                label: Text('Date')),
                                          ],
                                          rows: (bill['payments'] as List)
                                              .map<DataRow>((p) {
                                            return DataRow(cells: [
                                              DataCell(Text(
                                                  p['mode'] ?? '-')),
                                              DataCell(Text(
                                                  '₹${p['amount']}')),
                                              DataCell(Text(
                                                  p['paidAt'] ?? '-')),
                                            ]);
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';

class TicketListPageQC1 extends StatefulWidget {
  const TicketListPageQC1({super.key});

  @override
  State<TicketListPageQC1> createState() => _TicketListPageQC1State();
}

class _TicketListPageQC1State extends State<TicketListPageQC1> {
  List<dynamic> tickets = [];
  bool isLoading = true;
  int currentPage = 0;
  int pageSize = 10;

  final itemIdController = TextEditingController();
  final productNameController = TextEditingController();

  String? currentItemId;
  String? currentProductName;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    setState(() => isLoading = true);
    final authStore = Provider.of<AuthStore>(context, listen: false);

    final queryParameters = {
      'ticketStatus': 'QC1',
    };
    if (currentItemId != null && currentItemId!.isNotEmpty) {
      queryParameters['itemId'] = currentItemId!;
    }
    if (currentProductName != null && currentProductName!.isNotEmpty) {
      queryParameters['productName'] = currentProductName!;
    }

    final uri = Uri.https('api.abcoped.shop', '/api/ticket/search-ticket', queryParameters);

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

  void applyFilters() {
    currentItemId = itemIdController.text;
    currentProductName = productNameController.text;
    currentPage = 0;
    fetchTickets();
  }

  void clearFilters() {
    itemIdController.clear();
    productNameController.clear();
    currentItemId = null;
    currentProductName = null;
    currentPage = 0;
    fetchTickets();
  }

  Future<void> changeStatus(int ticketId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('https://api.abcoped.shop/api/ticket/$ticketId/status');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "newStatus": "QC2",
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated for ticket $ticketId')),
        );
        fetchTickets();
      } else {
        showError('Failed to update status. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('An error occurred while updating status: $e');
    }
  }

  void confirmStatusChange(int ticketId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Status Change'),
        content: const Text('Do you want to change the status to QC2?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => changeStatus(ticketId),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void showError(String message) {
    setState(() => isLoading = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paginatedTickets = tickets.skip(currentPage * pageSize).take(pageSize).toList();
    final totalPages = (tickets.length / pageSize).ceil();

    return Scaffold(
      appBar: AppBar(title: const Text("QC1 Ticket List")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemIdController,
                    decoration: const InputDecoration(labelText: 'Item ID'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: productNameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: applyFilters, child: const Text("Search")),
                const SizedBox(width: 8),
                TextButton(onPressed: clearFilters, child: const Text("Clear")),
              ],
            ),
            if (currentItemId != null || currentProductName != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Showing results for: "
                    "${currentItemId != null ? "Item ID = $currentItemId " : ""}" +
                    "${currentProductName != null ? "Product Name = $currentProductName" : ""}"),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: paginatedTickets.length,
                itemBuilder: (context, index) {
                  final ticket = paginatedTickets[index];
                  final ticketId = ticket['ticketId'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("Item ID: ${ticket['itemId']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ticket ID: $ticketId"),
                          Text("Purchase Type: ${ticket['productPurchaseType']}"),
                          Text("Invoice Date: ${ticket['invoiceDate']}"),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => confirmStatusChange(ticketId),
                        child: const Text("Change Status"),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (tickets.length > pageSize)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text('Page ${currentPage + 1} of $totalPages'),
                  IconButton(
                    onPressed: currentPage < totalPages - 1 ? () => setState(() => currentPage++) : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

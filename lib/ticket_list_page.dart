import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  List<dynamic> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('https://api.abcoped.shop/api/ticket/search-ticket');

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
          "newStatus":"QC2",
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated for ticket $ticketId')),
        );
        fetchTickets(); // Refresh the list
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
    return Scaffold(
      appBar: AppBar(title: const Text("All Products List")),
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
                  Text("Ticket Status: ${ticket['ticketStatus']}"),
                  Text("Invoice Date: ${ticket['invoiceDate']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

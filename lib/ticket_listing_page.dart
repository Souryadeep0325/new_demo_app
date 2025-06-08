import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';

class TicketListingPage extends StatefulWidget {
  final String status;
  final String? title;

  const TicketListingPage({
    super.key,
    required this.status,
    this.title,
  });

  @override
  State<TicketListingPage> createState() => _TicketListingPageState();
}

class _TicketListingPageState extends State<TicketListingPage> {
  List<dynamic> allTickets = [];
  List<dynamic> displayedTickets = [];
  bool isLoading = true;

  final itemIdController = TextEditingController();
  final productNameController = TextEditingController();
  int currentPage = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    setState(() {
      isLoading = true;
      displayedTickets = [];
    });

    final authStore = Provider.of<AuthStore>(context, listen: false);

    final params = {
      "ticketStatus": widget.status,
      if (itemIdController.text.isNotEmpty) "itemId": itemIdController.text,
      if (productNameController.text.isNotEmpty) "productName": productNameController.text,
    };

    final uri = Uri.http('35.154.252.161:8080', '/api/ticket/search-ticket', params);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        allTickets = json.decode(response.body);
        currentPage = 1;
        updateDisplayedTickets();
      } else {
        showError('Failed to fetch tickets. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('An error occurred: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void updateDisplayedTickets() {
    final startIndex = (currentPage - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, allTickets.length);
    setState(() {
      displayedTickets = allTickets.sublist(startIndex, endIndex);
    });
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void confirmStatusChange(int ticketId, String currentStatus) {
    final List<String> statusOptions = ['QC1', 'QC2', 'LISTED', 'FACTORY']
        .where((status) => status != currentStatus)
        .toList();

    String? selectedStatus;
    final TextEditingController commentController = TextEditingController();
    final TextEditingController costController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Ticket Status'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'New Status'),
                value: selectedStatus,
                items: statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedStatus = value);
                },
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Comment (optional)'),
              ),
              TextField(
                controller: costController,
                decoration: const InputDecoration(labelText: 'Cost (optional)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (selectedStatus == null) {
                showError('Please select a new status.');
                return;
              }
              Navigator.pop(context); // Close dialog
              changeStatus(
                ticketId,
                selectedStatus!,
                comment: commentController.text.trim(),
                costText: costController.text.trim(),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> changeStatus(int ticketId, String newStatus,
      {String? comment, String? costText}) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('http://35.154.252.161:8080/api/ticket/$ticketId/status');

    final Map<String, dynamic> body = {
      'newStatus': newStatus,
    };

    if (comment != null && comment.isNotEmpty) {
      body['comment'] = comment;
    }

    if (costText != null && costText.isNotEmpty) {
      final cost = int.tryParse(costText);
      if (cost != null) {
        body['cost'] = cost;
      } else {
        showError('Invalid cost entered. It should be a number.');
        return;
      }
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${authStore.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated for ticket $ticketId')),
        );
        await fetchTickets(); // Refresh
      } else {
        showError('Failed to update status. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error updating status: $e');
    }
  }

  Future<void> showTicketInfo(int ticketId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('http://35.154.252.161:8080/api/ticket/check-ticket/$ticketId');

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

        final totalCost =ticket['refurbishedCost']!= null &&
            ticket['refurbishedCost']!=0? ticket['acquisitionCost'] + ticket['refurbishedCost']
            :ticket['acquisitionCost'];
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Ticket Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Product: ${ticket['productName']}"),
                Text("RAM/ROM: ${ticket['ramRomSpecs']}"),
                Text("Color: ${ticket['colorSpecs']}"),
                Text("Acquisition Cost: ${ticket['acquisitionCost']}"),
                Text("Refurbished Cost: ${ticket['refurbishedCost'] ?? 'N/A'}"),

                Text("Total Acquisition Cost:${totalCost}"),
                Text("Comment: ${ticket['comment']}"),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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

  Widget buildSearchSection() {
    return Padding(
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
              ElevatedButton(onPressed: fetchTickets, child: const Text("Search")),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  itemIdController.clear();
                  productNameController.clear();
                  fetchTickets();
                },
                child: const Text("Clear"),
              ),
            ],
          ),
          if (itemIdController.text.isNotEmpty || productNameController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Filters: '
                    '${itemIdController.text.isNotEmpty ? 'Item ID = ${itemIdController.text} ' : ''}'
                    '${productNameController.text.isNotEmpty ? 'Product = ${productNameController.text}' : ''}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildTicketList() {
    return Expanded(
      child: ListView.builder(
        itemCount: displayedTickets.length,
        itemBuilder: (context, index) {
          final ticket = displayedTickets[index];
          final ticketId = ticket['ticketId'];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text("Item ID: ${ticket['itemId']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ticket ID: $ticketId"),
                  Text("Product: ${ticket['productName']}"),
                  Text("Purchase Type: ${ticket['productPurchaseType']}"),
                  Text("Invoice Date: ${ticket['invoiceDate']}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: "View Details",
                    onPressed: () => showTicketInfo(ticketId),
                  ),
                  ElevatedButton(
                    onPressed: () => confirmStatusChange(ticketId, ticket['ticketStatus']),
                    child: const Text("Change Status"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildPaginationControls() {
    final totalPages = (allTickets.length / pageSize).ceil();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () {
              setState(() => currentPage--);
              updateDisplayedTickets();
            }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Page $currentPage of $totalPages'),
          IconButton(
            onPressed: currentPage < totalPages
                ? () {
              setState(() => currentPage++);
              updateDisplayedTickets();
            }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = widget.title ?? '${widget.status} Ticket List';

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          buildSearchSection(),
          buildTicketList(),
          if (allTickets.length > pageSize) buildPaginationControls(),
        ],
      ),
    );
  }
}

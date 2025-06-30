import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';
import 'widgets/custom_dialog.dart';

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
  final costMinController = TextEditingController();
  final costMaxController = TextEditingController();

  DateTime? tempInvoiceDateFrom;
  DateTime? tempInvoiceDateTo;
  DateTime? invoiceDateFrom;
  DateTime? invoiceDateTo;

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
      if (invoiceDateFrom != null) "invoiceDateFrom": invoiceDateFrom!.toIso8601String().split('T').first,
      if (invoiceDateTo != null) "invoiceDateTo": invoiceDateTo!.toIso8601String().split('T').first,
      if (costMinController.text.isNotEmpty) "costMin": costMinController.text,
      if (costMaxController.text.isNotEmpty) "costMax": costMaxController.text,
    };

    final uri = Uri.https('api.abcoped.shop', '/api/ticket/search-ticket', params);

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

  void confirmStatusChange(int ticketId, String currentStatus) {
    final List<String> statusOptions = ['QC1', 'QC2', 'LISTED', 'FACTORY']
        .where((status) => status != currentStatus)
        .toList();

    String? selectedStatus;
    final TextEditingController commentController = TextEditingController();
    final TextEditingController costController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Change Ticket Status',
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoSection(
                title: 'Status Information',
                rows: [
                  InfoRow(
                    label: 'Current Status',
                    value: currentStatus,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'New Status',
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
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
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costController,
                decoration: const InputDecoration(
                  labelText: 'Cost (optional)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          DialogButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          DialogButton(
            label: 'Submit',
            isPrimary: true,
            onPressed: () {
              if (selectedStatus == null) {
                showError('Please select a new status.');
                return;
              }
              Navigator.pop(context);
              changeStatus(
                ticketId,
                selectedStatus!,
                comment: commentController.text.trim(),
                costText: costController.text.trim(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> changeStatus(int ticketId, String newStatus,
      {String? comment, String? costText}) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('https://api.abcoped.shop/api/ticket/$ticketId/status');

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
        await fetchTickets();
      } else {
        showError('Failed to update status. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error updating status: $e');
    }
  }

  Future<void> showTicketInfo(int ticketId) async {
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoSection(
                  title: 'Product Information',
                  rows: [
                    InfoRow(
                      label: 'Product Name',
                      value: ticket['productName'] ?? 'N/A',
                    ),
                    InfoRow(
                      label: 'RAM/ROM',
                      value: ticket['ramRomSpecs'] ?? 'N/A',
                    ),
                    InfoRow(
                      label: 'Color',
                      value: ticket['colorSpecs'] ?? 'N/A',
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempInvoiceDateFrom ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => tempInvoiceDateFrom = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Invoice Date From'),
                    child: Text(tempInvoiceDateFrom != null
                        ? tempInvoiceDateFrom!.toIso8601String().split('T').first
                        : 'Select date'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempInvoiceDateTo ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => tempInvoiceDateTo = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Invoice Date To'),
                    child: Text(tempInvoiceDateTo != null
                        ? tempInvoiceDateTo!.toIso8601String().split('T').first
                        : 'Select date'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: costMinController,
                  decoration: const InputDecoration(labelText: 'Cost Min'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: costMaxController,
                  decoration: const InputDecoration(labelText: 'Cost Max'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  invoiceDateFrom = tempInvoiceDateFrom;
                  invoiceDateTo = tempInvoiceDateTo;
                  fetchTickets();
                },
                child: const Text("Search"),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  itemIdController.clear();
                  productNameController.clear();
                  costMinController.clear();
                  costMaxController.clear();
                  invoiceDateFrom = null;
                  invoiceDateTo = null;
                  tempInvoiceDateFrom = null;
                  tempInvoiceDateTo = null;
                  fetchTickets();
                },
                child: const Text("Clear"),
              ),
            ],
          ),
          if (itemIdController.text.isNotEmpty ||
              productNameController.text.isNotEmpty ||
              invoiceDateFrom != null ||
              invoiceDateTo != null ||
              costMinController.text.isNotEmpty ||
              costMaxController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Filters: '
                    '${itemIdController.text.isNotEmpty ? 'Item ID = ${itemIdController.text} ' : ''}'
                    '${productNameController.text.isNotEmpty ? 'Product = ${productNameController.text} ' : ''}'
                    '${invoiceDateFrom != null ? 'From = ${invoiceDateFrom!.toIso8601String().split('T').first} ' : ''}'
                    '${invoiceDateTo != null ? 'To = ${invoiceDateTo!.toIso8601String().split('T').first} ' : ''}'
                    '${costMinController.text.isNotEmpty ? 'Cost ≥ ${costMinController.text} ' : ''}'
                    '${costMaxController.text.isNotEmpty ? 'Cost ≤ ${costMaxController.text}' : ''}',
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

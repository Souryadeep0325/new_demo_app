import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';
import 'widgets/custom_dialog.dart';

class ProductListing extends StatefulWidget {
  final String status;
  final String? title;

  const ProductListing({
    super.key,
    required this.status,
    this.title,
  });

  @override
  State<ProductListing> createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  List<dynamic> allTickets = [];
  List<dynamic> displayedTickets = [];
  bool isLoading = true;

  final itemIdController = TextEditingController();
  final productNameController = TextEditingController();
  int currentPage = 1;
  int pageSize = 10;

  // Add state for filters
  String? productNameFilter;
  String? statusFilter;
  DateTimeRange? invoiceDateRange;

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
      if (widget.status.isNotEmpty) "ticketStatus": widget.status,
      if (itemIdController.text.isNotEmpty) "itemId": itemIdController.text,
      if (productNameController.text.isNotEmpty) "productName": productNameController.text,
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
        await fetchTickets(); // Refresh
      } else {
        showError('Failed to update status. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error updating status: $e');
    }
  }

  Future<void> createBill(int ticketId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final TextEditingController customerNameController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();
    final TextEditingController gstIdController = TextEditingController();
    final TextEditingController modeOfPaymentController = TextEditingController();
    final TextEditingController onlineTrxIdController = TextEditingController();
    final TextEditingController placeOfSaleController = TextEditingController();
    final TextEditingController profitController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => CustomDialog(
          title: 'Create Bill',
          maxWidth: 500,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoSection(
                title: 'Customer Information',
                rows: const [],
                hasDivider: false,
              ),
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gstIdController,
                decoration: const InputDecoration(
                  labelText: 'GST ID (optional)',
                  prefixIcon: Icon(Icons.receipt),
                ),
              ),
              const SizedBox(height: 24),
              InfoSection(
                title: 'Payment Details',
                rows: const [],
                hasDivider: false,
              ),
              TextField(
                controller: modeOfPaymentController,
                decoration: const InputDecoration(
                  labelText: 'Mode of Payment',
                  prefixIcon: Icon(Icons.payment),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: onlineTrxIdController,
                decoration: const InputDecoration(
                  labelText: 'Online Transaction ID',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 24),
              InfoSection(
                title: 'Additional Information',
                rows: const [],
                hasDivider: false,
              ),
              TextField(
                controller: placeOfSaleController,
                decoration: const InputDecoration(
                  labelText: 'Place of Sale',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: profitController,
                decoration: const InputDecoration(
                  labelText: 'Profit (optional)',
                  prefixIcon: Icon(Icons.trending_up),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            DialogButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
            DialogButton(
              label: 'Create',
              isPrimary: true,
              isLoading: isSubmitting,
              onPressed: () async {
                setState(() => isSubmitting = true);
                
                final uri = Uri.parse('https://api.abcoped.shop/api/ticket/$ticketId/create-bill');
                final body = {
                  'customerName': customerNameController.text.trim(),
                  'phoneNumber': phoneNumberController.text.trim(),
                  'gstId': gstIdController.text.trim(),
                  'modeOfPayment': modeOfPaymentController.text.trim(),
                  'onlineTrxId': onlineTrxIdController.text.trim(),
                  'placeOfSale': placeOfSaleController.text.trim(),
                  if (profitController.text.isNotEmpty) 'profit': int.tryParse(profitController.text.trim()),
                };
                
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
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bill created successfully')),
                    );
                    await fetchTickets();
                  } else {
                    showError('Failed to create bill. Status: ${response.statusCode}');
                  }
                } catch (e) {
                  showError('Error creating bill: $e');
                } finally {
                  setState(() => isSubmitting = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showTicketInfo(int ticketId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('https://api.abcoped.shop/api/ticket/check-ticket/$ticketId');
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
        final ticket = json.decode(response.body);
        final totalCost = (ticket['refurbishedCost'] != null && ticket['refurbishedCost'] != 0)
            ? (ticket['acquisitionCost'] ?? 0) + (ticket['refurbishedCost'] ?? 0)
            : (ticket['acquisitionCost'] ?? 0);
        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            title: 'Ticket Details',
            maxWidth: 500,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoSection(
                    title: 'Product Information',
                    rows: [
                      InfoRow(label: 'Ticket ID', value: ticket['ticketId']?.toString() ?? 'N/A', copyable: true),
                      InfoRow(label: 'Product Name', value: ticket['productName'] ?? 'N/A'),
                      InfoRow(label: 'RAM/ROM', value: ticket['ramRomSpecs'] ?? 'N/A'),
                      InfoRow(label: 'Color', value: ticket['colorSpecs'] ?? 'N/A'),
                      InfoRow(label: 'Status', value: ticket['status'] ?? 'N/A', isHighlighted: true),
                    ],
                  ),
                  InfoSection(
                    title: 'Cost Details',
                    rows: [
                      InfoRow(label: 'Acquisition Cost', value: ticket['acquisitionCost'] != null ? '\u20b9${ticket['acquisitionCost']}' : 'N/A'),
                      InfoRow(label: 'Refurbished Cost', value: ticket['refurbishedCost'] != null ? '\u20b9${ticket['refurbishedCost']}' : 'N/A'),
                      InfoRow(label: 'Total Cost', value: '\u20b9$totalCost', isHighlighted: true),
                    ],
                  ),
                  if (ticket['comment'] != null && ticket['comment'].toString().isNotEmpty)
                    InfoSection(
                      title: 'Additional Information',
                      hasDivider: false,
                      rows: [
                        InfoRow(label: 'Comment', value: ticket['comment']),
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
            ],
          ),
        );
      } else {
        showError('Failed to fetch ticket details. Status: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context); // Remove loading
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

  // Add filter widgets above the table
  Widget buildAllProductsFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Product Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  productNameFilter = value;
                });
              },
            ),
          ),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              value: statusFilter,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Statuses')),
                ...["LISTED", "SOLD", "IN_STOCK", "OUT_OF_STOCK"].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  statusFilter = value;
                });
              },
            ),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(invoiceDateRange == null
                ? 'Invoice Date Range'
                : '${invoiceDateRange!.start.toLocal().toString().split(' ')[0]} - ${invoiceDateRange!.end.toLocal().toString().split(' ')[0]}'),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: invoiceDateRange,
              );
              if (picked != null) {
                setState(() {
                  invoiceDateRange = picked;
                });
              }
            },
          ),
          if (productNameFilter != null || statusFilter != null || invoiceDateRange != null)
            TextButton(
              onPressed: () {
                setState(() {
                  productNameFilter = null;
                  statusFilter = null;
                  invoiceDateRange = null;
                });
              },
              child: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  // Filter logic for All Products table
  List<Map<String, dynamic>> get filteredProducts {
    return allTickets.where((ticket) {
      final matchesName = productNameFilter == null || productNameFilter!.isEmpty || (ticket['productName']?.toLowerCase().contains(productNameFilter!.toLowerCase()) ?? false);
      final matchesStatus = statusFilter == null || ticket['status'] == statusFilter;
      final matchesDate = invoiceDateRange == null || (
        (ticket['invoiceDate'] != null &&
          DateTime.tryParse(ticket['invoiceDate']) != null &&
          DateTime.tryParse(ticket['invoiceDate'])!.isAfter(invoiceDateRange!.start.subtract(const Duration(days: 1))) &&
          DateTime.tryParse(ticket['invoiceDate'])!.isBefore(invoiceDateRange!.end.add(const Duration(days: 1)))
        )
      );
      return matchesName && matchesStatus && matchesDate;
    }).toList().cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> get paginatedFilteredProducts {
    final startIndex = (currentPage - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, filteredProducts.length);
    return filteredProducts.sublist(startIndex, endIndex);
  }

  Widget buildAllProductsTable() {
    return DataTable(
      headingRowColor: MaterialStateProperty.resolveWith<Color?>((states) => Colors.grey[100]),
      dataRowColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.selected)) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
        }
        return null;
      }),
      columns: const [
        DataColumn(label: Text('Product ID')),
        DataColumn(label: Text('Product Name')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Invoice Date')),
        DataColumn(label: Text('Acquisition Cost')),
        DataColumn(label: Text('Actions')),
      ],
      rows: List<DataRow>.generate(
        paginatedFilteredProducts.length,
        (index) {
          final ticket = paginatedFilteredProducts[index];
          final isEven = index % 2 == 0;
          return DataRow(
            color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                }
                return isEven ? Colors.grey[50] : Colors.white;
              },
            ),
            cells: [
              DataCell(Text(ticket['itemId']?.toString() ?? '')),
              DataCell(Text(ticket['productName'] ?? '')),
              DataCell(Text(ticket['status'] ?? '')),
              DataCell(Text(ticket['invoiceDate'] ?? ticket['createdAt'] ?? '')),
              DataCell(Text(ticket['acquisitionCost']?.toString() ?? '')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: "View Details",
                    onPressed: () => showTicketInfo(ticket['ticketId']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: "Change Status",
                    onPressed: () => confirmStatusChange(ticket['ticketId'], ticket['status']),
                  ),
                  if (ticket['status'] == 'LISTED')
                    IconButton(
                      icon: const Icon(Icons.receipt_long),
                      tooltip: 'Create Bill',
                      onPressed: () => createBill(ticket['ticketId']),
                    ),
                ],
              )),
            ],
          );
        },
      ),
    );
  }

  Widget buildPaginationControls() {
    final totalPages = (filteredProducts.length / pageSize).ceil();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () {
              setState(() => currentPage--);
            }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Page $currentPage of $totalPages'),
          IconButton(
            onPressed: currentPage < totalPages
                ? () {
              setState(() => currentPage++);
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Product Listing'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
                final cardMaxWidth = isMobile ? double.infinity : (isTablet ? 700.0 : 1100.0);
                final horizontalPadding = isMobile ? 8.0 : (isTablet ? 16.0 : 32.0);
                return Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(maxWidth: cardMaxWidth),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: buildSearchSection(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildAllProductsFilters(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: cardMaxWidth,
                                minWidth: isMobile ? 500 : 0,
                              ),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: buildAllProductsTable(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      buildPaginationControls(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';
import 'widgets/custom_dialog.dart';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
final List<String> allBrands = [
  'Alcatel', 'Allview', 'Amazon', 'Amoi', 'Apple', 'Archos', 'Asus', 'AT&T', 'Benefon',
  'BenQ', 'BenQ-Siemens', 'Bird', 'BlackBerry', 'Blackview', 'BLU', 'Bosch', 'BQ', 'Casio',
  'Cat', 'Celkon', 'Chea', 'Coolpad', 'Cubot', 'Dell', 'Doogee', 'Emporia', 'Energizer',
  'Ericsson', 'Eten', 'Fairphone', 'Fujitsu Siemens', 'Garmin-Asus', 'Gigabyte', 'Gionee',
  'Google', 'Haier', 'HMD', 'Honor', 'HP', 'HTC', 'Huawei', 'i-mate', 'i-mobile', 'Icemobile',
  'Infinix', 'Innostream', 'iNQ', 'Intex', 'itel', 'Jolla', 'Karbonn', 'Kyocera', 'Lava',
  'LeEco', 'Lenovo', 'LG', 'Maxon', 'Maxwest', 'Meizu', 'Micromax', 'Microsoft', 'Mitac',
  'Mitsubishi', 'Modu', 'Motorola', 'MWg', 'NEC', 'Neonode', 'NIU', 'Nokia', 'Nothing',
  'Nvidia', 'O2', 'OnePlus', 'Oppo', 'Orange', 'Oscal', 'Oukitel', 'Palm', 'Panasonic',
  'Pantech', 'Parla', 'Philips', 'Plum', 'Posh', 'Prestigio', 'QMobile', 'Qtek', 'Razer',
  'Realme', 'Sagem', 'Samsung', 'Sendo', 'Sewon', 'Sharp', 'Siemens', 'Sonim', 'Sony',
  'Sony Ericsson', 'Spice', 'T-Mobile', 'TCL', 'Tecno', 'Tel.Me.', 'Telit', 'Thuraya',
  'Toshiba', 'Ulefone', 'Umidigi', 'Unnecto', 'Vertu', 'verykool', 'vivo', 'VK Mobile',
  'Vodafone', 'Wiko', 'WND', 'XCute', 'Xiaomi', 'XOLO', 'Yezz', 'Yota', 'YU', 'ZTE'
];
class TicketListingPage extends StatefulWidget {
  final String status;
  final String? title;

  const TicketListingPage({super.key, required this.status, this.title});

  @override
  State<TicketListingPage> createState() => _TicketListingPageState();
}

class _TicketListingPageState extends State<TicketListingPage> {
  List<dynamic> allTickets = [];
  bool isLoading = true;

  final ticketIdController = TextEditingController();
  final brandController = TextEditingController();
  final productNameController = TextEditingController();
  final costMinController = TextEditingController();
  final costMaxController = TextEditingController();

  DateTime? tempInvoiceDateFrom;
  DateTime? tempInvoiceDateTo;
  DateTime? invoiceDateFrom;
  DateTime? invoiceDateTo;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    setState(() => isLoading = true);

    final authStore = Provider.of<AuthStore>(context, listen: false);
    final params = {
      if (widget.status != 'Inventory') "ticketStatus": widget.status,
      if (ticketIdController.text.isNotEmpty) "ticketId": ticketIdController.text,
      if (brandController.text.isNotEmpty) "brand": brandController.text,
      if (productNameController.text.isNotEmpty) "productName": productNameController.text,
      if (invoiceDateFrom != null) "invoiceDateFrom": invoiceDateFrom!.toIso8601String().split('T').first,
      if (invoiceDateTo != null) "invoiceDateTo": invoiceDateTo!.toIso8601String().split('T').first,
      if (costMinController.text.isNotEmpty) "costMin": costMinController.text,
      if (costMaxController.text.isNotEmpty) "costMax": costMaxController.text,
    };

    final uri = widget.status != 'Inventory'
        ? Uri.https('api.abcoped.shop', '/api/ticket/search-ticket', params)
        : Uri.https('api.abcoped.shop', '/api/ticket/inventory-ticket', params);

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        allTickets = json.decode(response.body);
      } else {
        showError('Failed to fetch tickets. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('An error occurred: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Error',
        maxWidth: 400,
        content: Text(message),
        actions: [DialogButton(label: 'OK', isPrimary: true, onPressed: () => Navigator.pop(context))],
      ),
    );
  }
  Future<void> showSoldTicketInfo(int ticketId) async {
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
                onPressed: () {downloadBillPdfFromData(bill);},
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
  // Future<void> downloadBillPdf(int ticketId) async {
  //   final authStore = Provider.of<AuthStore>(context, listen: false);
  //   final uri = Uri.parse('https://api.abcoped.shop/api/ticket/download-bill/$ticketId');
  //
  //   try {
  //     final response = await http.get(uri, headers: {
  //       'Authorization': 'Bearer ${authStore.token}',
  //       'Accept': 'application/pdf',
  //     });
  //
  //     if (response.statusCode == 200) {
  //       final blob = html.Blob([response.bodyBytes], 'application/pdf');
  //       final url = html.Url.createObjectUrlFromBlob(blob);
  //       final anchor = html.AnchorElement(href: url)
  //         ..setAttribute('download', 'Bill-$ticketId.pdf')
  //         ..click();
  //       html.Url.revokeObjectUrl(url);
  //     } else {
  //       _showAlertDialog('Failed to download PDF. Status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     _showAlertDialog('Error downloading PDF: $e');
  //   }
  // }
  Future<void> downloadBillPdfFromData(Map<String, dynamic> billData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Bill Details', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Text('Customer Name: ${billData['customerName'] ?? 'N/A'}'),
            pw.Text('Phone Number: ${billData['phoneNumber'] ?? 'N/A'}'),
            if (billData['gstId'] != null && billData['gstId'].toString().isNotEmpty)
              pw.Text('GST ID: ${billData['gstId']}'),
            pw.SizedBox(height: 12),
            pw.Text('Bill Number: ${billData['billNumber'] ?? 'N/A'}'),
            pw.Text('Bill Date: ${billData['billDate'] ?? 'N/A'}'),
            pw.SizedBox(height: 12),
            pw.Text('Mode of Payment: ${billData['modeOfPayment'] ?? 'N/A'}'),
            if (billData['onlineTrxId'] != null && billData['onlineTrxId'].toString().isNotEmpty)
              pw.Text('Online Trx ID: ${billData['onlineTrxId']}'),
            pw.Text('Place of Sale: ${billData['placeOfSale'] ?? 'N/A'}'),
            pw.SizedBox(height: 12),
            pw.Text('Profit: ₹${billData['profit'] ?? 'N/A'}'),
            pw.Text('Client ID: ${billData['clientId'] ?? 'N/A'}'),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();

    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'Bill.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  Future<void> showTicketInfo(int ticketId) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('https://api.abcoped.shop/api/ticket/check-ticket/$ticketId');

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Accept': 'application/json',
      });

      Navigator.pop(context);
      if (response.statusCode == 200) {
        final ticket = json.decode(response.body);
        final totalCost = (ticket['refurbishedCost'] ?? 0) + (ticket['acquisitionCost'] ?? 0);
        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            title: 'Ticket Details',
            maxWidth: 500,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ticket ID: ${ticket['ticketId'] ?? 'N/A'}'),
                Text('Brand: ${ticket['brand'] ?? 'NA'}'),
                Text('Product Name: ${ticket['productName'] ?? 'N/A'}'),
                Text('Status: ${ticket['ticketStatus'] ?? 'N/A'}'),
                Text('Acquisition Cost: ₹${ticket['acquisitionCost']}'),
                Text('Refurbished Cost: ₹${ticket['refurbishedCost'] ?? 'N/A'}'),
                Text('Invoice Date: ₹${ticket['invoiceDate'] ?? 'N/A'}'),
                Text('Total Cost: ₹$totalCost'),
              ],
            ),
            actions: [DialogButton(label: 'Close', onPressed: () => Navigator.pop(context))],
          ),
        );
      } else {
        showError('Failed to fetch ticket details. Status: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context);
      showError('Error fetching ticket details: $e');
    }
  }

  void confirmStatusChange(int ticketId, String currentStatus) {
    final statusOptions = ['QC1', 'QC2', 'LISTED', 'FACTORY', 'SCRAPED']
        .where((status) => status != currentStatus)
        .toList();

    String? selectedStatus;
    final commentController = TextEditingController();
    final costController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Change Ticket Status',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Status: $currentStatus'),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => selectedStatus = value,
              decoration: const InputDecoration(labelText: 'New Status'),
            ),
            TextField(controller: commentController, decoration: const InputDecoration(labelText: 'Comment (optional)')),
            TextField(controller: costController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost (optional)')),
          ],
        ),
        actions: [
          DialogButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
          DialogButton(
            label: 'Submit',
            isPrimary: true,
            onPressed: () {
              if (selectedStatus == null) {
                showError('Please select a new status.');
                return;
              }
              Navigator.pop(context);
              changeStatus(ticketId, selectedStatus!, comment: commentController.text.trim(), costText: costController.text.trim());
            },
          ),
        ],
      ),
    );
  }

  Future<void> changeStatus(int ticketId, String newStatus, {String? comment, String? costText}) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final uri = Uri.parse('https://api.abcoped.shop/api/ticket/$ticketId/status');

    final body = {
      'newStatus': newStatus,
      if (comment?.isNotEmpty ?? false) 'comment': comment,
      if (costText?.isNotEmpty ?? false) 'cost': int.tryParse(costText!) ?? 0,
    };

    try {
      final response = await http.post(uri,
          headers: {'Authorization': 'Bearer ${authStore.token}', 'Content-Type': 'application/json'},
          body: json.encode(body));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated for ticket $ticketId')));
        fetchTickets();
      } else {
        showError('Failed to update status. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error updating status: $e');
    }
  }

  Widget buildSearchSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: TextField(controller: ticketIdController, decoration: const InputDecoration(labelText: 'Ticket ID'))),
            const SizedBox(width: 12),
            // Expanded(child: TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Brand'))),
            Expanded(
              child: DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                items: allBrands,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Select brand',
                    border: OutlineInputBorder(),
                  ),
                ),
                selectedItem: brandController.text.isNotEmpty
                    ? brandController.text
                    : null,
                onChanged: (value) {
                    brandController.text = value ?? '';
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: productNameController, decoration: const InputDecoration(labelText: 'Product Name'))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) setState(() => tempInvoiceDateFrom = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Invoice Date From'),
                  child: Text(tempInvoiceDateFrom != null ? tempInvoiceDateFrom!.toIso8601String().split('T').first : 'Select date'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) setState(() => tempInvoiceDateTo = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Invoice Date To'),
                  child: Text(tempInvoiceDateTo != null ? tempInvoiceDateTo!.toIso8601String().split('T').first : 'Select date'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextField(controller: costMinController, decoration: const InputDecoration(labelText: 'Cost Min'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: costMaxController, decoration: const InputDecoration(labelText: 'Cost Max'))),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                invoiceDateFrom = tempInvoiceDateFrom;
                invoiceDateTo = tempInvoiceDateTo;
                fetchTickets();
              },
              child: const Text('Search'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                ticketIdController.clear();
                brandController.clear();
                productNameController.clear();
                costMinController.clear();
                costMaxController.clear();
                tempInvoiceDateFrom = null;
                tempInvoiceDateTo = null;
                invoiceDateFrom = null;
                invoiceDateTo = null;
                fetchTickets();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }
  Widget buildAppliedFilters() {
    final List<Widget> filters = [];

    if (ticketIdController.text.isNotEmpty) filters.add(buildFilterChip('Ticket ID: ${ticketIdController.text}', ticketIdController));
    if (brandController.text.isNotEmpty) filters.add(buildFilterChip('Brand: ${brandController.text}', brandController));
    if (productNameController.text.isNotEmpty) filters.add(buildFilterChip('Product: ${productNameController.text}', productNameController));
    if (costMinController.text.isNotEmpty) filters.add(buildFilterChip('Cost ≥ ${costMinController.text}', costMinController));
    if (costMaxController.text.isNotEmpty) filters.add(buildFilterChip('Cost ≤ ${costMaxController.text}', costMaxController));
    if (invoiceDateFrom != null) filters.add(buildFilterChip('From: ${invoiceDateFrom!.toIso8601String().split('T').first}', null, clearInvoiceFrom));
    if (invoiceDateTo != null) filters.add(buildFilterChip('To: ${invoiceDateTo!.toIso8601String().split('T').first}', null, clearInvoiceTo));

    return filters.isNotEmpty
        ? Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(spacing: 8, runSpacing: 8, children: filters),
    )
        : const SizedBox.shrink();
  }

  Widget buildFilterChip(String label, TextEditingController? controller, [VoidCallback? onClear]) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.clear),
      onDeleted: () {
        if (controller != null) controller.clear();
        onClear?.call();
        fetchTickets();
      },
    );
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

  void clearInvoiceFrom() => setState(() => invoiceDateFrom = null);
  void clearInvoiceTo() => setState(() => invoiceDateTo = null);

  Widget buildTicketCard(dynamic ticket) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      title: Text('${ticket['productName'] ?? 'Unnamed Product'}', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Status: ${ticket['ticketStatus'] ?? 'N/A'}\nProduct Cost: ₹${ticket['acquisitionCost'] ?? 'N/A'}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.visibility), onPressed: () => ticket['ticketStatus'] != 'SOLD' ?showTicketInfo(ticket['ticketId']):showSoldTicketInfo(ticket['ticketId'])),
          if (ticket['ticketStatus'] != 'SOLD')IconButton(icon: const Icon(Icons.edit), onPressed: () => confirmStatusChange(ticket['ticketId'], ticket['status'] ?? '')),
          if (ticket['ticketStatus'] == 'LISTED')
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'Create Bill',
              onPressed: () => createBill(ticket['ticketId']),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Tickets')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchSection(),
            buildAppliedFilters(),
            const SizedBox(height: 16),
            ...allTickets.map(buildTicketCard),
          ],
        ),
      ),
    );
  }
}

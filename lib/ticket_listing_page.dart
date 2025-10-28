import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/sell_cart_page.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'widgets/custom_dialog.dart';
import 'dart:typed_data';
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
  List<T> reverseList<T>(List<T> list) {
    return list.reversed.toList();
  }
  List<dynamic> reverseAllTickets = [];
  bool isLoading = true;
  bool _isSortedAsc = true;

  final ticketIdController = TextEditingController();
  final brandController = TextEditingController();
  final productNameController = TextEditingController();
  final costMinController = TextEditingController();
  final costMaxController = TextEditingController();
  int cartCount = 0;
  DateTime? tempInvoiceDateFrom;
  DateTime? tempInvoiceDateTo;
  DateTime? invoiceDateFrom;
  DateTime? invoiceDateTo;

  @override
  void initState() {
    super.initState();
    fetchTickets();
    if(widget.status == 'LISTED') {
      fetchCartCount();
    }
   ;
  }
  // Future<void> sortTapped() async {
  //
  //   setState(() => isLoading = true);
  //
  // }

  Future<void> fetchTickets() async {


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
        reverseAllTickets = allTickets.reversed.toList();

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
        final invoice = ticket['invoiceDto'];

        final totalCost = (ticket['refurbishedCost'] ?? 0) + (ticket['acquisitionCost'] ?? 0);

        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            title: 'Ticket & Invoice Details',
            maxWidth: 600,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ticket ID: ${ticket['ticketId']}'),
                  Text('Product Name: ${ticket['productName']}'),
                  Text('Status: ${ticket['ticketStatus']}'),
                  Text('Brand: ${ticket['brand']}'),
                  // Text('Acquisition Cost: ₹${ticket['acquisitionCost']}'),
                  // Text('Refurbished Cost: ₹${ticket['refurbishedCost'] ?? 0}'),
                  if(invoice != null)Text('Invoice Date: ${invoice['invoiceDate'] ?? 'N/A'}'),
                  Text('Total Cost: ₹$totalCost'),
                  const Divider(),
                  if ((invoice != null && widget.status == 'LISTED')||
                      (invoice != null && widget.status == 'Inventory')||
                      (invoice != null && widget.status == '') ) ...[
                    Text('Invoice Number: ${invoice['invoiceNumber']}'),
                    Text('Customer Name: ${invoice['customerName']}'),
                    Text('Phone: ${invoice['phoneNumber']}'),
                    Text('GST No: ${invoice['gstNumber']}'),
                    Text('Product Purchase Type: ${invoice['productPurchaseType']}'),
                    const SizedBox(height: 10),
                    Text('Payments:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...List<Widget>.from(invoice['payments'].map<Widget>((payment) {
                      return Text(
                        '• ${payment['modeOfPayment']} - ₹${payment['amount']}'
                            '${payment['transactionId'] != null ? ' (Txn: ${payment['transactionId']})' : ''}'
                            '${payment['paidAt'] != null ? ' on ${payment['paidAt']}' : ''}',
                      );
                    })),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => generateInvoicePdf(ticket,'Invoice'),
                      child: const Text('Download Invoice PDF'),
                    ),
                  ]
                ],
              ),
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


  Future<void> showSoldTicketBill(int ticketId) async {
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
        final invoice = ticket['invoiceDto'];
        final bill = ticket['billResponseDto'];
        final totalCost = (ticket['refurbishedCost'] ?? 0) + (ticket['acquisitionCost'] ?? 0);

        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            title: 'Ticket & Billing Details',
            maxWidth: 600,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ticket ID: ${ticket['ticketId']}'),
                  Text('Product: ${ticket['productName']}'),
                  Text('Status: ${ticket['ticketStatus']}'),
                  Text('Brand: ${ticket['brand']}'),
                  Text('Acquisition Cost: ₹${ticket['acquisitionCost']}'),
                  Text('Refurbished Cost: ₹${ticket['refurbishedCost'] ?? 0}'),
                  Text('Total Cost: ₹$totalCost'),
                  const Divider(),

                  if (bill != null) ...[
                    Text('Bill Number: ${bill['billNumber']}'),
                    Text('Bill Date: ${bill['billDate']}'),
                    Text('Customer Name: ${bill['customerName']}'),
                    Text('Phone: ${bill['phoneNumber']}'),
                    Text('GST ID: ${bill['gstId'] ?? 'N/A'}'),
                    Text('Place of Sale: ${bill['placeOfSale']}'),
                    Text('Profit: ₹${bill['profit'] ?? 'N/A'}'),
                    const SizedBox(height: 10),
                    Text('Payments:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...List<Widget>.from(bill['payments'].map<Widget>((pmt) {
                      return Text(
                        '• ${pmt['modeOfPayment']} - ₹${pmt['amount']}'
                            '${pmt['transactionId'] != null ? ' (Txn: ${pmt['transactionId']})' : ''}'
                            '${pmt['paidAt'] != null ? ' on ${pmt['paidAt']}' : ''}',
                      );
                    })),
                    const Divider(),
                    Text('Products:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...List<Widget>.from(bill['products'].map<Widget>((prod) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ${prod['productName']} (${prod['brand']})'),
                          Text('  RAM/ROM: ${prod['ramRomSpecs'] ?? '-'}'),
                          Text('  IMEI: ${prod['imeiNo']}  | Serial: ${prod['serialNo']}'),
                          Text('  Warranty: ${prod['warranty']}'),
                        ],
                      );
                    })),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => generateInvoicePdf(ticket,'Bill'),
                      child: const Text('Download Bill PDF'),
                    ),
                  ] else if (invoice != null) ...[
                    Text('Invoice Number: ${invoice['invoiceNumber']}'),
                    Text('Invoice Date: ${invoice['invoiceDate']}'),
                    Text('Customer Name: ${invoice['customerName']}'),
                    Text('Phone: ${invoice['phoneNumber']}'),
                    Text('GST ID: ${invoice['gstId']}'),
                    Text('Product Purchase Type: ${invoice['productPurchaseType']}'),
                    const SizedBox(height: 10),
                    Text('Payments:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...List<Widget>.from(invoice['payments'].map<Widget>((pmt) {
                      return Text(
                        '• ${pmt['modeOfPayment']} - ₹${pmt['amount']}'
                            '${pmt['transactionId'] != null ? ' (Txn: ${pmt['transactionId']})' : ''}'
                            '${pmt['paidAt'] != null ? ' on ${pmt['paidAt']}' : ''}',
                      );
                    })),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => generateInvoicePdf(ticket,'Bill'),
                      child: const Text('Download Invoice PDF'),
                    ),
                  ] else ...[
                    const Text('No billing or invoice data found.'),
                  ],
                ],
              ),
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
  Widget _buildTicketsTable() {
    if (allTickets.isEmpty) {
      return const Center(child: Text("No tickets found."));
    }

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
          columns: const [
            DataColumn(label: Text("Ticket ID")),
            DataColumn(label: Text("Product Name")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Cost")),
            DataColumn(label: Text("Actions")),
          ],
          rows: _isSortedAsc ? allTickets.map((ticket)  {
            final cost = (ticket['acquisitionCost'] ?? 0).toString();
            return DataRow(cells: [
              DataCell(Text(ticket['ticketId'].toString())),
              DataCell(Text(ticket['productName'] ?? 'N/A')),
              DataCell(Text(ticket['ticketStatus'] ?? 'N/A')),
              DataCell(Text("₹$cost")),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    tooltip: "View Ticket",
                    onPressed: () => showSoldTicketInfo(ticket['ticketId']),
                  ),
                  if (ticket['ticketStatus'] == 'SOLD')
                    IconButton(
                      icon: const Icon(Icons.receipt_rounded),
                      tooltip: "View Bill",
                      onPressed: () => showSoldTicketBill(ticket['ticketId']),
                    ),
                  if ((widget.status == 'QC') ||
                      (widget.status == 'Factory') ||
                      (widget.status == 'Scraped') ||
                      (widget.status == 'LISTED'))
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: "Change Status",
                      onPressed: () => confirmStatusChange(
                          ticket['ticketId'], ticket['status'] ?? ''),
                    ),
                  if (ticket['ticketStatus'] == 'LISTED')
                    IconButton(
                      icon: const Icon(Icons.receipt_long),
                      tooltip: 'Create Bill',
                      onPressed: () => addToSellCart(
                        ticketIds: [ticket['ticketId']],
                        authToken:
                        Provider.of<AuthStore>(context, listen: false).token ??
                            '',
                      ).then((success) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to Sell Cart')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Failed to add to Sell Cart')));
                        }
                      }),
                    ),
                ],
              )),
            ]);
          }).toList() : reverseAllTickets.map((ticket)  {
            final cost = (ticket['acquisitionCost'] ?? 0).toString();
            return DataRow(cells: [
              DataCell(Text(ticket['ticketId'].toString())),
              DataCell(Text(ticket['productName'] ?? 'N/A')),
              DataCell(Text(ticket['ticketStatus'] ?? 'N/A')),
              DataCell(Text("₹$cost")),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    tooltip: "View Ticket",
                    onPressed: () => showSoldTicketInfo(ticket['ticketId']),
                  ),
                  if (ticket['ticketStatus'] == 'SOLD')
                    IconButton(
                      icon: const Icon(Icons.receipt_rounded),
                      tooltip: "View Bill",
                      onPressed: () => showSoldTicketBill(ticket['ticketId']),
                    ),
                  if ((widget.status == 'QC') ||
                      (widget.status == 'Factory') ||
                      (widget.status == 'Scraped') ||
                      (widget.status == 'LISTED'))
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: "Change Status",
                      onPressed: () => confirmStatusChange(
                          ticket['ticketId'], ticket['status'] ?? ''),
                    ),
                  if (ticket['ticketStatus'] == 'LISTED')
                    IconButton(
                      icon: const Icon(Icons.receipt_long),
                      tooltip: 'Create Bill',
                      onPressed: () => addToSellCart(
                        ticketIds: [ticket['ticketId']],
                        authToken:
                        Provider.of<AuthStore>(context, listen: false).token ??
                            '',
                      ).then((success) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to Sell Cart')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Failed to add to Sell Cart')));
                        }
                      }),
                    ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void confirmStatusChange(int ticketId, String currentStatus) {
    final statusOptions = ['QC', 'LISTED', 'FACTORY', 'SCRAPED']
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
            // DropdownButtonFormField<String>(
            //   value: selectedStatus,
            //   items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            //   onChanged: (value) => selectedStatus = value,
            //   decoration: const InputDecoration(labelText: 'New Status'),
            // ),
            StatusDropdown(
              currentStatus: widget.status,
              value: selectedStatus,
              onChanged: (val) {
                setState(() {
                  selectedStatus = val;
                });
              },
            ),
            TextField(controller: commentController, decoration: const InputDecoration(labelText: 'Comment')),
            if(widget.status == 'Factory')TextField(controller: costController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Refurbishment Cost')),
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
        await authStore.fetchTicketStatusCounts();
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
            IconButton(
              icon: Icon(
                _isSortedAsc ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.blue, // keep your blue theme
              ),
              onPressed: () {
                // Toggle the sort order
                setState(() {
                  _isSortedAsc = !_isSortedAsc;
                });

                // Call your search/sort function
                //sortTapped();
              },
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
          IconButton(icon: const Icon(Icons.visibility), onPressed: () => showSoldTicketInfo(ticket['ticketId'])),
          if (ticket['ticketStatus'] == 'SOLD')IconButton(icon: const Icon(Icons.receipt_rounded), onPressed: () => showSoldTicketBill(ticket['ticketId'])),
          if ((widget.status =='QC' ))IconButton(icon: const Icon(Icons.edit), onPressed: () => confirmStatusChange(ticket['ticketId'], ticket['status'] ?? '')),
          if ((widget.status =='Factory' ))IconButton(icon: const Icon(Icons.edit), onPressed: () => confirmStatusChange(ticket['ticketId'], ticket['status'] ?? '')),
          if ((widget.status =='Scraped' ))IconButton(icon: const Icon(Icons.edit), onPressed: () => confirmStatusChange(ticket['ticketId'], ticket['status'] ?? '')),
          if ((widget.status =='LISTED' ))IconButton(icon: const Icon(Icons.edit), onPressed: () => confirmStatusChange(ticket['ticketId'], ticket['status'] ?? '')),

          if (ticket['ticketStatus'] == 'LISTED')
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'Create Bill',
              onPressed: () => addToSellCart(
                ticketIds: [ticket['ticketId']],
                authToken: Provider.of<AuthStore>(context, listen: false).token ?? '',
              ).then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Sell Cart')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add to Sell Cart')));
                }
              }
            ),
            )
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Tickets'),
        actions: [
          if (widget.status == 'LISTED')
            Stack(
        alignment: Alignment.topRight,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Go to Cart',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SellCartPage()),
              );
              fetchCartCount(); // Refresh count after returning
            },
          ),
          if (cartCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$cartCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          const Padding(padding: EdgeInsets.only(right: 16),
          ),
        ],
      ),

      ],),
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
            // ...allTickets.map(buildTicketCard),
            _buildTicketsTable(),
          ],
        ),
      ),
    );
  }
  Future<void> fetchCartCount() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    try {
      final uri = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items?cartType=SELL');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${authStore.token}',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cartCount = data['totalElements'] ?? 0;
        });
      }
    } catch (e) {
      // Handle errors silently or show snackbar/log
    }
  }

  Future<bool> addToSellCart({
    required List<int> ticketIds,
    required String authToken,
  }) async {
    final url = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items/sell/add');

    try {
      final sellingCost = await _showSellingCostDialog();
      if (sellingCost == null) {
        // User cancelled the dialog
        return false;
      }
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ticketIds': ticketIds,
          'sellingCost':sellingCost
        }),
      );

      if (response.statusCode == 200) {
        await fetchCartCount();
        setState(() {
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<double?> _showSellingCostDialog() async {
    final TextEditingController controller = TextEditingController();

    return showDialog<double>(
      context: context,
      barrierDismissible: false, // User must confirm or cancel explicitly
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Enter Selling Cost'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Selling cost',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(null); // Cancelled
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                final text = controller.text.trim();
                final cost = double.tryParse(text);
                if (cost != null) {
                  Navigator.of(dialogContext).pop(cost);
                } else {
                  // Optionally show error or ignore
                }
              },
            ),
          ],
        );
      },
    );
  }



  void generateInvoicePdf(Map<String, dynamic> ticket, String journey) async {
    final pdf = pw.Document();
    final invoice = ticket['invoiceDto'] ?? {};

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(journey, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Invoice Number: ${invoice['invoiceNumber'] ?? 'N/A'}'),
              pw.Text('Invoice Date: ${invoice['invoiceDate'] ?? 'N/A'}'),
              pw.Text('Customer Name: ${invoice['customerName'] ?? 'N/A'}'),
              pw.Text('Phone: ${invoice['phoneNumber'] ?? 'N/A'}'),
              pw.Text('GST ID: ${invoice['gstId'] ?? 'N/A'}'),
              pw.SizedBox(height: 10),
              pw.Text('Payments:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...List<pw.Widget>.from((invoice['payments'] ?? []).map<pw.Widget>((payment) {
                return pw.Text(
                  '${payment['modeOfPayment'] ?? 'N/A'}: ₹${payment['amount'] ?? 0}'
                      '${payment['transactionId'] != null ? ' (Txn: ${payment['transactionId']})' : ''}'
                      '${payment['paidAt'] != null ? ' on ${payment['paidAt']}' : ''}',
                );
              })),
            ],
          );
        },
      ),
    );

    // Ensure valid Uint8List output
    final Uint8List pdfBytes = await pdf.save();

    // Create blob and download link
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'invoice_${ticket['ticketId']}.pdf')
      ..click();

    html.Url.revokeObjectUrl(url);
  }


}

class StatusDropdown extends StatelessWidget {
  final String currentStatus;
  final String? value;
  final void Function(String?) onChanged;

  const StatusDropdown({
    super.key,
    required this.currentStatus,
    required this.value,
    required this.onChanged,
  });

  List<String> getStatusOptions(String currentStatus) {
    switch (currentStatus) {
      case 'QC':
        return ['LISTED', 'FACTORY', 'SCRAPED'];
      case 'LISTED':
        return ['SCRAPED'];
      case 'Factory':
        return ['QC', 'SCRAPED'];
      case 'Scraped':
        return ['QC'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusOptions = getStatusOptions(currentStatus);

    return DropdownButtonFormField<String>(
      value: value,
      items: statusOptions
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(labelText: 'New Status'),
      validator: (val) => val == null ? 'Please select a new status' : null,
    );
  }
}


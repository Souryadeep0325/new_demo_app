import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/sell_cart_page.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'widgets/custom_dialog.dart';
import 'package:excel/excel.dart';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
List<dynamic> allTicketsFinal = [];
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



  void exportExcelWeb(List<Map<String, dynamic>> tickets) {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Tickets'];

    // Add header
    sheetObject.appendRow([
      "Ticket ID",
      "Status",
      "Item ID",
      "Serial No",
      "RAM/ROM",
      "Color Specs",
      "Comment",
      "Invoice Date",
      "Invoice Number"
    ]);

    // Add data rows
    for (var ticket in tickets) {
      sheetObject.appendRow([
        ticket['ticketId'],
        ticket['ticketStatus'],
        ticket['itemId'],
        ticket['itemSerialNo'],
        ticket['ramRomSpecs'] ?? "",
        ticket['colorSpecs'] ?? "",
        ticket['comment'] ?? "",
        ticket['invoiceDto']?['invoiceDate'] ?? "",
        ticket['invoiceDto']?['invoiceNumber'] ?? ""
      ]);
    }

    var fileBytes = excel.encode();

    // Trigger browser download
    final content = base64Encode(fileBytes!);
    final anchor = html.AnchorElement(
        href: "data:application/octet-stream;base64,$content")
      ..setAttribute("download", "tickets.xlsx")
      ..click();
  }

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
        allTicketsFinal = allTickets;
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



  Widget buildBillDetailsWidget(Map<String, dynamic> bill, Map<String, dynamic> ticket, Function generateBillPdf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Billing Details:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text('Bill Number: ${bill['billNumber']}'),
        Text('Bill Date: ${bill['billDate']}'),
        Text('Customer Name: ${bill['customerName']}'),
        Text('Phone: ${bill['phoneNumber']}'),
        Text('GST ID: ${bill['gstId'] ?? 'N/A'}'),
        Text('Place of Sale: ${bill['placeOfSale']}'),
        Text('Profit: ₹${bill['profit'] ?? 'N/A'}'),
        const SizedBox(height: 10),

        Text('Payments:', style: const TextStyle(fontWeight: FontWeight.bold)),
        ...List<Widget>.from((bill['payments'] ?? []).map<Widget>((pmt) {
          return Text(
            '• ${pmt['modeOfPayment']} - ₹${pmt['amount']}'
                '${pmt['transactionId'] != null ? ' (Txn: ${pmt['transactionId']})' : ''}'
                '${pmt['paidAt'] != null ? ' on ${pmt['paidAt']}' : ''}',
          );
        })),

        const Divider(),

        Text('Products:', style: const TextStyle(fontWeight: FontWeight.bold)),
        ...List<Widget>.from((bill['products'] ?? []).map<Widget>((prod) {
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
          onPressed: () => generateBillPdf(ticket, 'Bill'),
          child: const Text('Download Bill PDF'),
        ),
      ],
    );
  }



  Widget buildInvoiceDetailsWidget(
      Map<String, dynamic> ticket,
      Map<String, dynamic>? invoice,
      Function generateInvoicePdf,
      ) {
    if (invoice == null || invoice.isEmpty) {
      return const Text('No billing or invoice data found.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invoice Details:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text('Invoice Number: ${invoice['invoiceNumber']}'),
        Text('Invoice Date: ${invoice['invoiceDate']}'),
        Text('Customer Name: ${invoice['customerName']}'),
        Text('Phone: ${invoice['phoneNumber']}'),
        Text('GST ID: ${invoice['gstId'] ?? 'N/A'}'),
        Text('Product Purchase Type: ${invoice['productPurchaseType'] ?? 'N/A'}'),
        const SizedBox(height: 10),

        Text('Payments:', style: const TextStyle(fontWeight: FontWeight.bold)),
        ...List<Widget>.from((invoice['payments'] ?? []).map<Widget>((pmt) {
          return Text(
            '• ${pmt['modeOfPayment']} - ₹${pmt['amount']}'
                '${pmt['transactionId'] != null ? ' (Txn: ${pmt['transactionId']})' : ''}'
                '${pmt['paidAt'] != null ? ' on ${pmt['paidAt']}' : ''}',
          );
        })),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: () => generateInvoicePdf(ticket, 'Bill'),
          child: const Text('Download Invoice PDF'),
        ),
      ],
    );
  }


  Widget detailText(String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();

    return RichText(
      text: TextSpan(
        text: '$label: ',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
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
                  // Row(
                  //   children: [
                  //     Text('Ticket ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                  //     Text(' ${ticket['ticketId']}')
                  //   ],
                  // ),
                  // Text('Product: ${ticket['productName']}'),
                  // Text('Status: ${ticket['ticketStatus']}'),
                  // Text('Brand: ${ticket['brand']}'),
                  // Text('Acquisition Cost: ₹${ticket['acquisitionCost']}'),
                  // Text('Refurbished Cost: ₹${ticket['refurbishedCost'] ?? 0}'),
                  // Text('Total Cost: ₹$totalCost'),
                  detailText("Ticket ID", "${ticket['ticketId']}"),
                  detailText("Product", ticket['productName']),
                  detailText("Status", ticket['ticketStatus']),
                  detailText("Brand", ticket['brand']),
                  detailText("Acquisition Cost", "₹${ticket['acquisitionCost']}"),
                  detailText("Refurbished Cost", "₹${ticket['refurbishedCost'] ?? 0}"),
                  detailText("Total Cost", "₹$totalCost"),

                  // New optional fields
                  detailText("Battery Health", ticket['batteryHealth']),
                  detailText("Warranty", ticket['warranty']),
                  detailText("Box Included", ticket['boxFlag'] == "Y" ? "Yes" : "No"),
                  detailText("Charger Included", ticket['chargerFlag'] == "N" ? "No" : "Yes"),
                  detailText("Sealed", ticket['sealedFlag'] == "Y" ? "Yes" : "No"),
                  detailText("Invoice Included", ticket['invoiceFlag'] == "Y" ? "Yes" : "No"),
                  detailText("RAM/ROM", ticket['ramRomSpecs']),
                  detailText("Color", ticket['colorSpecs']),

                  SingleChildScrollView(
                    child: buildTicketCommentsWidget(ticket['comment']),
                  ),
                  const Divider(),

                  if(bill != null && (widget.status == 'SOlD' || widget.status == '') )
                    buildBillDetailsWidget(bill, ticket, generateBillPdf),
                    if (invoice != null && (widget.status == "" || widget.status == 'LISTED' || widget.status == 'Inventory'))
        buildInvoiceDetailsWidget(ticket, invoice, generateInvoicePdf),
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
          columns: [
            const DataColumn(label: Text("Ticket ID")),
            const DataColumn(label: Text("Product Name")),
            const DataColumn(label: Text("Status")),
            const DataColumn(label: Text("Cost")),
            if(widget.status == 'LISTED' || widget.status == 'QC' || widget.status == 'Factory')
              const DataColumn(label: Text("Refurbishment Cost")),

            const DataColumn(label: Text("Invoice Date")),

            if (widget.status == 'SOLD'|| widget.status == 'Inventory'|| widget.status == '' )
              const DataColumn(label: Text("Bill Date")),

            const DataColumn(label: Text("Actions")),
          ],
          rows: _isSortedAsc ? allTickets.map((ticket)  {

            final cost = (ticket['acquisitionCost'] ?? 0).toString();
            final totalCost = (ticket['refurbishedCost'] ?? 0).toString();
            final invoice = ticket['invoiceDto'];
            final bill = ticket['billResponseDto'];
            return DataRow(cells: [
              DataCell(Text(ticket['ticketId'].toString())),
              DataCell(Text(ticket['productName'] ?? 'N/A')),
              DataCell(Text(ticket['ticketStatus'] ?? 'N/A')),
              DataCell(Text("₹$cost")),

              if(widget.status == 'LISTED' || widget.status == 'QC' || widget.status == 'Factory')
                  DataCell(Text("₹$totalCost")) ,
              invoice == null || invoice.isEmpty? const DataCell(Text("")):DataCell(Text("${invoice['invoiceDate']}")),
              if(widget.status == 'SOLD' || widget.status == 'Inventory'|| widget.status == '')
                  (bill == null || bill.isEmpty) ? const DataCell(Text("")):DataCell(Text("${bill['billDate']}")),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    tooltip: "View Ticket",
                    onPressed: () => showSoldTicketBill(ticket['ticketId']),
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
                  if (widget.status == 'LISTED')
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
            final totalCost = (ticket['refurbishedCost'] ?? 0).toString();
            final invoice = ticket['invoiceDto'];
            final bill = ticket['billResponseDto'];
            return DataRow(cells: [
              DataCell(Text(ticket['ticketId'].toString())),
              DataCell(Text(ticket['productName'] ?? 'N/A')),
              DataCell(Text(ticket['ticketStatus'] ?? 'N/A')),
              DataCell(Text("₹$cost")),
              if(widget.status == 'LISTED' || widget.status == 'QC' || widget.status == 'Factory')
              DataCell(Text("₹$totalCost")),
              invoice == null || invoice.isEmpty ? DataCell(Text("")):DataCell(Text("${invoice['invoiceDate']}")),
               if(ticket['ticketStatus'] == 'SOLD' || widget.status == 'Inventory'|| widget.status == '')
               (bill == null || bill.isEmpty) ? DataCell(Text("")):DataCell(Text("${bill['billDate']}")),

              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    tooltip: "View Ticket",
                    onPressed: () => showSoldTicketBill(ticket['ticketId']),
                  ),
                  if (widget.status == 'SOLD')
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
                  if (widget.status == 'LISTED')
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
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
          IconButton(
            tooltip: 'Sort By Date',
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
          IconButton(
            tooltip: 'Export To Excel',
            icon: const Icon(
              Icons.send,
              color: Colors.blue, // keep your blue theme
            ),
            onPressed: () async {
              // Suppose this is your API response
              List<Map<String, dynamic>> apiResponse =
              allTicketsFinal.map((e) => e as Map<String, dynamic>).toList(); // your JSON data here
              exportExcelWeb(apiResponse);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Excel exported successfully!')),
              );
            },
          ),
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
        ],)
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

  List<Map<String, String>> parseTicketComments(String? commentText) {
    if (commentText == null || commentText.trim().isEmpty || commentText == "null") {
      return [];
    }

    final commentPattern = RegExp(
      r'Ticket has been updated to status (.*?) on (.*?) at (.*?)\.\s*Comment added by (.*?) : (.*?)(?=Ticket has been updated|$)',
      dotAll: true,
    );

    final matches = commentPattern.allMatches(commentText);
    return matches.map((m) {
      return {
        'status': m.group(1)?.trim() ?? '',
        'date': m.group(2)?.trim() ?? '',
        'time': m.group(3)?.trim() ?? '',
        'user': m.group(4)?.trim() ?? '',
        'comment': m.group(5)?.trim() ?? '',
      };
    }).toList();
  }

  Widget buildTicketCommentsWidget(String? commentText) {
    final comments = parseTicketComments(commentText);

    if (comments.isEmpty) {
      return const Text('No comments available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ticket Comments:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...comments.map((c) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${c['status']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Date: ${c['date']} at ${c['time']}'),
                  Text('By: ${c['user']}'),
                  const SizedBox(height: 4),
                  Text('Comment: ${c['comment']}'),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }




  Future<void> generateBillPdf(Map<String, dynamic> ticket, String type) async {
    // Use billResponseDto for main info
    final bill = ticket['billResponseDto'] ?? ticket;
    // Use invoiceDto if exists
    final invoice = ticket['invoiceDto'];

    final pdf = pw.Document();

    final logo = await imageFromAssetBundle('assets/images.png'); // replace with your asset

    final products = (invoice?['products'] ?? bill['products'] ?? []) as List<dynamic>;
    pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
          // Header
          pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Image(logo, width: 80),
            pw.Text(
              '$type Invoice',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.SizedBox(height: 16),

        // Bill / Customer Info
        pw.Divider(),
        pw.Text('Bill Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),

        pw.Text('Bill Number: ${bill['billNumber'] ?? '-'}'),
        pw.Text('Bill Date: ${bill['billDate'] ?? '-'}'),
        pw.Text('Customer Name: ${bill['customerName'] ?? '-'}'),
        pw.Text('Phone: ${bill['phoneNumber'] ?? '-'}'),
        pw.Text('GST ID: ${bill['gstId'] ?? '-'}'),
        pw.Text('Place of Sale: ${bill['placeOfSale'] ?? '-'}'),
        pw.Text('Profit: ₹${bill['profit'] != null ? bill['profit'].toStringAsFixed(2) : '-'}'),

        pw.SizedBox(height: 12),

        // Payments Section
        pw.Text('Payments', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),

        if ((invoice?['payments'] ?? bill['payments'] ?? []).isEmpty)
    pw.Text('No payment records found.')
    else
    pw.Table.fromTextArray(
    headers: ['Mode', 'Amount', 'Txn ID', 'Paid At'],
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
    cellAlignment: pw.Alignment.centerLeft,

    data: (bill['payments'] ?? [])
        .map<List<String>>((pmt) => [
    pmt['modeOfPayment']?.toString() ?? '-',
    pmt['amount'] != null ? '₹${(pmt['amount'] as num).toStringAsFixed(2)}' : '-',
    pmt['transactionId']?.toString() ?? '-',
    pmt['paidAt']?.toString() ?? '-',
    ])
        .toList(),
    ),

    pw.SizedBox(height: 16),

    // Products Section
    pw.Text('Products', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
    pw.SizedBox(height: 8),

    if (products.isEmpty)
    pw.Text('No products found.')
    else
    pw.Table.fromTextArray(
    headers: ['Product', 'Brand', 'RAM/ROM', 'IMEI', 'Serial', 'Warranty'],
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
    cellAlignment: pw.Alignment.centerLeft,
    data: (products as List<dynamic>)
        .map<List<String>>((prod) => [
    prod['productName']?.toString() ?? '-',
    prod['brand']?.toString() ?? '-',
    prod['ramRomSpecs']?.toString() ?? '-',
    prod['imeiNo']?.toString() ?? '-',
    prod['serialNo']?.toString() ?? '-',
    prod['warranty']?.toString() ?? '-',
    ])
        .toList(),
    ),

    pw.SizedBox(height: 20),

    // Footer
    pw.Divider(),
    pw.Center(
    child: pw.Text(
    'Thank you for your business!',
    style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
    ),
    ),
    ],
    ),
    );

    await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Future<void> generateBillPdf(Map<String, dynamic> ticket, String type) async {
  //   final bill = ticket['bill'] ?? ticket;
  //
  //   final pdf = pw.Document();
  //
  //   // Load your logo (you can replace this with a real asset or network image)
  //   final logo = await imageFromAssetBundle('assets/images.png'); // Add logo.png to assets folder
  //
  //   pdf.addPage(
  //     pw.MultiPage(
  //       pageFormat: PdfPageFormat.a4,
  //       margin: const pw.EdgeInsets.all(24),
  //       build: (context) => [
  //         // Header with logo and title
  //         pw.Row(
  //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //           children: [
  //             pw.Image(logo, width: 80),
  //             pw.Text(
  //               '$type Invoice',
  //               style: pw.TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: pw.FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //         pw.SizedBox(height: 16),
  //
  //         // Customer & Bill Info
  //         pw.Divider(),
  //         pw.Text('Bill Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
  //         pw.SizedBox(height: 8),
  //
  //         pw.Text('Bill Number: ${bill['billNumber']}'),
  //         pw.Text('Bill Date: ${bill['billDate']}'),
  //         pw.Text('Customer Name: ${bill['customerName']}'),
  //         pw.Text('Phone: ${bill['phoneNumber']}'),
  //         pw.Text('GST ID: ${bill['gstId'] ?? 'N/A'}'),
  //         pw.Text('Place of Sale: ${bill['placeOfSale']}'),
  //         pw.Text('Profit: ₹${bill['profit'] ?? 'N/A'}'),
  //
  //         pw.SizedBox(height: 12),
  //
  //         // Payments Section
  //         pw.Text('Payments', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
  //         pw.SizedBox(height: 8),
  //
  //         if ((bill['payments'] ?? []).isEmpty)
  //           pw.Text('No payment records found.')
  //         else
  //           pw.Table.fromTextArray(
  //             headers: ['Mode', 'Amount', 'Txn ID', 'Paid At'],
  //             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //             headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
  //             cellAlignment: pw.Alignment.centerLeft,
  //             data: List<List<String>>.from((bill['payments'] ?? []).map((pmt) => [
  //               pmt['modeOfPayment'] ?? '-',
  //               '₹${pmt['amount'] ?? ''}',
  //               pmt['transactionId'] ?? '-',
  //               pmt['paidAt'] ?? '-',
  //             ])),
  //           ),
  //
  //         pw.SizedBox(height: 16),
  //
  //         // Products Section
  //         pw.Text('Products', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
  //         pw.SizedBox(height: 8),
  //
  //         if ((bill['products'] ?? []).isEmpty)
  //           pw.Text('No products found.')
  //         else
  //           pw.Table.fromTextArray(
  //             headers: ['Product', 'Brand', 'RAM/ROM', 'IMEI', 'Serial', 'Warranty'],
  //             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //             headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
  //             cellAlignment: pw.Alignment.centerLeft,
  //             data: List<List<String>>.from((bill['products'] ?? []).map((prod) => [
  //               prod['productName'] ?? '-',
  //               prod['brand'] ?? '-',
  //               prod['ramRomSpecs'] ?? '-',
  //               prod['imeiNo'] ?? '-',
  //               prod['serialNo'] ?? '-',
  //               prod['warranty'] ?? '-',
  //             ])),
  //           ),
  //
  //         pw.SizedBox(height: 20),
  //
  //         // Footer
  //         pw.Divider(),
  //         pw.Center(
  //           child: pw.Text(
  //             'Thank you for your business!',
  //             style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   // Display the PDF in viewer or print
  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => pdf.save(),
  //   );
  // }


  Future<void> generateInvoicePdf(Map<String, dynamic> ticket, String type) async {
    final bill = ticket['invoiceDto'] ?? ticket; // Use invoiceDto if available

    final pdf = pw.Document();

    // Load your logo (replace with your actual asset)
    final logo = await imageFromAssetBundle('assets/images.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          // Header with logo and title
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(logo, width: 80),
              pw.Text(
                '$type Invoice',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Bill / Customer Info
          pw.Divider(),
          pw.Text('Invoice Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),

          pw.Text('Bill Number: ${bill['invoiceNumber'] ?? '-'}'),
          pw.Text('Bill Date: ${bill['invoiceDate'] ?? '-'}'),
          pw.Text('Customer Name: ${bill['customerName'] ?? '-'}'),
          pw.Text('Phone: ${bill['phoneNumber'] ?? '-'}'),
          pw.Text('GST ID: ${bill['gstId'] ?? '-'}'),
          pw.Text('Place of Sale: ${ticket['storeName'] ?? '-'}'),
          pw.Text('Profit: ₹${ticket['refurbishedCost'] != null && ticket['acquisitionCost'] != null ? (ticket['refurbishedCost'] - ticket['acquisitionCost']).toStringAsFixed(2) : 'N/A'}'),

          pw.SizedBox(height: 12),

          // Payments Section
          pw.Text('Payments', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),

          if ((bill['payments'] ?? []).isEmpty)
            pw.Text('No payment records found.')
          else
            pw.Table.fromTextArray(
              headers: ['Mode', 'Amount', 'Txn ID', 'Paid At'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              data: (bill['payments'] ?? []).map<List<String>>((p) {
                return [
                  p['modeOfPayment']?.toString() ?? '-',
                  p['amount'] != null ? '₹${p['amount'].toStringAsFixed(2)}' : '-',
                  p['transactionId']?.toString() ?? '-',
                  p['paidAt']?.toString() ?? '-',
                ];
              }).toList(),
            ),

          pw.SizedBox(height: 16),

          // Products Section
          pw.Text('Products', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),

          if ((bill['products'] ?? [ticket]).isEmpty)
            pw.Text('No products found.')
          else
            pw.Table.fromTextArray(
              headers: ['Product', 'Brand', 'RAM/ROM', 'IMEI', 'Serial', 'Warranty'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              data: (bill['products'] ?? [ticket]).map<List<String>>((prod) {
                return [
                  prod['productName']?.toString() ?? '-',
                  prod['brand']?.toString() ?? '-',
                  prod['ramRomSpecs']?.toString() ?? '-',
                  prod['imeiNo']?.toString() ?? '-',
                  prod['itemSerialNo']?.toString() ?? '-',
                  prod['warranty']?.toString() ?? '-',
                ];
              }).toList(),
            ),

          pw.SizedBox(height: 20),

          // Footer
          pw.Divider(),
          pw.Center(
            child: pw.Text(
              'Thank you for your business!',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    // Print or view PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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
        return ['SCRAPED', 'QC'];
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


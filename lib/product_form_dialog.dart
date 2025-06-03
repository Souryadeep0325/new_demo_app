import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';

class ProductFormDialog extends StatefulWidget {
  final int itemId;
  final String productName;

  const ProductFormDialog({
    super.key,
    required this.itemId,
    required this.productName,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  // Controllers
  final invoiceNumberController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final customerNameController = TextEditingController();
  final gstNumberController = TextEditingController();
  final gstIdController = TextEditingController();
  final customerAadharIdController = TextEditingController();
  final itemSerialNoController = TextEditingController();
  final imeiNoController = TextEditingController();
  final batteryHealthController = TextEditingController();
  final acquisitionCostController = TextEditingController();
  final ramRomSpecsController = TextEditingController();
  final colorSpecsController = TextEditingController();
  final commentsController = TextEditingController();
  final warrantyController = TextEditingController(text: '1 Year');

  // Dropdowns
  String purchaseType = 'UPI';
  String modeOfPayment = 'UPI';
  final List<String> paymentOptions = ['UPI', 'CARD', 'CASH', 'OTHER'];
  final List<String> flags = ['Y', 'N'];
  String boxFlag = 'Y';
  String chargerFlag = 'Y';
  String sealedFlag = 'Y';
  String invoiceFlag = 'Y';

  List<String> ramRomOptions = [];
  List<String> colorOptions = [];
  bool ramRomApiFailed = false;
  bool colorApiFailed = false;

  Future<void> _fetchSpecs() async {
    try {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      final response = await http.get(
        Uri.parse('http://35.154.252.161:8080/api/product/select-specs/${widget.itemId}'),
        headers: {'Authorization': 'Bearer ${authStore.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ramRomOptions = List<String>.from(data['RAM-ROM specs'] ?? []);
          colorOptions = List<String>.from(data['Color specs'] ?? []);
          ramRomApiFailed = ramRomOptions.isEmpty;
          colorApiFailed = colorOptions.isEmpty;
        });
      } else {
        setState(() {
          ramRomApiFailed = true;
          colorApiFailed = true;
        });
      }
    } catch (e) {
      setState(() {
        ramRomApiFailed = true;
        colorApiFailed = true;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authStore = Provider.of<AuthStore>(context, listen: false);

    final Map<String, dynamic> body = {
      "itemId": widget.itemId,
      "invoiceNumber": invoiceNumberController.text,
      "invoiceDate": DateTime.now().toIso8601String().split("T").first,
      "phoneNumber": phoneNumberController.text,
      "customerName": customerNameController.text,
      "gstNumber": gstNumberController.text,
      "gstId": gstIdController.text,
      "productPurchaseType": purchaseType,
      "modeOfPayment": modeOfPayment,
      "customerAadharId": int.tryParse(customerAadharIdController.text) ?? 0,
      "itemSerialNo": itemSerialNoController.text,
      "imeiNo": imeiNoController.text,
      "batteryHealth": batteryHealthController.text,
      "warranty": warrantyController.text,
      "boxFlag": boxFlag,
      "chargerFlag": chargerFlag,
      "sealedFlag": sealedFlag,
      "invoiceFlag": invoiceFlag,
      "acquisitionCost": double.tryParse(acquisitionCostController.text) ?? 0.0,
      "ramRomSpecs": ramRomSpecsController.text,
      "ColorSpecs": colorSpecsController.text,
      "comments": commentsController.text,
      "productName": widget.productName,
    };

    setState(() => isSubmitting = true);

    final response = await http.post(
      Uri.parse('http://35.154.252.161:8080/api/ticket/create-ticket'),
      headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    setState(() => isSubmitting = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket created successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${response.statusCode}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSpecs();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Ticket for Item ID ${widget.itemId}', style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 24),

                Text('Product: ${widget.productName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                const Text('Customer Information', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(controller: customerNameController, decoration: const InputDecoration(labelText: 'Customer Name'), validator: _required),
                TextFormField(controller: phoneNumberController, decoration: const InputDecoration(labelText: 'Phone Number'), validator: _required),
                TextFormField(controller: customerAadharIdController, decoration: const InputDecoration(labelText: 'Aadhar ID'), keyboardType: TextInputType.number, validator: _required),
                TextFormField(controller: gstNumberController, decoration: const InputDecoration(labelText: 'GST Number')),
                TextFormField(controller: gstIdController, decoration: const InputDecoration(labelText: 'GST ID')),

                const SizedBox(height: 24),
                const Text('Product Details', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(controller: itemSerialNoController, decoration: const InputDecoration(labelText: 'Item Serial No'), validator: _required),
                TextFormField(controller: imeiNoController, decoration: const InputDecoration(labelText: 'IMEI No'), validator: _required),
                TextFormField(controller: batteryHealthController, decoration: const InputDecoration(labelText: 'Battery Health')),
                TextFormField(controller: warrantyController, decoration: const InputDecoration(labelText: 'Warranty')),

                const SizedBox(height: 24),
                const Text('Purchase Info', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(controller: invoiceNumberController, decoration: const InputDecoration(labelText: 'Invoice Number'), validator: _required),
                DropdownButtonFormField(value: purchaseType, decoration: const InputDecoration(labelText: 'Purchase Type'), items: _dropdownItems(paymentOptions), onChanged: (val) => setState(() => purchaseType = val!), validator: _required),
                DropdownButtonFormField(value: modeOfPayment, decoration: const InputDecoration(labelText: 'Mode of Payment'), items: _dropdownItems(paymentOptions), onChanged: (val) => setState(() => modeOfPayment = val!), validator: _required),
                TextFormField(controller: acquisitionCostController, decoration: const InputDecoration(labelText: 'Acquisition Cost'), keyboardType: TextInputType.number, validator: _required),

                const SizedBox(height: 24),
                const Text('Specs', style: TextStyle(fontWeight: FontWeight.bold)),

                ramRomApiFailed
                    ? TextFormField(controller: ramRomSpecsController, decoration: const InputDecoration(labelText: 'RAM/ROM Specs (Manual)'), validator: _required)
                    : DropdownButtonFormField(
                  value: ramRomSpecsController.text.isNotEmpty ? ramRomSpecsController.text : null,
                  items: _dropdownItems(ramRomOptions),
                  onChanged: (val) {
                    setState(() => ramRomSpecsController.text = val!);
                  },
                  decoration: const InputDecoration(labelText: 'RAM/ROM Specs'),
                  validator: _required,
                ),

                colorApiFailed
                    ? TextFormField(controller: colorSpecsController, decoration: const InputDecoration(labelText: 'Color Specs (Manual)'), validator: _required)
                    : DropdownButtonFormField(
                  value: colorSpecsController.text.isNotEmpty ? colorSpecsController.text : null,
                  items: _dropdownItems(colorOptions),
                  onChanged: (val) {
                    setState(() => colorSpecsController.text = val!);
                  },
                  decoration: const InputDecoration(labelText: 'Color Specs'),
                  validator: _required,
                ),

                const SizedBox(height: 24),
                const Text('Product Accessories', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField(value: boxFlag, decoration: const InputDecoration(labelText: 'Box Present'), items: _dropdownItems(flags), onChanged: (val) => setState(() => boxFlag = val!), validator: _required),
                DropdownButtonFormField(value: chargerFlag, decoration: const InputDecoration(labelText: 'Charger Present'), items: _dropdownItems(flags), onChanged: (val) => setState(() => chargerFlag = val!), validator: _required),
                DropdownButtonFormField(value: sealedFlag, decoration: const InputDecoration(labelText: 'Sealed Box'), items: _dropdownItems(flags), onChanged: (val) => setState(() => sealedFlag = val!), validator: _required),
                DropdownButtonFormField(value: invoiceFlag, decoration: const InputDecoration(labelText: 'Invoice Present'), items: _dropdownItems(flags), onChanged: (val) => setState(() => invoiceFlag = val!), validator: _required),

                const SizedBox(height: 24),
                const Text('Comments'),
                TextFormField(controller: commentsController, decoration: const InputDecoration(labelText: 'Comments')),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _submitForm,
                      child: isSubmitting ? const CircularProgressIndicator() : const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropdownItems(List<String> items) =>
      items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList();

  String? _required(String? val) => val == null || val.trim().isEmpty ? 'Required' : null;
}

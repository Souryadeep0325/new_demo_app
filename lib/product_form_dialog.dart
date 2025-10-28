import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';

class ProductFormDialog extends StatefulWidget {
  final int itemId;
  final String brand;
  final String productName;

  const ProductFormDialog({
    super.key,
    required this.itemId,
    required this.brand,
    required this.productName,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  // Controllers
  // final invoiceNumberController = TextEditingController();
  // final phoneNumberController = TextEditingController();
  // final customerNameController = TextEditingController();
  // final gstNumberController = TextEditingController();
  // final gstIdController = TextEditingController();
  // final customerAadharIdController = TextEditingController();
 // final itemSerialNoController = TextEditingController();
  final imeiNoController = TextEditingController();
  final batteryHealthController = TextEditingController();
  final acquisitionCostController = TextEditingController();
  final ramRomSpecsController = TextEditingController();
  final colorSpecsController = TextEditingController();
  final commentsController = TextEditingController();
  final warrantyController = TextEditingController();

  // Dropdowns
  String purchaseType = 'UPI';
  String modeOfPayment = 'UPI';
  final List<String> paymentOptions = ['UPI', 'CARD', 'CASH', 'OTHER','CREDIT'];
  final List<String> flags = ['Y', 'N'];
  String? boxFlag;
  String? chargerFlag;
  String? sealedFlag;
  String? invoiceFlag;

  List<String> ramRomOptions = [];
  List<String> colorOptions = [];
  bool ramRomApiFailed = false;
  bool colorApiFailed = false;

  Future<void> _fetchSpecs() async {
    try {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      final response = await http.get(
        Uri.parse('https://api.abcoped.shop/api/product/select-specs/${widget.itemId}'),
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
      "brand":widget.brand,
      "itemId": widget.itemId,
      // "invoiceNumber": invoiceNumberController.text,
      // "invoiceDate": DateTime.now().toIso8601String().split("T").first,
      // "phoneNumber": phoneNumberController.text,
      // "customerName": customerNameController.text,
      // "gstNumber": gstNumberController.text,
      // "gstId": gstIdController.text,
      //"productPurchaseType": purchaseType,
     // "modeOfPayment": modeOfPayment,
      // "customerAadharId": int.tryParse(customerAadharIdController.text) ?? 0,
      //"itemSerialNo": itemSerialNoController.text,
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
      "cartType": "BUY",
    };

    setState(() => isSubmitting = true);

    final response = await http.post(
      // Uri.parse('https://api.abcoped.shop/api/ticket/create-ticket'),
      Uri.parse('https://api.abcoped.shop/api/ticket/cart/items/buy/add'),

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
        const SnackBar(content: Text('Item Added to cart!')),
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
                Text('Create Ticket for Item ID ${widget.itemId}', style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 24),

                Text('Product: ${widget.productName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

              //  const Text('Customer Information', style: TextStyle(fontWeight: FontWeight.bold)),
              //  TextFormField(controller: customerNameController, decoration: const InputDecoration(labelText: 'Customer Name'), validator: _required),
              //  TextFormField(controller: phoneNumberController, decoration: const InputDecoration(labelText: 'Phone Number'), validator: _required),
               // TextFormField(controller: customerAadharIdController, decoration: const InputDecoration(labelText: 'Aadhar ID'), keyboardType: TextInputType.number, validator: _required),
               // TextFormField(controller: gstNumberController, decoration: const InputDecoration(labelText: 'GST Number')),
              //  TextFormField(controller: gstIdController, decoration: const InputDecoration(labelText: 'GST ID')),

                const SizedBox(height: 24),
                const Text('Product Details', style: TextStyle(fontWeight: FontWeight.bold)),
               // TextFormField(controller: itemSerialNoController, decoration: const InputDecoration(labelText: 'Item Serial No'), validator: _required),
                TextFormField(controller: imeiNoController, decoration: const InputDecoration(labelText: 'IMEI No'), validator: _required),
                TextFormField(controller: batteryHealthController, decoration: const InputDecoration(labelText: 'Battery Health'),validator: _isBetween1And100),
                //TextFormField(controller: warrantyController, decoration: const InputDecoration(labelText: 'Warranty')),
                WarrantyDatePickerField(controller: warrantyController),
                DropdownButtonFormField<String>(
                  value: invoiceFlag,
                  //decoration: const InputDecoration(labelText: 'Invoice Present'),
                  items: _dropdownItemsWithHint(flags,'Invoice Present'),
                  onChanged: (val) => setState(() => invoiceFlag = val),
                  validator: _required,
                ),
                const SizedBox(height: 24),
                const Text('Purchase Info', style: TextStyle(fontWeight: FontWeight.bold)),
             //   TextFormField(controller: invoiceNumberController, decoration: const InputDecoration(labelText: 'Invoice Number'), validator: _required),
             //   DropdownButtonFormField(value: purchaseType, decoration: const InputDecoration(labelText: 'Purchase Type'), items: _dropdownItems(paymentOptions), onChanged: (val) => setState(() => purchaseType = val!), validator: _required),
             //   DropdownButtonFormField(value: modeOfPayment, decoration: const InputDecoration(labelText: 'Mode of Payment'), items: _dropdownItems(paymentOptions), onChanged: (val) => setState(() => modeOfPayment = val!), validator: _required),
                TextFormField(controller: acquisitionCostController, decoration: const InputDecoration(labelText: 'Acquisition Cost'), keyboardType: TextInputType.number, validator: _validateInteger),

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
               // DropdownButtonFormField(value: boxFlag, decoration: const InputDecoration(labelText: 'Box Present'), items: _dropdownItems(flags), onChanged: (val) => setState(() => boxFlag = val!), validator: _required),
                DropdownButtonFormField<String>(
                  initialValue: boxFlag,
                  decoration: const InputDecoration(labelText: 'Box Present'),
                  items: _dropdownItemsWithHint(flags,'Box Present'),
                  onChanged: (val) => setState(() => boxFlag = val),
                  validator: _required,
                ),
                DropdownButtonFormField<String>(
                  initialValue: sealedFlag,
                  decoration: const InputDecoration(labelText: 'Sealed Box'),
                  items: _dropdownItemsWithHint(flags,'Sealed Box'),
                  onChanged: (val) => setState(() => sealedFlag = val),
                  validator: _required,
                ),
                DropdownButtonFormField<String>(
                  initialValue: chargerFlag,
                  decoration: const InputDecoration(labelText: 'Charger Present'),
                  items: _dropdownItemsWithHint(flags,'Charger Present'),
                  onChanged: (val) => setState(() => chargerFlag = val),
                  validator: _required,
                ),
                // DropdownButtonFormField<String>(
                //   value: invoiceFlag,
                //   //decoration: const InputDecoration(labelText: 'Invoice Present'),
                //   items: _dropdownItemsWithHint(flags,'Invoice Present'),
                //   onChanged: (val) => setState(() => invoiceFlag = val),
                //   validator: _required,
                // ),
                //DropdownButtonFormField(value: chargerFlag, decoration: const InputDecoration(labelText: 'Charger Present'), items: _dropdownItems(flags), onChanged: (val) => setState(() => chargerFlag = val!), validator: _required),
                //DropdownButtonFormField(value: sealedFlag, decoration: const InputDecoration(labelText: 'Sealed Box'), items: _dropdownItems(flags), onChanged: (val) => setState(() => sealedFlag = val!), validator: _required),
                //DropdownButtonFormField(value: invoiceFlag, decoration: const InputDecoration(labelText: 'Invoice Present'), items: _dropdownItems(flags), onChanged: (val) => setState(() => invoiceFlag = val!), validator: _required),

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


  List<DropdownMenuItem<String>> _dropdownItemsWithHint(List<String> items, String placeHolderText) {
    return [
      DropdownMenuItem<String>(
        value: null,
        child: Text(placeHolderText), // Hint or label for dropdown
      ),
      ...items.map(
            (e) => DropdownMenuItem<String>(
          value: e,
          child: Text(e == 'Y' ? 'Yes' : 'No'), // Optional: show Y/N as Yes/No
        ),
      )
    ];
  }

  String? _required(String? val) => val == null || val.trim().isEmpty ? 'Required' : null;

  String? _validateInteger(String? val) =>
      val == null || val.trim().isEmpty ? 'Required' : int.tryParse(val.trim()) == null ? 'Must be an integer' : null;
  String? _isBetween1And100(String? val) {
    if (val == null || val.trim().isEmpty) return null; // Optional field
    final number = num.tryParse(val.trim());
    if (number == null) return 'Enter a valid number';
    if (number <= 0 || number > 100) return 'Must be between 1 and 100';
    return null;
  }

}



// class WarrantyDatePickerField extends StatefulWidget {
//   final TextEditingController controller;
//
//   const WarrantyDatePickerField({super.key, required this.controller});
//
//   @override
//   State<WarrantyDatePickerField> createState() => _WarrantyDatePickerFieldState();
// }
//
// class _WarrantyDatePickerFieldState extends State<WarrantyDatePickerField> {
//   late FocusNode _focusNode;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//
//     _focusNode.addListener(() async {
//       if (_focusNode.hasFocus) {
//         // Unfocus to prevent reopening
//         _focusNode.unfocus();
//
//         final pickedDate = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime(2000),
//           lastDate: DateTime(2100),
//         );
//
//         if (pickedDate != null) {
//           widget.controller.text = _formatDate(pickedDate);
//         }
//       }
//     });
//   }
//
//   String _formatDate(DateTime date) {
//     return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: widget.controller,
//       focusNode: _focusNode,
//       decoration: const InputDecoration(labelText: 'Warranty Date',hintText: 'Select warranty date',),
//       readOnly: true,
//     );
//   }
// }


class WarrantyDatePickerField extends StatefulWidget {
  final TextEditingController controller;

  const WarrantyDatePickerField({super.key, required this.controller});

  @override
  State<WarrantyDatePickerField> createState() => _WarrantyDatePickerFieldState();
}

class _WarrantyDatePickerFieldState extends State<WarrantyDatePickerField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() async {
      if (_focusNode.hasFocus) {
        // Prevent keyboard and reopen loop
        _focusNode.unfocus();

        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _parseExistingDate(widget.controller.text) ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDatePickerMode: DatePickerMode.year, // 🔹 Opens with year view
          helpText: 'Select Warranty Date',
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.blue.shade700,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          widget.controller.text = _formatDate(pickedDate);
        }
      }
    });
  }

  /// Parse existing text (dd-MM-yyyy) into DateTime if valid
  DateTime? _parseExistingDate(String text) {
    try {
      final parts = text.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      decoration: const InputDecoration(
        labelText: 'Warranty Date',
        hintText: 'Select warranty date',
      ),
      readOnly: true,
    );
  }
}


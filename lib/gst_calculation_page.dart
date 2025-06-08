import 'package:flutter/material.dart';

class GSTCalculationPage extends StatefulWidget {
  const GSTCalculationPage({super.key});

  @override
  _GSTCalculationPageState createState() => _GSTCalculationPageState();
}

class _GSTCalculationPageState extends State<GSTCalculationPage> {
  final TextEditingController taxableValueController = TextEditingController();
  final TextEditingController outputTaxableValueController = TextEditingController();

  final TextEditingController spController = TextEditingController();
  final TextEditingController cpController = TextEditingController();
  final TextEditingController hsnCodeController = TextEditingController(text: "8517");
  final TextEditingController profitMarginController = TextEditingController();

  double gstAmount = 0.0;
  double cgstAmount = 0.0;
  double sgstAmount = 0.0;
  double taxableValue = 0.0;
  double outputTaxableValue = 0.0;
  double sp = 0;
  double cp = 0;
  double margin = 0;

  double totalInvoiceValue = 0.0;
  double outputTax = 0.0;
  double inputTax = 0.0;
  double saleGstValue =0 ;
  double taxToGovt = 0;
  bool isNewPhone = true;
  bool isITCClaimable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GST Calculation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: taxableValueController,
              decoration: const InputDecoration(labelText: 'Input Taxable Value'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: outputTaxableValueController,
              decoration: const InputDecoration(labelText: 'output invoice value'),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: hsnCodeController,
              decoration: const InputDecoration(labelText: 'HSN Code'),
              readOnly: true,
            ),
            SwitchListTile(
              title: const Text('New Phone'),
              value: isNewPhone,
              onChanged: (value) {
                setState(() {
                  isNewPhone = value;
                });
              },
            ),
            if (!isNewPhone)
            TextField(
              controller: spController,
              decoration: const InputDecoration(labelText: 'sp'),
              keyboardType: TextInputType.number,
            ),
            if (!isNewPhone)
            TextField(
              controller: cpController,
              decoration: const InputDecoration(labelText: 'cp'),
              keyboardType: TextInputType.number,
            ),
            if (!isNewPhone)
              TextField(
                controller: profitMarginController,
                decoration: const InputDecoration(labelText: 'Profit Margin (Used Phone)'),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateGST,
              child: const Text('Calculate GST'),
            ),
            const SizedBox(height: 20),

            if (isNewPhone) ...[
              Text('Taxable Value: \$${taxableValue.toStringAsFixed(2)}'),
              Text('GST Amount: \$${gstAmount.toStringAsFixed(2)}'),
              Text('CGST: \$${cgstAmount.toStringAsFixed(2)}'),
              Text('SGST: \$${sgstAmount.toStringAsFixed(2)}'),

            Text('Total Invoice Value: \$${totalInvoiceValue.toStringAsFixed(2)}'),

            Text('Input Tax: \$${inputTax.toStringAsFixed(2)}'),
            Text('Total Output Taxable Value: \$${outputTaxableValue.toStringAsFixed(2)}'),
            Text('Output Tax: \$${outputTax.toStringAsFixed(2)}'),
            ],
            Text('Tax to Govt: \$${taxToGovt.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  void _calculateGST() {
    final double taxableValue = double.tryParse(taxableValueController.text) ?? 0.0;
    final double profitMargin = double.tryParse(profitMarginController.text) ?? 0.0;
    final double cp = double.tryParse(cpController.text) ?? 0.0;
    final double sp = double.tryParse(spController.text) ?? 0.0;
    final double outputInvoiceValue = double.tryParse(outputTaxableValueController.text) ?? 0.0;

    // Calculate taxable value for new phones
    if (isNewPhone) {
      totalInvoiceValue = ((18/100)*taxableValue) + taxableValue;
      gstAmount = totalInvoiceValue - taxableValue;

      // ITC is available for new phones
      cgstAmount = gstAmount / 2; // 9% CGST and 9% SGST for ITC
      sgstAmount = cgstAmount;
      // Output tax for new phones
      inputTax = gstAmount;
      outputTaxableValue = (outputInvoiceValue*100)/(100+18);
      saleGstValue = outputInvoiceValue - outputTaxableValue;

      outputTax = saleGstValue;
      taxToGovt = outputTax >= inputTax ? outputTax - inputTax : 0;




    } else {
      // // For used phones, apply Margin Scheme
      // taxableValue = profitMargin;
      // gstAmount = taxableValue * 18 / 100;
      //
      // // No ITC for used phones
      // inputTaxCredit = 0.0;

      // Output tax for used phones
      margin = profitMargin == 0? sp-cp : profitMargin;

      taxToGovt = margin >= 0 ? (18/100) * margin : 0;
    }

    setState(() {});
  }
}

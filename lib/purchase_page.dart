import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/centred_view.dart';
import 'package:news_app/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'package:news_app/product_form_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  _PurchasesPageState createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();

  List<String> productNames = [];
  List<int> productMasterId = [];

  int currentPage = 0;
  int totalPages = 1;
  bool isLoading = false;
  bool hasSearched = false;

  String currentBrand = '';
  String currentProductName = '';

  late AuthStore authStore;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authStore = Provider.of<AuthStore>(context, listen: false);
    });
  }

  Future<void> fetchProducts({
    required String brand,
    required String productName,
    int page = 0,
  }) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (page == 0) productNames.clear();
    });

    Uri uri;

    if (productName.isNotEmpty) {
      final queryParams = {
        'productName': productName,
        'page': page.toString(),
        if (brand.isNotEmpty) 'brand': brand,
      };
      uri = Uri.http('35.154.252.161:8080', '/api/product/brand/names/products', queryParams);
    } else {
      uri = Uri.http('35.154.252.161:8080', '/api/product/brand/names', {
        'brand': brand,
        'page': page.toString(),
      });
    }

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${authStore.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List products = data['content'];
      final int pages = data['totalPages'];

      setState(() {
        currentBrand = brand;
        currentProductName = productName;
        currentPage = page;
        totalPages = pages;
        hasSearched = true;

        productNames = products.map<String>((e) => e['productName'] as String).toList();
        productMasterId =
            products.map<int>((e) => int.parse(e['productMasterId'].toString())).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      _showAlertDialog('Failed to load products. Status: ${response.statusCode}');
    }
  }

  void _showAlertDialog(String message) {
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

  Widget _buildPagination() {
    const maxVisiblePages = 5;
    int maxPages = totalPages;
    int halfRange = maxVisiblePages ~/ 2;

    int upperBound = (maxPages - maxVisiblePages).clamp(0, maxPages);
    int startPage = (currentPage - halfRange).clamp(0, upperBound);
    int endPage = (startPage + maxVisiblePages).clamp(0, maxPages);

    List<Widget> pageButtons = [];

    pageButtons.add(
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: currentPage > 0
            ? () => fetchProducts(
          brand: currentBrand,
          productName: currentProductName,
          page: currentPage - 1,
        )
            : null,
      ),
    );

    for (int i = startPage; i < endPage; i++) {
      pageButtons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: i == currentPage ? Colors.blue : Colors.grey,
              minimumSize: const Size(40, 36),
            ),
            onPressed: () => fetchProducts(
              brand: currentBrand,
              productName: currentProductName,
              page: i,
            ),
            child: Text('${i + 1}'),
          ),
        ),
      );
    }

    pageButtons.add(
      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: currentPage < totalPages - 1
            ? () => fetchProducts(
          brand: currentBrand,
          productName: currentProductName,
          page: currentPage + 1,
        )
            : null,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pageButtons,
    );
  }

  void _showFormDialog(int itemId, String productName) {
    showDialog(
      context: context,
      builder: (_) => ProductFormDialog(itemId: itemId, productName: productName),
    );
  }

  void _clearFields() {
    setState(() {
      _brandController.clear();
      _productNameController.clear();
      productNames.clear();
      hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CentredView(
      child: Scaffold(
        appBar: const CustomAppBar(appBarTitle: 'Purchases'),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
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
                          selectedItem: _brandController.text.isNotEmpty
                              ? _brandController.text
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _brandController.text = value ?? '';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _productNameController,
                          decoration: const InputDecoration(
                            labelText: 'Enter product name (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final brand = _brandController.text.trim();
                          final productName = _productNameController.text.trim();

                          if (brand.isNotEmpty || productName.isNotEmpty) {
                            fetchProducts(
                              brand: brand,
                              productName: productName,
                              page: 0,
                            );
                          }
                        },
                        child: const Text('Search'),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: _clearFields,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (hasSearched)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing products for'
                            '${currentBrand.isNotEmpty ? ' brand: "$currentBrand"' : ''}'
                            '${currentProductName.isNotEmpty ? ' and product: "$currentProductName"' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: productNames.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(productNames[index]),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _showFormDialog(productMasterId[index], productNames[index]);
                        },
                        child: const Text('Open Form'),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildPagination(),
            ),
          ],
        ),
      ),
    );
  }
}

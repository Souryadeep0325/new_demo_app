import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/centred_view.dart';
import 'package:news_app/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'package:news_app/product_form_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'buy_cart_page.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  _PurchasesPageState createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final TextEditingController _productNameController = TextEditingController();
  int cartCount = 0;
  List<String> productNames = [];
  List<int> productMasterId = [];
  List<String> brandNames = [];

  int currentPage = 0;
  int totalPages = 1;
  bool isLoading = false;
  bool hasSearched = false;

  String? selectedBrand;
  String searchedProductName = '';

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
    fetchCartCount();
  }

  Future<void> fetchProducts({required String brand, required String productName, int page = 0}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (page == 0) productNames.clear();
    });

    final queryParams = {
      'brand': brand,
      'productName': productName,
      'page': page.toString(),
    };

    final uri = Uri.https('api.abcoped.shop', '/api/product/brand/names/products', queryParams);

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer ${authStore.token}',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List products = data['content'];

      setState(() {
        productNames = products.map<String>((e) => e['productName'] as String).toList();
        brandNames = products.map<String>((e) => e['brand'] as String).toList();
        productMasterId = products.map<int>((e) => int.parse(e['productMasterId'].toString())).toList();
        currentPage = page;
        totalPages = data['totalPages'];
        hasSearched = true;
        searchedProductName = productName;
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
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  Future<void> fetchCartCount() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    try {
      final uri = Uri.parse('https://api.abcoped.shop/api/ticket/cart/items?cartType=BUY');
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

  Widget _buildBrandTiles() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allBrands.map((brand) {
        return ActionChip(
          label: Text(brand),
          onPressed: () {
            setState(() {
              selectedBrand = brand;
              _productNameController.clear();
              searchedProductName = '';
              fetchProducts(brand: brand, productName: '', page: 0);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSearchSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _productNameController,
            decoration: const InputDecoration(labelText: 'Enter product name', border: OutlineInputBorder()),
            onSubmitted: (value) => fetchProducts(brand: selectedBrand ?? '', productName: value.trim(), page: 0),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => fetchProducts(brand: selectedBrand ?? '', productName: _productNameController.text.trim(), page: 0),
          child: const Text('Search'),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () => setState(() => selectedBrand = null),
          child: const Text('Change Brand'),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () => fetchProducts(brand: selectedBrand ?? '', productName: '', page: 0),
          child: const Text('Clear Search'),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: productNames.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(productNames[index]),
            subtitle: Text('Brand: ${brandNames[index]}'),
            trailing: ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ProductFormDialog(
                  itemId: productMasterId[index],
                  productName: productNames[index],
                  brand: brandNames[index],
                ),
              ),
              child: const Text('+Cart'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagination() {
    List<Widget> pageButtons = [];
    for (int i = 0; i < totalPages; i++) {
      pageButtons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: i == currentPage ? Colors.blue : Colors.grey, minimumSize: const Size(40, 36)),
            onPressed: () => fetchProducts(brand: selectedBrand ?? '', productName: _productNameController.text.trim(), page: i),
            child: Text('${i + 1}'),
          ),
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: pageButtons);
  }

  @override
  Widget build(BuildContext context) {
    return CentredView(
      child: Scaffold(
        // appBar: const CustomAppBar(appBarTitle: 'Purchases'),
        appBar: AppBar(
          title: const Text('Purchases'),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.shopping_cart),
            //   tooltip: 'Go to Cart',
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => const BuyCartPage()),
            //     );
            //   },
            // ),
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Go to Cart',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BuyCartPage()),
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
              ],
            ),

          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: selectedBrand == null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select a Brand:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildBrandTiles(),
                ],
              )
                  : Column(
                children: [
                  _buildSearchSection(),
                  const SizedBox(height: 10),
                  if (hasSearched)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing results for "$selectedBrand"' + (searchedProductName.isNotEmpty ? ' and "$searchedProductName"' : ''),
                      ),
                    ),
                ],
              ),
            ),
            if (selectedBrand != null) Expanded(child: _buildProductList()),
            if (selectedBrand != null) Padding(padding: const EdgeInsets.all(16.0), child: _buildPagination()),
          ],
        ),
      ),
    );
  }
}

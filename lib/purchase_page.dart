import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/centred_view.dart';
import 'package:news_app/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'package:news_app/product_form_dialog.dart';


class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  _PurchasesPageState createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final TextEditingController _brandController = TextEditingController(text: 'lg');
  List<String> productNames = [];
  List<int>  productMasterId = [];
  int currentPage = 0;
  int totalPages = 1;
  bool isLoading = false;
  String currentBrand = 'lg';
  late AuthStore authStore; // Declare authStore

  @override
  void initState() {
    super.initState();

    // Access Provider safely after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authStore = Provider.of<AuthStore>(context, listen: false);
      fetchProducts(brand: currentBrand, page: 0);
    });
  }

  Future<void> fetchProducts({required String brand, int page = 0}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (page == 0) productNames.clear(); // Clear on new brand search
    });

    final uri = Uri.parse(
        'http://35.154.252.161:8080/api/product/brand/names?brand=$brand&page=$page');

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
        currentPage = page;
        totalPages = pages;
        productNames = products.map<String>((e) => e['productName'] as String).toList();
        productMasterId = products.map<int>((e) => int.parse(e['productMasterId'].toString())).toList();
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
    List<Widget> pageButtons = [];

    for (int i = 0; i < totalPages; i++) {
      pageButtons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: i == currentPage ? Colors.blue : Colors.grey,
              minimumSize: const Size(40, 36),
            ),
            onPressed: () {
              if (i != currentPage) {
                fetchProducts(brand: currentBrand, page: i);
              }
            },
            child: Text('${i + 1}'),
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      children: pageButtons,
    );
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Enter brand name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final brand = _brandController.text.trim();
                      if (brand.isNotEmpty) {
                        fetchProducts(brand: brand, page: 0);
                      }
                    },
                    child: const Text('Search'),
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
                          _showFormDialog(  productMasterId[index]);
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
  void _showFormDialog(int itemId) {
    showDialog(
      context: context,
      builder: (_) => ProductFormDialog(itemId: itemId),
    );
  }
}

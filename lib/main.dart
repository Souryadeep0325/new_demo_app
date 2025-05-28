import 'package:flutter/material.dart';
import 'package:news_app/scrap.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'sales_page.dart';
import 'purchase_page.dart';
import 'listing_page.dart';
import 'gst_calculation_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthStore(),
      child: MaterialApp(
        title: 'Flutter Web App',
        theme: ThemeData(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
          ),
        ),
        home: Consumer<AuthStore>(
          builder: (context, authStore, _) {
            return authStore.isAuthenticated
                ? const HomePage() // HomePage when authenticated
                : LoginPage(); // LoginPage when not authenticated
          },
        ),
        routes: {
          '/login': (_) => LoginPage(),
          '/home': (_) => const HomePage(),
          '/sales': (_) => const SalesPage(),
          '/purchases': (_) => const PurchasesPage(),
          '/listing': (_) => const ListingPage(),
          '/qc1': (_) => const ListingPage(),
          '/qc2': (_) => const ListingPage(),
          '/scrap': (_) => const ScrapPage(),
          '/gst_calculation': (context) => const GSTCalculationPage(),
        },
      ),
    );
  }
}

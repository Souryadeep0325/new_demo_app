import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'sales_page.dart';
import 'purchase_page.dart';
import 'listing_page.dart';
import 'gst_calculation_page.dart';
import 'ticket_list_page.dart';
import 'scrap.dart';
import 'ticket_listing_page.dart';

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
                ? const HomePage()
                : LoginPage();
          },
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => LoginPage());
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomePage());
            case '/sales':
              return MaterialPageRoute(builder: (_) => const TicketListPageSold());
            case '/purchases':
              return MaterialPageRoute(builder: (_) => const PurchasesPage());
            case '/listing':
              return MaterialPageRoute(builder: (_) => const ProductListing(status: 'LISTED', title: 'Listed Products'));
            case '/qc1':
              return MaterialPageRoute(
                builder: (_) => const TicketListingPage(status: 'QC1', title: 'QC1 Tickets'),
              );
            case '/qc2':
              return MaterialPageRoute(
                builder: (_) => const TicketListingPage(status: 'QC2', title: 'QC2 Tickets'),
              );
            case '/scrap':
              return MaterialPageRoute(
                builder: (_) => const TicketListingPage(status: 'SCRAP', title: 'Scrap Tickets'),
              );
            case '/all_products':
              return MaterialPageRoute(
                builder: (_) => const TicketListPage(),
              );
            case '/gst_calculation':
              return MaterialPageRoute(
                  builder: (_) => const GSTCalculationPage());
            default:
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Page not found')),
                ),
              );
          }
        },
      ),
    );
  }
}

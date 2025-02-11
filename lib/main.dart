import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_store.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'sales_page.dart';
import 'purchase_page.dart';
import 'listing_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web App',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
        ),
      ),
      home: ChangeNotifierProvider(
        create: (_) => AuthStore(),
        child: Consumer<AuthStore>(
          builder: (context, authStore, _) {
            return authStore.isAuthenticated
                ? HomePage()
                : LoginPage();
          },
        ),
      ),
      routes: {
        '/login': (_) => LoginPage(),
        '/home': (_) => HomePage(),
        '/sales': (_) => SalesPage(),
        '/purchases': (_) => PurchasesPage(),
        '/listing': (_) => ListingPage(),
      },
    );
  }
}

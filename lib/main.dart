import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
  ErrorWidget.builder = (FlutterErrorDetails details) => const SizedBox.shrink();
  FlutterError.onError = (FlutterErrorDetails details) {
    // Print errors to the console, but do not show red error screens
    debugPrint(details.toString());
  };
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthStore(),
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'Flutter Web App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A73E8),
              primary: const Color(0xFF1A73E8),
              secondary: const Color(0xFF4285F4),
              surface: Colors.white,
              background: const Color(0xFFF8F9FA),
              error: const Color(0xFFDC3545),
            ),
            brightness: Brightness.light,
            textTheme: TextTheme(
              displayLarge: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF202124),
              ),
              displayMedium: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF202124),
              ),
              titleLarge: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF202124),
              ),
              titleMedium: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF202124),
              ),
              bodyLarge: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF202124),
              ),
              bodyMedium: GoogleFonts.roboto(
                fontSize: 14,
                color: const Color(0xFF202124),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF1A73E8),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDC3545)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              labelStyle: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF5F6368),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A73E8),
              primary: const Color(0xFF1A73E8),
              secondary: const Color(0xFF4285F4),
              surface: const Color(0xFF202124),
              background: const Color(0xFF121212),
              error: const Color(0xFFDC3545),
              brightness: Brightness.dark,
            ),
            brightness: Brightness.dark,
            textTheme: TextTheme(
              displayLarge: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              displayMedium: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              titleLarge: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              titleMedium: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              bodyLarge: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.white,
              ),
              bodyMedium: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF1A73E8),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDC3545)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              labelStyle: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF5F6368),
              ),
            ),
          ),
          themeMode: _themeMode,
          home: Consumer<AuthStore>(
            builder: (context, authStore, _) {
              return authStore.isAuthenticated
                  ? HomePage(toggleTheme: _toggleTheme)
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
                  builder: (_) => const ProductListing(status: '', title: 'All Products'),
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
      ),
    );
  }
}

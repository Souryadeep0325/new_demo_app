
import 'package:flutter/material.dart';
import 'package:news_app/news_ui/splash_screen.dart';

void main() => runApp(const MyApp());

// Main App Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter News App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashScreen(),
    );
  }
}


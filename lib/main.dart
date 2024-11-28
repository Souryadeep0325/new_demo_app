import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_app/news_ui/splash_screen.dart';
import 'package:news_app/news_ui/splash_screen_store.dart'; // Import the store

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => SplashScreenStore()), // Provide the store
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'News App',
      home: SplashScreen(),
    );
  }
}

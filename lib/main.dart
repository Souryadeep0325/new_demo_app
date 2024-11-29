import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_app/news_ui/splash_screen.dart';
import 'package:news_app/news_ui/splash_screen_store.dart';
import 'package:news_app/news_ui/theme_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => SplashScreenStore()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          title: 'News App',
          theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: const SplashScreen(),
        );
      },
    );
  }
}

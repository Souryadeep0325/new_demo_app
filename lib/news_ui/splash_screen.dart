import 'package:flutter/material.dart';
import 'package:news_app/news_ui/news_screen.dart';
import 'package:news_app/news_ui/constant.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'splash_screen_store.dart'; // Import the store

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late SplashScreenStore splashScreenStore;

  @override
  void initState() {
    super.initState();
    splashScreenStore =
        context.read<SplashScreenStore>(); // Read the store from provider
    splashScreenStore.fetchNews(); // Trigger the news fetch on screen load
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        // This will reactively rebuild the widget when `newsLoaded` or `hasError` changes.
        if (splashScreenStore.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Constants.primaryColor,
                    size: Constants.iconSize,
                  ),
                  const SizedBox(height: Constants.spacer),
                  const Text(
                    Constants.errorMessage,
                    style: TextStyle(
                      fontSize: Constants.regularFontSize,
                      color: Constants.tertiaryColor,
                    ),
                  ),
                  const SizedBox(height: Constants.spacer),
                  ElevatedButton(
                    onPressed: splashScreenStore.reload, // Trigger reload
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                    ),
                    child: const Text(Constants.reloadButtonText),
                  ),
                ],
              ),
            ),
          );
        }

        if (!splashScreenStore.newsLoaded) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (splashScreenStore.newsArticles.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                Constants.noDataMessage,
                style: TextStyle(fontSize: Constants.regularFontSize),
              ),
            ),
          );
        }

        // If the data is loaded successfully
        return NewsScreen(newsArticles: splashScreenStore.newsArticles);
      },
    );
  }
}

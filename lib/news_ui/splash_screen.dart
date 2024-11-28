import 'package:flutter/material.dart';
import 'package:news_app/news-schema/news_model.dart';
import 'package:news_app/news_ui/news_screen.dart';
import 'package:news_app/news_api/news_service.dart';
import 'package:news_app/news_ui/constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late Future<List<NewsModel>> newsArticles;
  bool hasError = false;
  final NewsService newsService = NewsService();

  @override
  void initState() {
    super.initState();
    newsArticles = fetchNews();
  }

  Future<List<NewsModel>> fetchNews() async {
    try {
      final data = await newsService.fetchNews();
      return data;
    } catch (e) {
      setState(() {
        hasError = true;
      });
      rethrow;
    }
  }

  void reload() {
    setState(() {
      hasError = false;
      newsArticles = fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: hasError
          ? Center(
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
                    onPressed: reload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                    ),
                    child: const Text(Constants.reloadButtonText),
                  ),
                ],
              ),
            )
          : FutureBuilder<List<NewsModel>>(
              future: newsArticles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        Constants.errorMessage,
                        style: TextStyle(
                          fontSize: Constants.regularFontSize,
                          color: Constants.primaryColor,
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return NewsScreen(newsArticles: snapshot.data!);
                } else {
                  return const Scaffold(
                    body: Center(
                      child: Text(
                        Constants.noDataMessage,
                        style: TextStyle(fontSize: Constants.regularFontSize),
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}

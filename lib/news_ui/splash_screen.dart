import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/news-schema/news_model.dart';
import 'package:news_app/news_ui/news_list.dart';
import 'package:news_app/news_ui/news_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<List<NewsModel>> newsArticles;

  @override
  void initState() {
    super.initState();
    newsArticles = fetchNews(); // Fetch news when splash screen loads
  }

  // Function to fetch news from API
  Future<List<NewsModel>> fetchNews() async {
    final response = await http.get(Uri.parse(
      'https://newsapi.org/v2/top-headlines?country=us&apiKey=YOUR_API_KEY',
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List articles = data['articles'];
      return articles.map((article) => NewsModel.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsModel>>(
      future: newsArticles, // Wait for the news data
      builder: (context, snapshot) {
        // While waiting for data, show a loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If there's an error, show error message
        else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 18)),
            ),
          );
        }

        // If the data is fetched successfully, navigate to NewsScreen
        else if (snapshot.hasData) {
          // Navigate to the NewsScreen once data is ready
          return NewsScreen(newsArticles: snapshot.data!);
        }

        // If no data, show a placeholder message
        else {
          return Scaffold(
            body: Center(
              child: Text('No data available', style: TextStyle(fontSize: 18)),
            ),
          );
        }
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:news_app/news-schema/news_model.dart';
import 'package:news_app/news_ui/news_list.dart';
import 'package:news_app/news_ui/constant.dart';
import 'package:provider/provider.dart';
import 'theme_service.dart';

class NewsScreen extends StatelessWidget {
  final List<NewsModel> newsArticles;

  const NewsScreen({super.key, required this.newsArticles});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Constants.newsScreenTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: Constants.appBarTitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Constants.primaryColor,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.isDarkMode
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
              color: themeNotifier.isDarkMode ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: NewsList(newsArticles: newsArticles),
    );
  }
}

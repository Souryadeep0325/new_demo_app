import 'package:flutter/material.dart';
import 'package:news_app/news-schema/news_model.dart';
import 'package:news_app/news_ui/news_list.dart';
import 'package:news_app/news_ui/constant.dart';

class NewsScreen extends StatelessWidget {
  final List<NewsModel> newsArticles;

  const NewsScreen({super.key, required this.newsArticles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Constants.newsScreenTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: Constants.appBarTitleFontSize,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Constants.primaryColor,
        elevation: 1,
        centerTitle: true,
      ),
      body: NewsList(newsArticles: newsArticles),
    );
  }
}




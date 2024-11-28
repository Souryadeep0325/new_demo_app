import 'package:flutter/material.dart';
import 'package:news_app/news-schema/news_model.dart'; 
import 'package:news_app/news_ui/news_card.dart';

// NewsList widget to display the list of articles
class NewsList extends StatelessWidget {
  final List<NewsModel> newsArticles; // Accept a List<NewsModel>

  NewsList({required this.newsArticles});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: newsArticles.length,
      itemBuilder: (context, index) {
        final article = newsArticles[index];
        return NewsCard(article: article); // Assuming NewsCard is used to display individual articles
      },
    );
  }
}

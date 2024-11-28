import 'package:flutter/material.dart';
import 'package:news_app/news-schema/news_model.dart';
import 'package:news_app/news_ui/news_card.dart';
import 'package:news_app/news_ui/news_detail_page.dart';

class NewsList extends StatelessWidget {
  final List<NewsModel> newsArticles;

  const NewsList({super.key, required this.newsArticles});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: newsArticles.length,
      itemBuilder: (context, index) {
        final article = newsArticles[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailPage(article: article),
              ),
            );
          },
          child: NewsCard(article: article),
        );
      },
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/news-schema/news_model.dart';
import 'package:news_app/news_ui/news_list.dart';
class NewsScreen extends StatelessWidget {
  final List<NewsModel> newsArticles; // Accept a list of news articles

  NewsScreen({required this.newsArticles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Top Headlines',
        style: const TextStyle(color: Colors.blue,fontSize: 18, fontWeight: FontWeight.bold,),

      )),
      body: NewsList(newsArticles: newsArticles), // Pass data to the List widget
    );
  }
}
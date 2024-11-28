import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/news-schema/news_model.dart';
import 'package:intl/intl.dart';
import 'package:news_app/news_ui/constant.dart';

class NewsService {
  List<NewsModel>? _cachedNews;
  DateTime? _lastFetchedTime;

  Future<List<NewsModel>> fetchNews() async {
    final currentTime = DateTime.now();

    if (_cachedNews != null &&
        _lastFetchedTime != null &&
        currentTime.difference(_lastFetchedTime!) <
            Constants.cacheExpiryDuration) {
      return _cachedNews!;
    }

    try {
      final response = await http.get(Uri.parse(
        '${Constants.apiUrl}?country=${Constants.countryCode}&apiKey=${Constants.apiKey}', // Use constants
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List articles = data['articles'];
        List<NewsModel> newsArticles = articles.map((article) {
          DateTime publishedDate = DateTime.parse(article['publishedAt']);
          String formattedDate =
              DateFormat('MM/dd/yyyy hh:mm a').format(publishedDate);
          article['publishedAt'] = formattedDate;
          return NewsModel.fromJson(article);
        }).toList();
        _cachedNews = newsArticles;
        _lastFetchedTime = currentTime;

        return newsArticles;
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}

import 'package:flutter/material.dart';

class Constants {
  static const cacheExpiryDuration = Duration(minutes: 2);

  static const String apiUrl = 'https://newsapi.org/v2/top-headlines';
  static const String apiKey = '39c1ac3e795348d5b64f81a338b1cc77';
  static const String countryCode = 'us';

  static const String newsScreenTitle = 'Top Headlines';

  static const double appBarTitleFontSize = 20.0;
  static const double regularFontSize = 12.0;
  static const double titleFontSize = 16.0;
  static const double buttonFontSize = 14.0;

  static const double padding = 8;
  static const double height = 200;
  static const double spacer = 20;
  static const double iconSize = 50;

  static const Color primaryColor = Colors.blueAccent;
  static const Color secondaryColor = Colors.grey;
  static const Color tertiaryColor = Colors.blueGrey;

  static const String source = 'Source:';
  static const String publishedOn = 'Published on:';
  static const String author = 'Author:';
  static const String errorMessage = 'Failed to load news. Please try again.';
  static const String reloadButtonText = 'Reload';
  static const String noDataMessage = 'No data available';
  static const String invalidDateMessage = 'Invalid date';
}

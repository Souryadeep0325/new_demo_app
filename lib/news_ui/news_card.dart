// NewsCard widget to display individual news articles
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/news-schema/news_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
class NewsCard extends StatelessWidget {
  final NewsModel article;

  NewsCard({required this.article});

  @override
 Widget build(BuildContext context) {
  return Card(
    margin: EdgeInsets.all(10),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15), // Set the radius of rounded corners
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(), // Extract image handling into a separate method
        _buildTitle(), // Extract title to a method
        _buildDescription(), // Extract description to a method
        _buildPublishedDate(), // Extract published date to a method
        _buildReadMoreButton(), // Extract button to a method
      ],
    ),
  );
}


  // Extracted method to handle image display
  Widget _buildImage() {
  return article.urlToImage.isNotEmpty
      ? Image.network(
          article.urlToImage,
          height: 500,
          width: double.infinity,
          fit: BoxFit.scaleDown,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(height: 200, color: Colors.grey); // Fallback if image fails
          },
        )
      : Container(height: 200, color: Colors.grey); // Fallback if no image URL
}


  // Extracted method to handle article title
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        article.title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Extracted method to handle article description
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        article.description,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  // Extracted method to handle published date
  Widget _buildPublishedDate() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Published on: ${getFormattedDate(article.publishedAt)}',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  // Extracted method to handle the 'Read more' button
  Widget _buildReadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // Add functionality to navigate to a web view screen or open the article URL
        },
        child: Text('Read more'),
      ),
    );
  }


  String getFormattedDate(String dateStr) {
    DateTime dateTime = convertToDateTime(dateStr);
  
  // Extract only the date part (yyyy-MM-dd)
  String formattedDate = formatDateOnly(dateTime);
  return formattedDate;
  }

  DateTime convertToDateTime(String dateStr) {
  return DateTime.parse(dateStr);  // Convert the string into a DateTime object
}

// Function to format DateTime to 'yyyy-MM-dd' format
String formatDateOnly(DateTime dateTime) {
  // Extract year, month, and day
  int year = dateTime.year;
  int month = dateTime.month;
  int day = dateTime.day;
  
  // Return the formatted date string as 'yyyy-MM-dd'
  return "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
}
}
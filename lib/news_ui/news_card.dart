import 'package:flutter/material.dart';
import 'package:news_app/news-schema/news_model.dart';

import 'package:news_app/news_ui/constant.dart';

class NewsCard extends StatelessWidget {
  final NewsModel article;

  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(Constants.padding * 2),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding * 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          _buildTitle(),
          _buildDescription(),
          _buildPublishedSource(),
          _buildPublishedDate(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return article.urlToImage.isNotEmpty
        ? Image.network(
            article.urlToImage,
            height: Constants.height,
            width: double.infinity,
            fit: BoxFit.cover,
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
              return Container(
                height: Constants.height,
                color: Constants.secondaryColor,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.error_outline,
                  color: Constants.primaryColor,
                  size: Constants.iconSize,
                ),
              );
            },
          )
        : Container(
            height: Constants.height,
            color: Constants.secondaryColor,
            alignment: Alignment.center,
            child: const Icon(
              Icons.error_outline,
              color: Constants.primaryColor,
              size: Constants.iconSize,
            ),
          ); // Fallback if no image URL
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(Constants.padding),
      child: Text(
        article.title,
        style: const TextStyle(
            fontSize: Constants.titleFontSize,
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Constants.padding),
      child: Text(
        article.description,
        style: const TextStyle(
            color: Constants.tertiaryColor,
            fontSize: Constants.regularFontSize),
        maxLines: 4,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildPublishedSource() {
    return Padding(
      padding: const EdgeInsets.all(Constants.padding),
      child: Text(
        '${Constants.source}  ${article.sourceName}',
        style: const TextStyle(
            fontSize: Constants.regularFontSize,
            color: Constants.secondaryColor),
      ),
    );
  }

  Widget _buildPublishedDate() {
    return Padding(
      padding: const EdgeInsets.only(
          left: Constants.padding,
          right: Constants.padding,
          bottom: Constants.padding),
      child: Text(
        '${Constants.publishedOn} ${article.publishedAt}',
        style: const TextStyle(
            fontSize: Constants.regularFontSize,
            color: Constants.secondaryColor),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:news_app/news-schema/news_model.dart';
import 'package:news_app/news_ui/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsModel article;

  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: Constants.appBarTitleFontSize,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Constants.primaryColor,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Constants.padding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),

            const SizedBox(height: Constants.padding),

            // Article Title
            Text(
              article.title,
              style: const TextStyle(
                fontSize: Constants.titleFontSize,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
            const SizedBox(height: Constants.spacer),

            // Published Date
            Text(
              '${Constants.author} ${article.author}',
              style: const TextStyle(
                  fontSize: Constants.regularFontSize,
                  color: Constants.secondaryColor),
            ),
            Text(
              '${Constants.source} ${article.sourceName}',
              style: const TextStyle(
                  fontSize: Constants.regularFontSize,
                  color: Constants.secondaryColor),
            ),
            Text(
              "${Constants.publishedOn} ${article.publishedAt}",
              style: const TextStyle(
                  fontSize: Constants.regularFontSize,
                  color: Constants.secondaryColor),
            ),
            const SizedBox(height: Constants.spacer),

            // Article Description
            Text(
              article.description,
              style: const TextStyle(
                  fontSize: Constants.regularFontSize,
                  color: Constants.tertiaryColor),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Constants.spacer),

            Text(
              article.content ?? 'No content available',
              style: const TextStyle(
                  fontSize: Constants.regularFontSize,
                  color: Constants.tertiaryColor),
              maxLines: null,
              overflow: TextOverflow.visible,
            ),

            const SizedBox(height: Constants.spacer),

            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse(article.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: const Text(
                'Read full article',
                style: TextStyle(
                  fontSize: Constants.buttonFontSize,
                  color: Constants.primaryColor,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
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
          );
  }
}

class NewsModel {
  final String title;
  final String description;
  final String urlToImage;
  final String url;
  final String publishedAt;

  NewsModel({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.url,
    required this.publishedAt,
  });

  // Constructor to handle JSON parsing
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'No Title', // Use default if null
      description: json['description'] ?? 'No Description', // Use default if null
      urlToImage: json['urlToImage'] ?? '', // Use empty string if null
      url: json['url'] ?? '', // Use empty string if null
      publishedAt: json['publishedAt'] ?? 'Unknown', // Use default if null
    );
  }
}

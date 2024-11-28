class NewsModel {
  final String title;
  final String description;
  final String urlToImage;
  final String url;
  final String publishedAt;
  final String? author;  // Optional field: Some articles may not have an author
  final String? content; // Optional field: Some articles may not have content
  final String sourceName; // Source name (e.g., 'CNN', 'Reuters')

  // Constructor to initialize all properties
  NewsModel({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.url,
    required this.publishedAt,
    this.author,
    this.content,
    required this.sourceName,
  });

  // Factory constructor to create a NewsModel from JSON
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'No Title', // Default to 'No Title' if missing
      description: json['description'] ?? 'No Description', // Default to 'No Description' if missing
      urlToImage: json['urlToImage'] ?? '', // Empty string if no image URL
      url: json['url'] ?? '', // Empty string if no URL
      publishedAt: json['publishedAt'] ?? 'Unknown', // Default to 'Unknown' if no date
      author: json['author'], // Some articles may not have an author
      content: json['content'], // Some articles may not have content
      sourceName: json['source']['name'] ?? 'Unknown', // Source name from the 'source' object
    );
  }
}

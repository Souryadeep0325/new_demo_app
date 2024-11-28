class NewsModel {
  final String title;
  final String description;
  final String urlToImage;
  final String url;
  final String publishedAt;
  final String? author;
  final String? content;
  final String sourceName;

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

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      urlToImage: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? 'Unknown',
      author: json['author'],
      content: json['content'],
      sourceName: json['source']['name'] ?? 'Unknown',
    );
  }
}

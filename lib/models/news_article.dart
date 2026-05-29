class NewsArticle {
  final String title;
  final String description;
  final String link;
  final String imageUrl;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.link,
    required this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? '',
      link: json['link'] as String? ?? '',
      imageUrl: json['img'] as String? ?? '',
    );
  }
}

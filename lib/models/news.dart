class NewsItem {
  final String company;
  final String title;
  final String url;
  final String description;
  final String summaryKo;
  final String sentiment;
  final String publishedAt;

  NewsItem({
    required this.company,
    required this.title,
    required this.url,
    required this.description,
    required this.summaryKo,
    required this.sentiment,
    required this.publishedAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      company: json['company'],
      title: json['title'],
      url: json['url'],
      description: json['description'] ?? "",
      summaryKo: json['summary_ko'] ?? "요약 없음",
      sentiment: json['sentiment'] ?? "neutral",
      publishedAt: json['publishedAt'] ?? "",
    );
  }
}

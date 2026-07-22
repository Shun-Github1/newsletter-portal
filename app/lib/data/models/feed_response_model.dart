import 'article_model.dart';

class FeedResponseModel {
  final List<ArticleModel> articles;
  final List<ArticleModel>? headlines;

  const FeedResponseModel({
    required this.articles,
    this.headlines,
  });

  factory FeedResponseModel.fromJson(Map<String, dynamic> json) {
    return FeedResponseModel(
      articles: (json['articles'] as List<dynamic>).map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList(),
      headlines: json['headlines'] != null ? (json['headlines'] as List<dynamic>).map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articles': articles.map((e) => e.toJson()).toList(),
      'headlines': headlines?.map((e) => e.toJson()).toList(),
    };
  }

  FeedResponseModel copyWith({
    List<ArticleModel>? articles,
    List<ArticleModel>? headlines,
  }) {
    return FeedResponseModel(
      articles: articles ?? this.articles,
      headlines: headlines ?? this.headlines,
    );
  }
}

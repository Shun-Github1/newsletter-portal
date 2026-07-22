import 'article_model.dart';
import 'search_meta_model.dart';

class SearchResponseModel {
  final List<ArticleModel> articles;
  final SearchMetaModel? meta;

  const SearchResponseModel({
    required this.articles,
    this.meta,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchResponseModel(
      articles: (json['articles'] as List<dynamic>).map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList(),
      meta: json['meta'] != null ? SearchMetaModel.fromJson(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articles': articles.map((e) => e.toJson()).toList(),
      'meta': meta?.toJson(),
    };
  }

  SearchResponseModel copyWith({
    List<ArticleModel>? articles,
    SearchMetaModel? meta,
  }) {
    return SearchResponseModel(
      articles: articles ?? this.articles,
      meta: meta ?? this.meta,
    );
  }
}

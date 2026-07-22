import 'article_model.dart';
import 'article_description_model.dart';
import 'coverage_detail_model.dart';
import 'metrics_model.dart';
import 'source_article_model.dart';
import 'topic_model.dart';

class ArticleDetailModel {
  final String title;
  final String? pictureURL;
  final String date;
  final String articleID;
  final String? shareURL;
  final String? sector;
  final String? region;
  final ArticleDescriptionModel? description;
  final CoverageDetailModel? coverage;
  final MetricsModel? metrics;
  final List<SourceArticleModel>? articles;
  final List<TopicModel>? relatedTopics;
  final List<ArticleModel>? relatedArticles;

  const ArticleDetailModel({
    required this.title,
    this.pictureURL,
    required this.date,
    required this.articleID,
    this.shareURL,
    this.sector,
    this.region,
    this.description,
    this.coverage,
    this.metrics,
    this.articles,
    this.relatedTopics,
    this.relatedArticles,
  });

  factory ArticleDetailModel.fromJson(Map<String, dynamic> json) {
    return ArticleDetailModel(
      title: json['title'] as String,
      pictureURL: json['pictureURL'] as String?,
      date: json['date'] as String,
      articleID: json['articleID'] as String,
      shareURL: json['shareURL'] as String?,
      sector: json['sector'] as String?,
      region: json['region'] as String?,
      description: json['description'] != null ? ArticleDescriptionModel.fromJson(json['description']) : null,
      coverage: json['coverage'] != null ? CoverageDetailModel.fromJson(json['coverage']) : null,
      metrics: json['metrics'] != null ? MetricsModel.fromJson(json['metrics']) : null,
      articles: json['articles'] != null ? (json['articles'] as List<dynamic>).map((e) => SourceArticleModel.fromJson(e as Map<String, dynamic>)).toList() : null,
      relatedTopics: json['relatedTopics'] != null ? (json['relatedTopics'] as List<dynamic>).map((e) => TopicModel.fromJson(e as Map<String, dynamic>)).toList() : null,
      relatedArticles: json['relatedArticles'] != null ? (json['relatedArticles'] as List<dynamic>).map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'pictureURL': pictureURL,
      'date': date,
      'articleID': articleID,
      'shareURL': shareURL,
      'sector': sector,
      'region': region,
      'description': description?.toJson(),
      'coverage': coverage?.toJson(),
      'metrics': metrics?.toJson(),
      'articles': articles?.map((e) => e.toJson()).toList(),
      'relatedTopics': relatedTopics?.map((e) => e.toJson()).toList(),
      'relatedArticles': relatedArticles?.map((e) => e.toJson()).toList(),
    };
  }

  ArticleDetailModel copyWith({
    String? title,
    String? pictureURL,
    String? date,
    String? articleID,
    String? shareURL,
    String? sector,
    String? region,
    ArticleDescriptionModel? description,
    CoverageDetailModel? coverage,
    MetricsModel? metrics,
    List<SourceArticleModel>? articles,
    List<TopicModel>? relatedTopics,
    List<ArticleModel>? relatedArticles,
  }) {
    return ArticleDetailModel(
      title: title ?? this.title,
      pictureURL: pictureURL ?? this.pictureURL,
      date: date ?? this.date,
      articleID: articleID ?? this.articleID,
      shareURL: shareURL ?? this.shareURL,
      sector: sector ?? this.sector,
      region: region ?? this.region,
      description: description ?? this.description,
      coverage: coverage ?? this.coverage,
      metrics: metrics ?? this.metrics,
      articles: articles ?? this.articles,
      relatedTopics: relatedTopics ?? this.relatedTopics,
      relatedArticles: relatedArticles ?? this.relatedArticles,
    );
  }
}

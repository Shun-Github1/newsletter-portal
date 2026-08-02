import 'coverage_model.dart';
import 'metrics_model.dart';

class ArticleModel {
  final String title;
  final String? pictureURL;
  final String date;
  final String? articleURL;
  final String articleID;
  final CoverageModel? coverage;
  final MetricsModel? metrics;
  final String? region;
  final String? sector;
  final int? nSources;
  final String? description;
  final String? synopsis;
  final String? summary;
  final String? implications;

  const ArticleModel({
    required this.title,
    this.pictureURL,
    required this.date,
    this.articleURL,
    required this.articleID,
    this.coverage,
    this.metrics,
    this.region,
    this.sector,
    this.nSources,
    this.description,
    this.synopsis,
    this.summary,
    this.implications,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    String? desc;
    String? parsedSynopsis;
    String? parsedSummary;
    String? parsedImplications;

    if (json['description'] is String && (json['description'] as String).trim().isNotEmpty) {
      desc = (json['description'] as String).trim();
    } else if (json['description'] is Map) {
      final descMap = json['description'] as Map<String, dynamic>;
      parsedSynopsis = descMap['synopsis'] as String?;
      parsedImplications = descMap['implications'] as String?;
      parsedSummary = descMap['summary'] as String?;
      
      final summaryFallback = descMap['summary'] as String? ?? descMap['description'] as String? ?? descMap['content'] as String?;

      final List<String> parts = [];
      if (parsedSynopsis != null && parsedSynopsis.trim().isNotEmpty) {
        parts.add(parsedSynopsis.trim());
      }
      if (parsedImplications != null && parsedImplications.trim().isNotEmpty) {
        parts.add('Implications: ${parsedImplications.trim()}');
      }
      if (parts.isEmpty && summaryFallback != null && summaryFallback.trim().isNotEmpty) {
        parts.add(summaryFallback.trim());
      }
      desc = parts.isNotEmpty ? parts.join('\n\n') : null;
    } else if (json['synopsis'] is String && (json['synopsis'] as String).trim().isNotEmpty) {
      desc = (json['synopsis'] as String).trim();
      parsedSynopsis = desc;
    } else if (json['summary'] is String && (json['summary'] as String).trim().isNotEmpty) {
      desc = (json['summary'] as String).trim();
      parsedSummary = desc;
    } else if (json['content'] is String && (json['content'] as String).trim().isNotEmpty) {
      desc = (json['content'] as String).trim();
    } else if (json['text'] is String && (json['text'] as String).trim().isNotEmpty) {
      desc = (json['text'] as String).trim();
    }

    return ArticleModel(
      title: json['title'] as String? ?? 'Untitled Article',
      pictureURL: json['pictureURL'] as String?,
      date: json['date'] as String? ?? DateTime.now().toIso8601String(),
      articleURL: json['articleURL'] as String?,
      articleID: json['articleID'] as String? ?? json['id'] as String? ?? '',
      coverage: json['coverage'] != null ? CoverageModel.fromJson(json['coverage']) : null,
      metrics: json['metrics'] != null ? MetricsModel.fromJson(json['metrics']) : null,
      region: json['region'] as String?,
      sector: json['sector'] as String?,
      nSources: json['nSources'] as int?,
      description: desc,
      synopsis: parsedSynopsis,
      summary: parsedSummary,
      implications: parsedImplications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'pictureURL': pictureURL,
      'date': date,
      'articleURL': articleURL,
      'articleID': articleID,
      'coverage': coverage?.toJson(),
      'metrics': metrics?.toJson(),
      'region': region,
      'sector': sector,
      'nSources': nSources,
      'description': description,
      'synopsis': synopsis,
      'summary': summary,
      'implications': implications,
    };
  }

  ArticleModel copyWith({
    String? title,
    String? pictureURL,
    String? date,
    String? articleURL,
    String? articleID,
    CoverageModel? coverage,
    MetricsModel? metrics,
    String? region,
    String? sector,
    int? nSources,
    String? description,
    String? synopsis,
    String? summary,
    String? implications,
  }) {
    return ArticleModel(
      title: title ?? this.title,
      pictureURL: pictureURL ?? this.pictureURL,
      date: date ?? this.date,
      articleURL: articleURL ?? this.articleURL,
      articleID: articleID ?? this.articleID,
      coverage: coverage ?? this.coverage,
      metrics: metrics ?? this.metrics,
      region: region ?? this.region,
      sector: sector ?? this.sector,
      nSources: nSources ?? this.nSources,
      description: description ?? this.description,
      synopsis: synopsis ?? this.synopsis,
      summary: summary ?? this.summary,
      implications: implications ?? this.implications,
    );
  }
}

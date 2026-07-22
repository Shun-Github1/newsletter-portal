import os
import json

base_dir = r"c:\Users\ShunKwok\OneDrive - Searcher\Desktop\newsletter-portal\app\lib\data"
models_dir = os.path.join(base_dir, "models")
datasources_dir = os.path.join(base_dir, "datasources")

os.makedirs(models_dir, exist_ok=True)
os.makedirs(datasources_dir, exist_ok=True)

files = {}

files[f"{models_dir}/api_response_model.dart"] = """
class ApiResponse<T> {
  final int code;
  final String msg;
  final T? data;

  const ApiResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return ApiResponse<T>(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'code': code,
      'msg': msg,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }
}
"""

files[f"{models_dir}/user_model.dart"] = """
class UserModel {
  final String authMethod;
  final String email;
  final bool isPro;
  final String language;
  final String profileIcon;
  final String username;

  const UserModel({
    required this.authMethod,
    required this.email,
    required this.isPro,
    required this.language,
    required this.profileIcon,
    required this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      authMethod: json['authMethod'] as String,
      email: json['email'] as String,
      isPro: json['isPro'] as bool,
      language: json['language'] as String,
      profileIcon: json['profileIcon'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authMethod': authMethod,
      'email': email,
      'isPro': isPro,
      'language': language,
      'profileIcon': profileIcon,
      'username': username,
    };
  }

  UserModel copyWith({
    String? authMethod,
    String? email,
    bool? isPro,
    String? language,
    String? profileIcon,
    String? username,
  }) {
    return UserModel(
      authMethod: authMethod ?? this.authMethod,
      email: email ?? this.email,
      isPro: isPro ?? this.isPro,
      language: language ?? this.language,
      profileIcon: profileIcon ?? this.profileIcon,
      username: username ?? this.username,
    );
  }
}
"""

files[f"{models_dir}/coverage_model.dart"] = """
class CoverageModel {
  final double centric;
  final double progressive;

  const CoverageModel({
    required this.centric,
    required this.progressive,
  });

  factory CoverageModel.fromJson(Map<String, dynamic> json) {
    return CoverageModel(
      centric: (json['centric'] as num).toDouble(),
      progressive: (json['progressive'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centric': centric,
      'progressive': progressive,
    };
  }

  CoverageModel copyWith({
    double? centric,
    double? progressive,
  }) {
    return CoverageModel(
      centric: centric ?? this.centric,
      progressive: progressive ?? this.progressive,
    );
  }
}
"""

files[f"{models_dir}/metrics_model.dart"] = """
class MetricsModel {
  final double? sentiment;
  final double? subjectivity;

  const MetricsModel({
    this.sentiment,
    this.subjectivity,
  });

  factory MetricsModel.fromJson(Map<String, dynamic> json) {
    return MetricsModel(
      sentiment: json['sentiment'] != null ? (json['sentiment'] as num).toDouble() : null,
      subjectivity: json['subjectivity'] != null ? (json['subjectivity'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentiment': sentiment,
      'subjectivity': subjectivity,
    };
  }

  MetricsModel copyWith({
    double? sentiment,
    double? subjectivity,
  }) {
    return MetricsModel(
      sentiment: sentiment ?? this.sentiment,
      subjectivity: subjectivity ?? this.subjectivity,
    );
  }
}
"""

files[f"{models_dir}/article_model.dart"] = """
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
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] as String,
      pictureURL: json['pictureURL'] as String?,
      date: json['date'] as String,
      articleURL: json['articleURL'] as String?,
      articleID: json['articleID'] as String,
      coverage: json['coverage'] != null ? CoverageModel.fromJson(json['coverage']) : null,
      metrics: json['metrics'] != null ? MetricsModel.fromJson(json['metrics']) : null,
      region: json['region'] as String?,
      sector: json['sector'] as String?,
      nSources: json['nSources'] as int?,
      description: json['description'] as String?,
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
    );
  }
}
"""

files[f"{models_dir}/feed_response_model.dart"] = """
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
"""

files[f"{models_dir}/article_description_model.dart"] = """
class ArticleDescriptionModel {
  final String? synopsis;
  final String? implications;

  const ArticleDescriptionModel({
    this.synopsis,
    this.implications,
  });

  factory ArticleDescriptionModel.fromJson(Map<String, dynamic> json) {
    return ArticleDescriptionModel(
      synopsis: json['synopsis'] as String?,
      implications: json['implications'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'synopsis': synopsis,
      'implications': implications,
    };
  }

  ArticleDescriptionModel copyWith({
    String? synopsis,
    String? implications,
  }) {
    return ArticleDescriptionModel(
      synopsis: synopsis ?? this.synopsis,
      implications: implications ?? this.implications,
    );
  }
}
"""

files[f"{models_dir}/icon_position_model.dart"] = """
class IconPositionModel {
  final double size;
  final double rx;
  final double ry;
  final String logo;

  const IconPositionModel({
    required this.size,
    required this.rx,
    required this.ry,
    required this.logo,
  });

  factory IconPositionModel.fromJson(Map<String, dynamic> json) {
    return IconPositionModel(
      size: (json['size'] as num).toDouble(),
      rx: (json['rx'] as num).toDouble(),
      ry: (json['ry'] as num).toDouble(),
      logo: json['logo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'rx': rx,
      'ry': ry,
      'logo': logo,
    };
  }

  IconPositionModel copyWith({
    double? size,
    double? rx,
    double? ry,
    String? logo,
  }) {
    return IconPositionModel(
      size: size ?? this.size,
      rx: rx ?? this.rx,
      ry: ry ?? this.ry,
      logo: logo ?? this.logo,
    );
  }
}
"""

files[f"{models_dir}/coverage_icons_model.dart"] = """
import 'icon_position_model.dart';

class CoverageIconsModel {
  final List<IconPositionModel>? centric;
  final List<IconPositionModel>? progressive;

  const CoverageIconsModel({
    this.centric,
    this.progressive,
  });

  factory CoverageIconsModel.fromJson(Map<String, dynamic> json) {
    return CoverageIconsModel(
      centric: json['centric'] != null ? (json['centric'] as List<dynamic>).map((e) => IconPositionModel.fromJson(e as Map<String, dynamic>)).toList() : null,
      progressive: json['progressive'] != null ? (json['progressive'] as List<dynamic>).map((e) => IconPositionModel.fromJson(e as Map<String, dynamic>)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centric': centric?.map((e) => e.toJson()).toList(),
      'progressive': progressive?.map((e) => e.toJson()).toList(),
    };
  }

  CoverageIconsModel copyWith({
    List<IconPositionModel>? centric,
    List<IconPositionModel>? progressive,
  }) {
    return CoverageIconsModel(
      centric: centric ?? this.centric,
      progressive: progressive ?? this.progressive,
    );
  }
}
"""

files[f"{models_dir}/coverage_detail_model.dart"] = """
import 'coverage_model.dart';
import 'coverage_icons_model.dart';

class CoverageDetailModel {
  final CoverageModel? percentage;
  final CoverageIconsModel? icons;

  const CoverageDetailModel({
    this.percentage,
    this.icons,
  });

  factory CoverageDetailModel.fromJson(Map<String, dynamic> json) {
    return CoverageDetailModel(
      percentage: json['percentage'] != null ? CoverageModel.fromJson(json['percentage']) : null,
      icons: json['icons'] != null ? CoverageIconsModel.fromJson(json['icons']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage?.toJson(),
      'icons': icons?.toJson(),
    };
  }

  CoverageDetailModel copyWith({
    CoverageModel? percentage,
    CoverageIconsModel? icons,
  }) {
    return CoverageDetailModel(
      percentage: percentage ?? this.percentage,
      icons: icons ?? this.icons,
    );
  }
}
"""

files[f"{models_dir}/stance_model.dart"] = """
class StanceModel {
  final String tag;
  final String displayName;

  const StanceModel({
    required this.tag,
    required this.displayName,
  });

  factory StanceModel.fromJson(Map<String, dynamic> json) {
    return StanceModel(
      tag: json['tag'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'displayName': displayName,
    };
  }

  StanceModel copyWith({
    String? tag,
    String? displayName,
  }) {
    return StanceModel(
      tag: tag ?? this.tag,
      displayName: displayName ?? this.displayName,
    );
  }
}
"""

files[f"{models_dir}/source_article_model.dart"] = """
import 'stance_model.dart';

class SourceArticleModel {
  final int publisherID;
  final String publisherName;
  final String? publisherIcon;
  final String title;
  final String articleURL;
  final StanceModel? publisherStance;
  final int? mediaSignificance;
  final int? bias;
  final String? publisherRegion;

  const SourceArticleModel({
    required this.publisherID,
    required this.publisherName,
    this.publisherIcon,
    required this.title,
    required this.articleURL,
    this.publisherStance,
    this.mediaSignificance,
    this.bias,
    this.publisherRegion,
  });

  factory SourceArticleModel.fromJson(Map<String, dynamic> json) {
    return SourceArticleModel(
      publisherID: json['publisherID'] as int,
      publisherName: json['publisherName'] as String,
      publisherIcon: json['publisherIcon'] as String?,
      title: json['title'] as String,
      articleURL: json['articleURL'] as String,
      publisherStance: json['publisherStance'] != null ? StanceModel.fromJson(json['publisherStance']) : null,
      mediaSignificance: json['mediaSignificance'] as int?,
      bias: json['bias'] as int?,
      publisherRegion: json['publisherRegion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publisherID': publisherID,
      'publisherName': publisherName,
      'publisherIcon': publisherIcon,
      'title': title,
      'articleURL': articleURL,
      'publisherStance': publisherStance?.toJson(),
      'mediaSignificance': mediaSignificance,
      'bias': bias,
      'publisherRegion': publisherRegion,
    };
  }

  SourceArticleModel copyWith({
    int? publisherID,
    String? publisherName,
    String? publisherIcon,
    String? title,
    String? articleURL,
    StanceModel? publisherStance,
    int? mediaSignificance,
    int? bias,
    String? publisherRegion,
  }) {
    return SourceArticleModel(
      publisherID: publisherID ?? this.publisherID,
      publisherName: publisherName ?? this.publisherName,
      publisherIcon: publisherIcon ?? this.publisherIcon,
      title: title ?? this.title,
      articleURL: articleURL ?? this.articleURL,
      publisherStance: publisherStance ?? this.publisherStance,
      mediaSignificance: mediaSignificance ?? this.mediaSignificance,
      bias: bias ?? this.bias,
      publisherRegion: publisherRegion ?? this.publisherRegion,
    );
  }
}
"""

files[f"{models_dir}/topic_model.dart"] = """
class TopicModel {
  final String tag;
  final String displayName;

  const TopicModel({
    required this.tag,
    required this.displayName,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      tag: json['tag'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'displayName': displayName,
    };
  }

  TopicModel copyWith({
    String? tag,
    String? displayName,
  }) {
    return TopicModel(
      tag: tag ?? this.tag,
      displayName: displayName ?? this.displayName,
    );
  }
}
"""

files[f"{models_dir}/article_detail_model.dart"] = """
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
"""

files[f"{models_dir}/sector_model.dart"] = """
class SectorModel {
  final String tag;
  final String displayName;

  const SectorModel({
    required this.tag,
    required this.displayName,
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      tag: json['tag'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'displayName': displayName,
    };
  }

  SectorModel copyWith({
    String? tag,
    String? displayName,
  }) {
    return SectorModel(
      tag: tag ?? this.tag,
      displayName: displayName ?? this.displayName,
    );
  }
}
"""

files[f"{models_dir}/region_model.dart"] = """
class RegionModel {
  final String tag;
  final String displayName;

  const RegionModel({
    required this.tag,
    required this.displayName,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      tag: json['tag'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'displayName': displayName,
    };
  }

  RegionModel copyWith({
    String? tag,
    String? displayName,
  }) {
    return RegionModel(
      tag: tag ?? this.tag,
      displayName: displayName ?? this.displayName,
    );
  }
}
"""

files[f"{models_dir}/region_response_model.dart"] = """
import 'region_model.dart';

class RegionResponseModel {
  final List<RegionModel> regions;
  final List<String> selected;

  const RegionResponseModel({
    required this.regions,
    required this.selected,
  });

  factory RegionResponseModel.fromJson(Map<String, dynamic> json) {
    return RegionResponseModel(
      regions: (json['regions'] as List<dynamic>).map((e) => RegionModel.fromJson(e as Map<String, dynamic>)).toList(),
      selected: (json['selected'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regions': regions.map((e) => e.toJson()).toList(),
      'selected': selected,
    };
  }

  RegionResponseModel copyWith({
    List<RegionModel>? regions,
    List<String>? selected,
  }) {
    return RegionResponseModel(
      regions: regions ?? this.regions,
      selected: selected ?? this.selected,
    );
  }
}
"""

files[f"{models_dir}/search_meta_model.dart"] = """
class SearchMetaModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const SearchMetaModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory SearchMetaModel.fromJson(Map<String, dynamic> json) {
    return SearchMetaModel(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }

  SearchMetaModel copyWith({
    int? page,
    int? limit,
    int? total,
    int? totalPages,
  }) {
    return SearchMetaModel(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
"""

files[f"{models_dir}/search_response_model.dart"] = """
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
"""

files[f"{models_dir}/publisher_model.dart"] = """
import 'stance_model.dart';

class PublisherModel {
  final String? conglomerate;
  final String? controller;
  final int id;
  final String? intro;
  final String name;
  final String? region;
  final StanceModel? stance;
  final String? type;
  final String? website;

  const PublisherModel({
    this.conglomerate,
    this.controller,
    required this.id,
    this.intro,
    required this.name,
    this.region,
    this.stance,
    this.type,
    this.website,
  });

  factory PublisherModel.fromJson(Map<String, dynamic> json) {
    return PublisherModel(
      conglomerate: json['conglomerate'] as String?,
      controller: json['controller'] as String?,
      id: json['id'] as int,
      intro: json['intro'] as String?,
      name: json['name'] as String,
      region: json['region'] as String?,
      stance: json['stance'] != null ? StanceModel.fromJson(json['stance']) : null,
      type: json['type'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conglomerate': conglomerate,
      'controller': controller,
      'id': id,
      'intro': intro,
      'name': name,
      'region': region,
      'stance': stance?.toJson(),
      'type': type,
      'website': website,
    };
  }

  PublisherModel copyWith({
    String? conglomerate,
    String? controller,
    int? id,
    String? intro,
    String? name,
    String? region,
    StanceModel? stance,
    String? type,
    String? website,
  }) {
    return PublisherModel(
      conglomerate: conglomerate ?? this.conglomerate,
      controller: controller ?? this.controller,
      id: id ?? this.id,
      intro: intro ?? this.intro,
      name: name ?? this.name,
      region: region ?? this.region,
      stance: stance ?? this.stance,
      type: type ?? this.type,
      website: website ?? this.website,
    );
  }
}
"""

files[f"{models_dir}/login_response_model.dart"] = """
class LoginResponseModel {
  final String? csrfToken;

  const LoginResponseModel({
    this.csrfToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      csrfToken: json['csrf_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'csrf_token': csrfToken,
    };
  }

  LoginResponseModel copyWith({
    String? csrfToken,
  }) {
    return LoginResponseModel(
      csrfToken: csrfToken ?? this.csrfToken,
    );
  }
}
"""

files[f"{datasources_dir}/auth_remote_datasource.dart"] = """
import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource(this._dio);

  Future<void> register(String email, String username, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'username': username,
      'password': password,
    });
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> logout() async {
    final response = await _dio.post('/auth/logout');
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
  }

  Future<void> refreshToken() async {
    final response = await _dio.post('/auth/refresh');
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
  }
}
"""

files[f"{datasources_dir}/profile_remote_datasource.dart"] = """
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/topic_model.dart';
import '../models/sector_model.dart';
import '../models/region_response_model.dart';
import '../models/article_model.dart';

class ProfileRemoteDatasource {
  final Dio _dio;

  ProfileRemoteDatasource(this._dio);

  Future<UserModel> getProfile() async {
    final response = await _dio.get('/profile');
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return UserModel.fromJson(response.data['data']);
  }

  Future<void> changeLanguage(String lang) async {
    final response = await _dio.post('/profile/language', data: {'language': lang});
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
  }

  Future<List<TopicModel>> getTopics({String? lang}) async {
    final response = await _dio.get('/profile/topics', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return (response.data['data'] as List).map((e) => TopicModel.fromJson(e)).toList();
  }

  Future<List<TopicModel>> getAllTopics({String? lang}) async {
    final response = await _dio.get('/topics/all', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return (response.data['data'] as List).map((e) => TopicModel.fromJson(e)).toList();
  }

  Future<void> editTopic(String action, String topic, {String? lang}) async {
    final response = await _dio.post('/profile/topics/edit', data: {
      'action': action,
      'topic': topic,
    }, queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
  }

  Future<List<SectorModel>> getSectors({String? lang}) async {
    final response = await _dio.get('/sectors', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return (response.data['data'] as List).map((e) => SectorModel.fromJson(e)).toList();
  }

  Future<RegionResponseModel> getPublisherRegions({String? lang}) async {
    final response = await _dio.get('/profile/regions', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return RegionResponseModel.fromJson(response.data['data']);
  }

  Future<void> editPublisherRegion(String action, String tag, {String? lang}) async {
    final response = await _dio.post('/profile/regions/edit', data: {
      'action': action,
      'tag': tag,
    }, queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
  }

  Future<List<ArticleModel>> getHistory({String? lang}) async {
    final response = await _dio.get('/profile/history', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return (response.data['data'] as List).map((e) => ArticleModel.fromJson(e)).toList();
  }

  Future<List<ArticleModel>> getSaved({String? lang}) async {
    final response = await _dio.get('/profile/saved', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return (response.data['data'] as List).map((e) => ArticleModel.fromJson(e)).toList();
  }

  Future<void> saveArticle(String articleId) async {
    final response = await _dio.post('/profile/saved/add', data: {'articleId': articleId});
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
  }

  Future<void> addToReadingHistory(String articleId) async {
    final response = await _dio.post('/profile/history/add', data: {'articleId': articleId});
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
  }
}
"""

files[f"{datasources_dir}/feed_remote_datasource.dart"] = """
import 'package:dio/dio.dart';
import '../models/feed_response_model.dart';
import '../models/topic_model.dart';

class FeedRemoteDatasource {
  final Dio _dio;

  FeedRemoteDatasource(this._dio);

  Future<FeedResponseModel> getHomeFeed({String? tag, int? offset, int? limit, String? lang}) async {
    final response = await _dio.get('/feed/home', queryParameters: {
      'tag': tag,
      'offset': offset,
      'limit': limit,
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return FeedResponseModel.fromJson(response.data['data']);
  }

  Future<FeedResponseModel> getPersonalFeed({int? offset, int? limit, String? lang, String? sortby}) async {
    final response = await _dio.get('/feed/personal', queryParameters: {
      'offset': offset,
      'limit': limit,
      'lang': lang,
      'sortby': sortby,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return FeedResponseModel.fromJson(response.data['data']);
  }

  Future<List<TopicModel>> getTrendingTopics({String? lang}) async {
    final response = await _dio.get('/feed/trending-topics', queryParameters: {
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return (response.data['data'] as List).map((e) => TopicModel.fromJson(e)).toList();
  }

  Future<FeedResponseModel> getFeedByTopic(String topic, {int? offset, int? limit, String? lang}) async {
    final response = await _dio.get('/feed/topic/\$topic', queryParameters: {
      'offset': offset,
      'limit': limit,
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return FeedResponseModel.fromJson(response.data['data']);
  }
}
"""

files[f"{datasources_dir}/article_remote_datasource.dart"] = """
import 'package:dio/dio.dart';
import '../models/article_detail_model.dart';

class ArticleRemoteDatasource {
  final Dio _dio;

  ArticleRemoteDatasource(this._dio);

  Future<ArticleDetailModel> getArticle(String idOrTitle, {String? lang}) async {
    final response = await _dio.get('/article/\$idOrTitle', queryParameters: {
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return ArticleDetailModel.fromJson(response.data['data']);
  }

  Future<void> submitFeedback(String idOrTitle, String content) async {
    final response = await _dio.post('/article/\$idOrTitle/feedback', data: {
      'content': content,
    });
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
  }
}
"""

files[f"{datasources_dir}/search_remote_datasource.dart"] = """
import 'package:dio/dio.dart';
import '../models/search_response_model.dart';

class SearchRemoteDatasource {
  final Dio _dio;

  SearchRemoteDatasource(this._dio);

  Future<SearchResponseModel> search(String query, {String? lang, int? page, int? limit, String? sortby}) async {
    final response = await _dio.get('/search', queryParameters: {
      'q': query,
      'lang': lang,
      'page': page,
      'limit': limit,
      'sortby': sortby,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return SearchResponseModel.fromJson(response.data['data']);
  }

  Future<SearchResponseModel> getTrendingSearch({String? lang}) async {
    final response = await _dio.get('/search/trending', queryParameters: {
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0) {
      throw Exception(response.data['msg']);
    }
    return SearchResponseModel.fromJson(response.data['data']);
  }
}
"""

for path, content in files.items():
    with open(path, "w", encoding="utf-8") as f:
        f.write(content.strip() + "\\n")
print(f"Created {len(files)} files successfully.")

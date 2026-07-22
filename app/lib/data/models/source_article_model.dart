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

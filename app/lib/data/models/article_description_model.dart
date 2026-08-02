class ArticleDescriptionModel {
  final String? synopsis;
  final String? implications;
  final String? summary;

  const ArticleDescriptionModel({
    this.synopsis,
    this.implications,
    this.summary,
  });

  factory ArticleDescriptionModel.fromJson(Map<String, dynamic> json) {
    return ArticleDescriptionModel(
      synopsis: json['synopsis'] as String?,
      implications: json['implications'] as String?,
      summary: json['summary'] as String? ?? json['description'] as String? ?? json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'synopsis': synopsis,
      'implications': implications,
      'summary': summary,
    };
  }

  ArticleDescriptionModel copyWith({
    String? synopsis,
    String? implications,
    String? summary,
  }) {
    return ArticleDescriptionModel(
      synopsis: synopsis ?? this.synopsis,
      implications: implications ?? this.implications,
      summary: summary ?? this.summary,
    );
  }
}

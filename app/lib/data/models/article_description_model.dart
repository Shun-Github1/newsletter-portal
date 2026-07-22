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

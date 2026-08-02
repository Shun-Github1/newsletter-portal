class Article {
  final String id;
  final String title;
  final String? imageUrl;
  final DateTime date;
  final String? url;
  final double? sentimentScore;
  final double? subjectivityScore;
  final double? centricScore;
  final double? progressiveScore;
  final String? region;
  final String? sector;
  final int? sourceCount;
  final String? synopsis;
  final String? summary;
  final String? implications;

  const Article({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.date,
    this.url,
    this.sentimentScore,
    this.subjectivityScore,
    this.centricScore,
    this.progressiveScore,
    this.region,
    this.sector,
    this.sourceCount,
    this.synopsis,
    this.summary,
    this.implications,
  });

  Article copyWith({
    String? id,
    String? title,
    String? imageUrl,
    DateTime? date,
    String? url,
    double? sentimentScore,
    double? subjectivityScore,
    double? centricScore,
    double? progressiveScore,
    String? region,
    String? sector,
    int? sourceCount,
    String? synopsis,
    String? summary,
    String? implications,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      url: url ?? this.url,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      subjectivityScore: subjectivityScore ?? this.subjectivityScore,
      centricScore: centricScore ?? this.centricScore,
      progressiveScore: progressiveScore ?? this.progressiveScore,
      region: region ?? this.region,
      sector: sector ?? this.sector,
      sourceCount: sourceCount ?? this.sourceCount,
      synopsis: synopsis ?? this.synopsis,
      summary: summary ?? this.summary,
      implications: implications ?? this.implications,
    );
  }
}

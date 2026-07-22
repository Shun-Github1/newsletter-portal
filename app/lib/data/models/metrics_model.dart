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

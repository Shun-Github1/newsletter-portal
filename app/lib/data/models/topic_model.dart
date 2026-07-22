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

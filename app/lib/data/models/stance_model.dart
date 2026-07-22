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

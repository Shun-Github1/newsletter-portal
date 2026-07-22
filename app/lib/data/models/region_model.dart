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

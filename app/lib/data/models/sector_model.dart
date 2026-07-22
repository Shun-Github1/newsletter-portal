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

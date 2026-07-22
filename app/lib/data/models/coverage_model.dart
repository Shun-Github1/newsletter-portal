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

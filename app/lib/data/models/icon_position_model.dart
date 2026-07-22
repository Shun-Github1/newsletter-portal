class IconPositionModel {
  final double size;
  final double rx;
  final double ry;
  final String logo;

  const IconPositionModel({
    required this.size,
    required this.rx,
    required this.ry,
    required this.logo,
  });

  factory IconPositionModel.fromJson(Map<String, dynamic> json) {
    return IconPositionModel(
      size: (json['size'] as num).toDouble(),
      rx: (json['rx'] as num).toDouble(),
      ry: (json['ry'] as num).toDouble(),
      logo: json['logo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'rx': rx,
      'ry': ry,
      'logo': logo,
    };
  }

  IconPositionModel copyWith({
    double? size,
    double? rx,
    double? ry,
    String? logo,
  }) {
    return IconPositionModel(
      size: size ?? this.size,
      rx: rx ?? this.rx,
      ry: ry ?? this.ry,
      logo: logo ?? this.logo,
    );
  }
}

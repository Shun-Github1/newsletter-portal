import 'icon_position_model.dart';

class CoverageIconsModel {
  final List<IconPositionModel>? centric;
  final List<IconPositionModel>? progressive;

  const CoverageIconsModel({
    this.centric,
    this.progressive,
  });

  factory CoverageIconsModel.fromJson(Map<String, dynamic> json) {
    return CoverageIconsModel(
      centric: json['centric'] != null ? (json['centric'] as List<dynamic>).map((e) => IconPositionModel.fromJson(e as Map<String, dynamic>)).toList() : null,
      progressive: json['progressive'] != null ? (json['progressive'] as List<dynamic>).map((e) => IconPositionModel.fromJson(e as Map<String, dynamic>)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centric': centric?.map((e) => e.toJson()).toList(),
      'progressive': progressive?.map((e) => e.toJson()).toList(),
    };
  }

  CoverageIconsModel copyWith({
    List<IconPositionModel>? centric,
    List<IconPositionModel>? progressive,
  }) {
    return CoverageIconsModel(
      centric: centric ?? this.centric,
      progressive: progressive ?? this.progressive,
    );
  }
}

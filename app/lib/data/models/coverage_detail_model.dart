import 'coverage_model.dart';
import 'coverage_icons_model.dart';

class CoverageDetailModel {
  final CoverageModel? percentage;
  final CoverageIconsModel? icons;

  const CoverageDetailModel({
    this.percentage,
    this.icons,
  });

  factory CoverageDetailModel.fromJson(Map<String, dynamic> json) {
    return CoverageDetailModel(
      percentage: json['percentage'] != null ? CoverageModel.fromJson(json['percentage']) : null,
      icons: json['icons'] != null ? CoverageIconsModel.fromJson(json['icons']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage?.toJson(),
      'icons': icons?.toJson(),
    };
  }

  CoverageDetailModel copyWith({
    CoverageModel? percentage,
    CoverageIconsModel? icons,
  }) {
    return CoverageDetailModel(
      percentage: percentage ?? this.percentage,
      icons: icons ?? this.icons,
    );
  }
}

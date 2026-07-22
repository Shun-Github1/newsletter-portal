import 'region_model.dart';

class RegionResponseModel {
  final List<RegionModel> regions;
  final List<String> selected;

  const RegionResponseModel({
    required this.regions,
    required this.selected,
  });

  factory RegionResponseModel.fromJson(Map<String, dynamic> json) {
    return RegionResponseModel(
      regions: (json['regions'] as List<dynamic>).map((e) => RegionModel.fromJson(e as Map<String, dynamic>)).toList(),
      selected: (json['selected'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regions': regions.map((e) => e.toJson()).toList(),
      'selected': selected,
    };
  }

  RegionResponseModel copyWith({
    List<RegionModel>? regions,
    List<String>? selected,
  }) {
    return RegionResponseModel(
      regions: regions ?? this.regions,
      selected: selected ?? this.selected,
    );
  }
}

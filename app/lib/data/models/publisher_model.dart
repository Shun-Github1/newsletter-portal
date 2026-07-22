import 'stance_model.dart';

class PublisherModel {
  final String? conglomerate;
  final String? controller;
  final int id;
  final String? intro;
  final String name;
  final String? region;
  final StanceModel? stance;
  final String? type;
  final String? website;

  const PublisherModel({
    this.conglomerate,
    this.controller,
    required this.id,
    this.intro,
    required this.name,
    this.region,
    this.stance,
    this.type,
    this.website,
  });

  factory PublisherModel.fromJson(Map<String, dynamic> json) {
    return PublisherModel(
      conglomerate: json['conglomerate'] as String?,
      controller: json['controller'] as String?,
      id: json['id'] as int,
      intro: json['intro'] as String?,
      name: json['name'] as String,
      region: json['region'] as String?,
      stance: json['stance'] != null ? StanceModel.fromJson(json['stance']) : null,
      type: json['type'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conglomerate': conglomerate,
      'controller': controller,
      'id': id,
      'intro': intro,
      'name': name,
      'region': region,
      'stance': stance?.toJson(),
      'type': type,
      'website': website,
    };
  }

  PublisherModel copyWith({
    String? conglomerate,
    String? controller,
    int? id,
    String? intro,
    String? name,
    String? region,
    StanceModel? stance,
    String? type,
    String? website,
  }) {
    return PublisherModel(
      conglomerate: conglomerate ?? this.conglomerate,
      controller: controller ?? this.controller,
      id: id ?? this.id,
      intro: intro ?? this.intro,
      name: name ?? this.name,
      region: region ?? this.region,
      stance: stance ?? this.stance,
      type: type ?? this.type,
      website: website ?? this.website,
    );
  }
}

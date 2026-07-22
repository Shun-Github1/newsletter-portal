import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:newsletter_portal/domain/entities/report_preset.dart';
import 'package:newsletter_portal/domain/entities/report_section.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';

class PresetLocalDatasource {
  static const String _boxName = 'report_presets';

  Future<Box<String>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return await Hive.openBox<String>(_boxName);
  }

  Future<List<ReportPreset>> loadAll() async {
    final box = await _getBox();
    final presets = <ReportPreset>[];
    for (final key in box.keys) {
      try {
        final json = jsonDecode(box.get(key)!) as Map<String, dynamic>;
        presets.add(_presetFromJson(json));
      } catch (_) {
        // Skip corrupted entries
      }
    }
    presets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return presets;
  }

  Future<void> save(ReportPreset preset) async {
    final box = await _getBox();
    await box.put(preset.id, jsonEncode(_presetToJson(preset)));
  }

  Future<void> delete(String presetId) async {
    final box = await _getBox();
    await box.delete(presetId);
  }

  Future<ReportPreset?> getById(String presetId) async {
    final box = await _getBox();
    final raw = box.get(presetId);
    if (raw == null) return null;
    return _presetFromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  // JSON serialization for Hive storage

  Map<String, dynamic> _presetToJson(ReportPreset preset) {
    return {
      'id': preset.id,
      'name': preset.name,
      'sections': preset.sections.map(_sectionToJson).toList(),
      'summaryMode': preset.summaryMode.name,
      'language': preset.language,
      'templateContent': preset.templateContent,
      'createdAt': preset.createdAt.toIso8601String(),
      'updatedAt': preset.updatedAt.toIso8601String(),
    };
  }

  ReportPreset _presetFromJson(Map<String, dynamic> json) {
    return ReportPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      sections: (json['sections'] as List)
          .map((s) => _sectionFromJson(s as Map<String, dynamic>))
          .toList(),
      summaryMode: json['summaryMode'] == 'paragraph' ? SummaryMode.paragraph : SummaryMode.pointForm,
      language: json['language'] as String? ?? 'en-UK',
      templateContent: json['templateContent'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _sectionToJson(ReportSection section) {
    return {
      'id': section.id,
      'title': section.title,
      'sectorWeights': section.sectorWeights.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'regionWeights': section.regionWeights,
      'tags': section.tags,
      'minItems': section.minItems,
      'maxItems': section.maxItems,
      'sentimentThreshold': section.sentimentThreshold,
    };
  }

  ReportSection _sectionFromJson(Map<String, dynamic> json) {
    return ReportSection(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Section',
      sectorWeights: (json['sectorWeights'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(int.parse(k), (v as num).toInt()),
      ),
      regionWeights: (json['regionWeights'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      tags: List<String>.from(json['tags'] as List? ?? []),
      minItems: (json['minItems'] as num?)?.toInt() ?? 1,
      maxItems: (json['maxItems'] as num?)?.toInt() ?? 10,
      sentimentThreshold: (json['sentimentThreshold'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

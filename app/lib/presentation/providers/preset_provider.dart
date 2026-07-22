import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';
import 'package:newsletter_portal/domain/entities/report_preset.dart';

import 'package:newsletter_portal/domain/entities/report_section.dart';

class PresetNotifier extends StateNotifier<List<ReportPreset>> {
  PresetNotifier() : super([]) {
    _initDefaults();
  }

  void _initDefaults() {
    final defaultPreset = ReportPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Default Preset',
      sections: [
        ReportSection(
          id: 'section-1',
          title: 'New Section 1',
          sectorWeights: const {},
          regionWeights: const {},
          tags: const [],
          minItems: 1,
          maxItems: 10,
          sentimentThreshold: 0.0,
        ),
      ],
      summaryMode: SummaryMode.pointForm,
      language: 'en-UK',
      templateContent: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [defaultPreset];
  }

  Future<void> loadAll() async {
    // In a real app, read from Hive box here
  }

  Future<void> create(ReportPreset preset) async {
    state = [...state, preset];
    // Save to Hive
  }

  Future<void> update(ReportPreset preset) async {
    state = state.map((p) => p.id == preset.id ? preset : p).toList();
    // Save to Hive
  }

  Future<void> delete(String id) async {
    state = state.where((p) => p.id != id).toList();
    // Save to Hive
  }

  Future<void> duplicate(String id) async {
    final toDuplicate = state.firstWhere((p) => p.id == id);
    final duplicated = toDuplicate.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${toDuplicate.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [...state, duplicated];
    // Save to Hive
  }
}

final presetListProvider = StateNotifierProvider<PresetNotifier, List<ReportPreset>>((ref) {
  return PresetNotifier()..loadAll();
});

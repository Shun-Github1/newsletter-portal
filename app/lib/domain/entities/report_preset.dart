import 'package:newsletter_portal/core/constants/api_constants.dart';
import 'package:newsletter_portal/domain/entities/report_section.dart';

class ReportPreset {
  final String id;
  final String name;
  final List<ReportSection> sections;
  final SummaryMode summaryMode;
  final String language;
  final String templateContent;
  final String tier1Template;
  final String tier2Template;
  final String tier3Template;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportPreset({
    required this.id,
    required this.name,
    required this.sections,
    required this.summaryMode,
    required this.language,
    required this.templateContent,
    this.tier1Template = '[DOCUMENT_TITLE] - [DATE]\nLANGUAGE: [LANGUAGE] | MODE: [SUMMARY_MODE]',
    this.tier2Template = 'SECTION [SECTION_NUMBER]: [SECTION_TITLE]\nTAGS: [SECTION_TAGS]',
    this.tier3Template = '[ARTICLE_TITLE] [SRC_COUNT]\n[DATE] | [REGION] | [SECTOR] | SENT: [SENTIMENT]\n[SYNOPSIS]',
    required this.createdAt,
    required this.updatedAt,
  });

  ReportPreset copyWith({
    String? id,
    String? name,
    List<ReportSection>? sections,
    SummaryMode? summaryMode,
    String? language,
    String? templateContent,
    String? tier1Template,
    String? tier2Template,
    String? tier3Template,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      sections: sections ?? this.sections,
      summaryMode: summaryMode ?? this.summaryMode,
      language: language ?? this.language,
      templateContent: templateContent ?? this.templateContent,
      tier1Template: tier1Template ?? this.tier1Template,
      tier2Template: tier2Template ?? this.tier2Template,
      tier3Template: tier3Template ?? this.tier3Template,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/presentation/widgets/section_config_card.dart';
import 'package:newsletter_portal/presentation/widgets/app_icon_button.dart';
import 'package:newsletter_portal/presentation/providers/report_provider.dart';
import 'package:newsletter_portal/presentation/providers/auth_provider.dart';
import 'package:newsletter_portal/presentation/providers/preset_provider.dart';
import 'package:newsletter_portal/domain/entities/report_section.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';

class ReportCustomizationView extends ConsumerStatefulWidget {
  const ReportCustomizationView({super.key});

  @override
  ConsumerState<ReportCustomizationView> createState() => _ReportCustomizationViewState();
}

class _ReportCustomizationViewState extends ConsumerState<ReportCustomizationView> {
  bool _isTemplateExpanded = false;
  late TextEditingController _docTitleController;

  // Active element sequences for Tier 1, Tier 2, and Tier 3 (Unified +/- Builders)
  List<String> _tier1Elements = [
    '[DOCUMENT_TITLE]',
    '[DATE]',
    '[LINE_BREAK]',
    '[LANGUAGE]',
    '[SUMMARY_MODE]',
    '[TOTAL_ARTICLES]',
  ];

  List<String> _tier2Elements = [
    '[SECTION_NUMBER]',
    '[SECTION_TITLE]',
    '[LINE_BREAK]',
    '[SECTION_TAGS]',
  ];

  List<String> _tier3Elements = [
    '[ARTICLE_TITLE]',
    '[SRC_COUNT]',
    '[LINE_BREAK]',
    '[DATE]',
    '[REGION]',
    '[SECTOR]',
    '[SENTIMENT]',
    '[LINE_BREAK]',
    '[SYNOPSIS]',
  ];

  @override
  void initState() {
    super.initState();
    final activePreset = ref.read(reportStateProvider).activePreset;
    _docTitleController = TextEditingController(
      text: activePreset?.name ?? 'APAC MEDIA MONITORING REPORT',
    );
  }

  @override
  void dispose() {
    _docTitleController.dispose();
    super.dispose();
  }

  String _buildTemplateString(List<String> elements) {
    List<String> lines = [];
    List<String> currentLine = [];

    for (final elem in elements) {
      if (elem == '[LINE_BREAK]') {
        lines.add(currentLine.join(' '));
        currentLine = [];
      } else {
        currentLine.add(elem);
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine.join(' '));
    }
    return lines.join('\n');
  }

  void _onTemplatesChanged() {
    // Update active preset title & template structures
    final activePreset = ref.read(reportStateProvider).activePreset;
    if (activePreset != null && _docTitleController.text.trim().isNotEmpty) {
      final updated = activePreset.copyWith(name: _docTitleController.text.trim());
      ref.read(reportStateProvider.notifier).loadPreset(updated);
    }

    ref.read(reportStateProvider.notifier).updateTemplates(
      tier1: _buildTemplateString(_tier1Elements),
      tier2: _buildTemplateString(_tier2Elements),
      tier3: _buildTemplateString(_tier3Elements),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportStateProvider);
    final activePreset = reportState.activePreset;
    final sections = activePreset?.sections ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopBar(context),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              _build3TierTemplateArea(),
              const SizedBox(height: AppSpacing.lg),
              _buildFormatSection(activePreset?.summaryMode, activePreset?.language),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Sections',
                style: AppTypography.panelTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              ...sections.map((section) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SectionConfigCard(
                      section: section,
                      availableTags: ref.watch(allTopicsProvider).maybeWhen(
                        data: (topics) => topics,
                        orElse: () => const [],
                      ),
                      onUpdate: (updated) {
                        ref.read(reportStateProvider.notifier).updateSection(section.id, updated);
                      },
                      onDelete: () {
                        ref.read(reportStateProvider.notifier).removeSection(section.id);
                      },
                    ),
                  )),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () {
                  final newSection = ReportSection(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: 'New Section ${sections.length + 1}',
                    sectorWeights: const {},
                    regionWeights: const {},
                    tags: const [],
                    minItems: 1,
                    maxItems: 10,
                    sentimentThreshold: 0.0,
                  );
                  ref.read(reportStateProvider.notifier).addSection(newSection);
                },
                icon: Icon(Icons.add, color: AppColors.of(context).textPrimary),
                label: Text('Add Section', style: AppTypography.labelLarge.copyWith(color: AppColors.of(context).textPrimary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.of(context).border),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          Text(
            'Report Configuration',
            style: AppTypography.pageTitle,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  final activePreset = ref.read(reportStateProvider).activePreset;
                  if (activePreset != null) {
                    ref.read(presetListProvider.notifier).update(activePreset);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Preset "${activePreset.name}" saved successfully!', style: AppTypography.monoSmall),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.of(context).surface,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.save_outlined, size: 16, color: AppColors.of(context).textPrimary),
                label: Text('Save preset', style: AppTypography.labelMedium.copyWith(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.of(context).border),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: () {
                  ref.read(reportStateProvider.notifier).proceedToSelection();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: Text('Select articles', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.onAccent)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSection(SummaryMode? currentMode, String? currentLanguage) {
    final mode = currentMode ?? SummaryMode.pointForm;
    final language = currentLanguage ?? 'en-UK';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Format',
          style: AppTypography.panelTitle,
        ),
        const SizedBox(height: AppSpacing.md),

        // Summary Mode Selector
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Text('Summary:', style: AppTypography.bodySmall),
            ),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSelectChip(
                    label: 'Point Form',
                    selected: mode == SummaryMode.pointForm,
                    onTap: () {
                      ref.read(reportStateProvider.notifier).updateGlobalSettings(SummaryMode.pointForm, language);
                    },
                  ),
                  _buildSelectChip(
                    label: 'Paragraph',
                    selected: mode == SummaryMode.paragraph,
                    onTap: () {
                      ref.read(reportStateProvider.notifier).updateGlobalSettings(SummaryMode.paragraph, language);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Language Selector
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Text('Language:', style: AppTypography.bodySmall),
            ),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSelectChip(
                    label: 'English (UK)',
                    selected: language == 'en-UK',
                    onTap: () {
                      ref.read(reportStateProvider.notifier).updateGlobalSettings(mode, 'en-UK');
                    },
                  ),
                  _buildSelectChip(
                    label: 'Traditional Chinese',
                    selected: language == 'zh-HK',
                    onTap: () {
                      ref.read(reportStateProvider.notifier).updateGlobalSettings(mode, 'zh-HK');
                    },
                  ),
                  _buildSelectChip(
                    label: 'Simplified Chinese',
                    selected: language == 'zh-CN',
                    onTap: () {
                      ref.read(reportStateProvider.notifier).updateGlobalSettings(mode, 'zh-CN');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? colors.surfaceHover : colors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: selected ? colors.textPrimary : Colors.transparent,
            ),
          ),
          child: Text(label, style: AppTypography.labelMedium),
        ),
      ),
    );
  }

  /// 3-Tier Interactive Template Editor Component
  Widget _build3TierTemplateArea() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isTemplateExpanded = !_isTemplateExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppIcon(Icons.description, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Template Editor', style: AppTypography.panelTitle),
                    ],
                  ),
                  AppIcon(
                    _isTemplateExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (_isTemplateExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TIER 1: Document Level Header Builder with Inline Document Title Input Box
                  _buildTier1SequenceBuilderBox(),
                  const SizedBox(height: AppSpacing.lg),

                  // TIER 2: Section Level Header Builder (No Text Box! +/- Fixed Elements + Line Break)
                  _buildSequenceBuilderBox(
                    tierTitle: 'Tier 2: Section Header Format Builder',
                    tierSubtitle: 'Add/remove fixed section elements and line breaks (No text box).',
                    elements: _tier2Elements,
                    availableElements: const [
                      '[SECTION_NUMBER]',
                      '[SECTION_TITLE]',
                      '[SECTION_TAGS]',
                      '[ITEM_COUNT]',
                      '[RELEVANCE_CUTOFF]',
                    ],
                    onElementsChanged: (newElemList) {
                      setState(() => _tier2Elements = newElemList);
                      _onTemplatesChanged();
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // TIER 3: Article Info Builder (No Text Box! +/- Fixed Elements + Line Break)
                  _buildSequenceBuilderBox(
                    tierTitle: 'Tier 3: News Item Info Format Builder',
                    tierSubtitle: 'Add/remove fixed article datafields and line breaks per news item.',
                    elements: _tier3Elements,
                    availableElements: const [
                      '[ARTICLE_TITLE]',
                      '[SRC_COUNT]',
                      '[DATE]',
                      '[REGION]',
                      '[SECTOR]',
                      '[SENTIMENT]',
                      '[SUBJECTIVITY]',
                      '[SYNOPSIS]',
                    ],
                    onElementsChanged: (newElemList) {
                      setState(() => _tier3Elements = newElemList);
                      _onTemplatesChanged();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// TIER 1 Builder: Sequence Builder + Inline Document Title Input Box
  Widget _buildTier1SequenceBuilderBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tier 1: Document Header Format Builder', style: AppTypography.sectionTitle.copyWith(color: AppColors.of(context).textPrimary)),
          const SizedBox(height: 2),
          Text('Configure document title text and top-level header metadata format.', style: AppTypography.monoTiny.copyWith(color: AppColors.of(context).textSecondary)),
          const SizedBox(height: AppSpacing.md),

          // Inline Document Title Input Field
          Row(
            children: [
              Text('[DOCUMENT_TITLE] Text:', style: AppTypography.monoSmall.copyWith(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _docTitleController,
                  onChanged: (_) => _onTemplatesChanged(),
                  style: AppTypography.monoMedium.copyWith(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'e.g. APAC MEDIA MONITORING REPORT',
                    hintStyle: AppTypography.monoSmall.copyWith(color: AppColors.of(context).textTertiary),
                    filled: true,
                    fillColor: AppColors.of(context).surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: AppColors.of(context).border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: AppColors.of(context).border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: AppColors.of(context).textPrimary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Tier 1 Sequence Builder
          _buildSequenceBuilderInner(
            tierTitle: 'Tier 1 Document Header Format',
            elements: _tier1Elements,
            availableElements: const [
              '[DOCUMENT_TITLE]',
              '[DATE]',
              '[LANGUAGE]',
              '[SUMMARY_MODE]',
              '[TOTAL_ARTICLES]',
            ],
            onElementsChanged: (newElemList) {
              setState(() => _tier1Elements = newElemList);
              _onTemplatesChanged();
            },
          ),
        ],
      ),
    );
  }

  /// TIER 2 & TIER 3: Fixed Element Sequence Builder Box (No Text Box! +/- & Line Breaks)
  Widget _buildSequenceBuilderBox({
    required String tierTitle,
    required String tierSubtitle,
    required List<String> elements,
    required List<String> availableElements,
    required Function(List<String>) onElementsChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tierTitle, style: AppTypography.sectionTitle.copyWith(color: AppColors.of(context).textPrimary)),
          const SizedBox(height: 2),
          Text(tierSubtitle, style: AppTypography.monoTiny.copyWith(color: AppColors.of(context).textSecondary)),
          const SizedBox(height: AppSpacing.md),
          _buildSequenceBuilderInner(
            tierTitle: tierTitle,
            elements: elements,
            availableElements: availableElements,
            onElementsChanged: onElementsChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceBuilderInner({
    required String tierTitle,
    required List<String> elements,
    required List<String> availableElements,
    required Function(List<String>) onElementsChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Elements Sequence Display (With '-' remove controls)
        Text('Active Format Sequence:', style: AppTypography.monoTiny.copyWith(color: AppColors.of(context).textSecondary)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.of(context).surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: elements.isEmpty
              ? Text('No elements added. Click "+" below to add elements.', style: AppTypography.monoTiny.copyWith(color: AppColors.of(context).textTertiary))
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: List.generate(elements.length, (idx) {
                    final item = elements[idx];
                    final isLineBreak = item == '[LINE_BREAK]';

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLineBreak ? Color(0xFFFCF3E6) : AppColors.of(context).surfaceHover,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLineBreak ? '⏎ LINE BREAK' : item,
                            style: AppTypography.monoTiny.copyWith(
                              color: isLineBreak ? AppColors.warning : AppColors.of(context).textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              final updated = List<String>.from(elements)..removeAt(idx);
                              onElementsChanged(updated);
                            },
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: isLineBreak ? AppColors.warning : AppColors.of(context).textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Available Elements Bar (With '+' Add controls and '+ LINE BREAK')
        Text('Available Fixed Elements & Line Breaks:', style: AppTypography.monoTiny.copyWith(color: AppColors.of(context).textSecondary)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...availableElements.map((elem) {
              return InkWell(
                onTap: () {
                  final updated = List<String>.from(elements)..add(elem);
                  onElementsChanged(updated);
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).surfaceHover,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 12, color: AppColors.of(context).textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        elem,
                        style: AppTypography.monoTiny.copyWith(
                          color: AppColors.of(context).textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Explicit + LINE BREAK Button
            InkWell(
              onTap: () {
                final updated = List<String>.from(elements)..add('[LINE_BREAK]');
                onElementsChanged(updated);
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF3E6),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 12, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '⏎ LINE BREAK',
                      style: AppTypography.monoTiny.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    if (tierTitle.contains('Tier 1')) {
                      _tier1Elements = ['[DOCUMENT_TITLE]', '[LINE_BREAK]', '[DATE]', '[LANGUAGE]', '[SUMMARY_MODE]', '[TOTAL_ARTICLES]'];
                    } else if (tierTitle.contains('Tier 2')) {
                      _tier2Elements = ['[SECTION_NUMBER]', '[SECTION_TITLE]', '[LINE_BREAK]', '[SECTION_TAGS]', '[ITEM_COUNT]', '[RELEVANCE_CUTOFF]'];
                    } else {
                      _tier3Elements = ['[ARTICLE_TITLE]', '[SRC_COUNT]', '[LINE_BREAK]', '[DATE]', '[REGION]', '[SECTOR]', '[SENTIMENT]', '[SUBJECTIVITY]', '[LINE_BREAK]', '[SYNOPSIS]'];
                    }
                  });
                  _onTemplatesChanged();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$tierTitle format reset to default!', style: AppTypography.monoSmall),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.of(context).surface,
                    ),
                  );
                },
                icon: Icon(Icons.refresh, size: 12, color: AppColors.of(context).textSecondary),
                label: Text('Reset', style: AppTypography.monoTiny.copyWith(fontWeight: FontWeight.bold, color: AppColors.of(context).textSecondary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.of(context).border),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              ElevatedButton.icon(
                onPressed: () {
                  _onTemplatesChanged();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tier format saved!', style: AppTypography.monoSmall),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.of(context).surface,
                    ),
                  );
                },
                icon: const Icon(Icons.check, size: 12, color: AppColors.onAccent),
                label: Text('Save format', style: AppTypography.monoTiny.copyWith(fontWeight: FontWeight.bold, color: AppColors.onAccent)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

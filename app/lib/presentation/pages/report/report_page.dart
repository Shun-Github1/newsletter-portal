import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';
import 'package:newsletter_portal/presentation/widgets/compact_top_bar.dart';
import 'package:newsletter_portal/presentation/widgets/sidebar_resize_handle.dart';
import 'package:newsletter_portal/presentation/widgets/sidebar_preset_list.dart';
import 'package:newsletter_portal/presentation/providers/report_provider.dart';
import 'package:newsletter_portal/presentation/providers/preset_provider.dart';
import 'package:newsletter_portal/domain/entities/report_preset.dart';

import 'package:newsletter_portal/presentation/widgets/app_icon_button.dart';
import 'customization/report_customization_view.dart';
import 'selection/article_selection_view.dart';
import 'preview/report_preview_view.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  bool _isLeftOpen = true;
  bool _isRightOpen = true;
  double _leftWidth = 220.0;
  double _rightWidth = 320.0;

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportStateProvider);
    final presetState = ref.watch(presetListProvider);

    if (reportState.activePreset == null && presetState.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ref.read(reportStateProvider).activePreset == null) {
          ref.read(reportStateProvider.notifier).loadPreset(presetState.first);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: Column(
        children: [
          // Compact Top Bar
          CompactTopBar(
            activeRoute: '/report',
            isLeftSidebarOpen: _isLeftOpen,
            isRightSidebarOpen: _isRightOpen,
            onToggleLeftSidebar: () => setState(() => _isLeftOpen = !_isLeftOpen),
            onToggleRightSidebar: () => setState(() => _isRightOpen = !_isRightOpen),
            onRefresh: () {
              final activePreset = reportState.activePreset;
              if (activePreset != null) {
                ref.read(reportStateProvider.notifier).loadPreset(activePreset);
              }
            },
          ),

          // Main Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Presets Sidebar
                if (_isLeftOpen) ...[
                  SizedBox(
                    width: _leftWidth,
                    child: _buildSidebar(context, ref, presetState, reportState),
                  ),
                  SidebarResizeHandle(
                    onDrag: (delta) {
                      setState(() {
                        _leftWidth = (_leftWidth + delta).clamp(150.0, 400.0);
                      });
                    },
                  ),
                ],

                // Central Workspace View (Instant, no animation)
                Expanded(
                  child: _buildCenterPanel(reportState),
                ),

                // Right Customization / Live Section Preview Panel (Available on all steps)
                if (_isRightOpen) ...[
                  SidebarResizeHandle(
                    isRight: true,
                    onDrag: (delta) {
                      setState(() {
                        _rightWidth = (_rightWidth + delta).clamp(220.0, 500.0);
                      });
                    },
                  ),
                  SizedBox(
                    width: _rightWidth,
                    child: _buildRightPanel(context, reportState),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    WidgetRef ref,
    List<ReportPreset> presetState,
    ReportState reportState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).sidebar,
      ),
      child: SidebarPresetList(
        presets: presetState,
        activePresetId: reportState.activePreset?.id,
        onSelect: (id) {
          final preset = presetState.firstWhere((p) => p.id == id);
          ref.read(reportStateProvider.notifier).loadPreset(preset);
        },
        onAdd: () {
          final newPreset = ReportPreset(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'New Preset',
            sections: [],
            summaryMode: SummaryMode.paragraph,
            language: 'en-UK',
            templateContent: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          ref.read(presetListProvider.notifier).create(newPreset);
          ref.read(reportStateProvider.notifier).loadPreset(newPreset);
        },
        onDelete: (id) {
          ref.read(presetListProvider.notifier).delete(id);
        },
        onRename: (id, newName) {
          final preset = presetState.firstWhere((p) => p.id == id);
          final updated = preset.copyWith(name: newName, updatedAt: DateTime.now());
          ref.read(presetListProvider.notifier).update(updated);
          if (reportState.activePreset?.id == id) {
            ref.read(reportStateProvider.notifier).loadPreset(updated);
          }
        },
      ),
    );
  }

  Widget _buildCenterPanel(ReportState reportState) {
    switch (reportState.currentStep) {
      case ReportStep.customization:
        return const ReportCustomizationView(key: ValueKey('customization'));
      case ReportStep.selection:
        return const ArticleSelectionView(key: ValueKey('selection'));
      case ReportStep.preview:
        return const ReportPreviewView(key: ValueKey('preview'));
    }
  }

  Widget _buildRightPanel(BuildContext context, ReportState reportState) {
    final activePreset = reportState.activePreset;
    final sections = activePreset?.sections ?? [];
    final previewArticles = reportState.previewArticles;
    final isLoading = reportState.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).sidebar,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live section preview',
                      style: AppTypography.panelTitle.copyWith(
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time articles per section',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.of(context).textTertiary),
                    ),
                  ],
                ),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.of(context).accent),
                    ),
                  )
                else
                  AppIconButton(
                    icon: Icons.refresh,
                    size: 16,
                    onPressed: () {
                      ref.read(reportStateProvider.notifier).refreshPreview();
                    },
                    tooltip: 'Refresh preview',
                  ),
              ],
            ),
          ),

          // Section-by-Section Cards List
          Expanded(
            child: sections.isEmpty
                ? Center(
                    child: Text('No sections configured', style: AppTypography.bodySmall.copyWith(color: AppColors.of(context).textTertiary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    itemCount: sections.length,
                    itemBuilder: (context, idx) {
                      final section = sections[idx];
                      final matchedArticles = previewArticles[section.id] ?? [];
                      final rawTier3 = activePreset?.tier3Template ?? '[ARTICLE_TITLE] [SRC_COUNT]\n[DATE] | [REGION] | [SECTOR] | SENT: [SENTIMENT]\n[SYNOPSIS]';

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.of(context).surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Card Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${idx + 1}. ${section.title}',
                                    style: AppTypography.sectionTitle.copyWith(
                                      color: AppColors.of(context).textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: matchedArticles.isNotEmpty ? AppColors.of(context).surfaceHover : Color(0xFFFDECEA),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    '${matchedArticles.length} MATCHED',
                                    style: AppTypography.monoTiny.copyWith(
                                      color: matchedArticles.isNotEmpty ? AppColors.of(context).textSecondary : AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tags: ${section.tags.isEmpty ? "ALL" : section.tags.join(", ")} | Cutoff: ${section.sentimentThreshold.toStringAsFixed(2)}',
                              style: AppTypography.monoTiny.copyWith(color: AppColors.of(context).textTertiary),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Preview Items List
                            if (matchedArticles.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'No articles match section filters.',
                                  style: AppTypography.monoTiny.copyWith(color: AppColors.of(context).textTertiary),
                                ),
                              )
                            else
                              ...matchedArticles.take(3).map((article) {
                                final titleStr = article.title;
                                final srcStr = article.sourceCount != null ? '[SRC: ${article.sourceCount}]' : '';
                                final dateStr = article.date.toString().split(' ')[0];
                                final regStr = (article.region ?? 'GLOBAL').toString().toUpperCase();
                                final secStr = (article.sector ?? 'GENERAL').toString().toUpperCase();
                                final sentVal = article.sentimentScore;
                                final sentStr = sentVal != null ? '${sentVal >= 0 ? "+" : ""}${sentVal.toStringAsFixed(2)}' : '';
                                final subjVal = article.subjectivityScore;
                                final subjStr = subjVal != null ? subjVal.toStringAsFixed(2) : '';
                                final synStr = article.synopsis ?? '';

                                final renderedItem = rawTier3
                                    .replaceAll('[ARTICLE_TITLE]', titleStr)
                                    .replaceAll('[SRC_COUNT]', srcStr)
                                    .replaceAll('[DATE]', dateStr)
                                    .replaceAll('[REGION]', regStr)
                                    .replaceAll('[SECTOR]', secStr)
                                    .replaceAll('[SENTIMENT]', sentStr)
                                    .replaceAll('[SUBJECTIVITY]', subjStr)
                                    .replaceAll('[SYNOPSIS]', synStr);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.of(context).surfaceVariant,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    renderedItem,
                                    style: AppTypography.monoTiny.copyWith(color: AppColors.of(context).textSecondary, fontSize: 10),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


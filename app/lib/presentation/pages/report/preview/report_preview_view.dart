import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/presentation/widgets/app_icon_button.dart';
import 'package:newsletter_portal/presentation/providers/report_provider.dart';
import 'package:newsletter_portal/domain/entities/report_preset.dart';
import 'package:newsletter_portal/domain/entities/article.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';

/// Clean Plain Text Document Report Preview View (No UI Cards)
class ReportPreviewView extends ConsumerStatefulWidget {
  const ReportPreviewView({super.key});

  @override
  ConsumerState<ReportPreviewView> createState() => _ReportPreviewViewState();
}

class _ReportPreviewViewState extends ConsumerState<ReportPreviewView> {
  bool _isMonospace = true;

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportStateProvider);
    final activePreset = reportState.activePreset;
    final previewArticles = reportState.previewArticles;
    final selectedArticleIds = reportState.selectedArticleIds;

    // Generate the exact full plain text report from 3-tier rules
    final fullDocumentText = _compilePlainTestDocument(
      activePreset,
      previewArticles,
      selectedArticleIds,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopBar(context, fullDocumentText),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DOCUMENT TYPE: INTELLIGENCE REPORT',
                          style: AppTypography.monoTiny.copyWith(color: AppColors.of(context).textSecondary, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'CONFIDENTIAL / FOR INTERNAL USE ONLY',
                          style: AppTypography.monoTiny.copyWith(color: AppColors.of(context).textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SelectableText(
                      fullDocumentText,
                      style: TextStyle(
                        fontFamily: _isMonospace ? 'monospace' : 'Roboto',
                        fontSize: 13,
                        height: 1.6,
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, String fullDocumentText) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          SizedBox(
            height: 32,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIconButton(
                  icon: Icons.arrow_back,
                  size: 20,
                  onPressed: () {
                    ref.read(reportStateProvider.notifier).proceedToSelection();
                  },
                  tooltip: 'Back to Article Selection',
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Report Preview',
                  style: AppTypography.pageTitle,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle Font Mode
              AppIconButton(
                icon: _isMonospace ? Icons.font_download : Icons.font_download_outlined,
                size: 20,
                active: _isMonospace,
                onPressed: () {
                  setState(() {
                    _isMonospace = !_isMonospace;
                  });
                },
                tooltip: _isMonospace ? 'Switch to Proportional Font' : 'Switch to Monospace Font',
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: fullDocumentText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Plain text document copied to clipboard!'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.of(context).surface,
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 16, color: AppColors.onAccent),
                label: Text('Copy text', style: AppTypography.labelMedium.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Master compiler that builds the continuous Plain Text Document string
  String _compilePlainTestDocument(
    ReportPreset? activePreset,
    Map<String, List<Article>> previewArticles,
    Map<String, Set<String>> selectedArticleIds,
  ) {
    if (activePreset == null) return 'No active preset selected.';

    final buffer = StringBuffer();

    // 1. TIER 1: Document Header
    final docTitle = activePreset.name;
    final dateStr = DateTime.now().toString().split('.')[0];
    final langStr = activePreset.language;
    final modeStr = activePreset.summaryMode == SummaryMode.pointForm ? 'POINT FORM' : 'PARAGRAPH';

    // Calculate total count
    int totalCount = 0;
    for (final set in selectedArticleIds.values) {
      totalCount += set.length;
    }
    if (totalCount == 0) {
      for (final list in previewArticles.values) {
        totalCount += list.length;
      }
    }

    final rawTier1 = activePreset.tier1Template;
    buffer.writeln(
      rawTier1
          .replaceAll('[DOCUMENT_TITLE]', docTitle.toUpperCase())
          .replaceAll('[DATE]', dateStr)
          .replaceAll('[LANGUAGE]', langStr.toUpperCase())
          .replaceAll('[SUMMARY_MODE]', modeStr)
          .replaceAll('[TOTAL_ARTICLES]', '$totalCount'),
    );
    buffer.writeln();
    buffer.writeln('================================================================================');
    buffer.writeln();

    // 2. TIER 2 & TIER 3: Sections & Articles
    for (int i = 0; i < activePreset.sections.length; i++) {
      final section = activePreset.sections[i];
      final rawTier2 = activePreset.tier2Template;
      final rawTier3 = activePreset.tier3Template;

      final tagsStr = section.tags.isEmpty ? 'ALL' : section.tags.join(', ');
      
      // Render Tier 2 Section Header
      buffer.writeln(
        rawTier2
            .replaceAll('[SECTION_NUMBER]', '${i + 1}')
            .replaceAll('[SECTION_TITLE]', section.title.toUpperCase())
            .replaceAll('[SECTION_TAGS]', tagsStr)
            .replaceAll('[ITEM_COUNT]', 'MIN ${section.minItems} - MAX ${section.maxItems}')
            .replaceAll('[RELEVANCE_CUTOFF]', section.sentimentThreshold.toStringAsFixed(2)),
      );
      buffer.writeln();

      // Retrieve matched/selected articles
      final allSectionArticles = previewArticles[section.id] ?? [];
      final selectedIds = selectedArticleIds[section.id] ?? {};
      final articles = selectedIds.isNotEmpty
          ? allSectionArticles.where((a) => selectedIds.contains(a.id)).toList()
          : allSectionArticles;

      if (articles.isEmpty) {
        buffer.writeln('  [ No articles available for this section ]\n');
      } else {
        for (final article in articles) {
          final titleStr = article.title;
          final srcStr = article.sourceCount != null ? '[SRC: ${article.sourceCount}]' : '[SRC: 1]';
          final dateStr = article.date.toString().split(' ')[0];
          final regStr = (article.region ?? 'GLOBAL').toUpperCase();
          final secStr = (article.sector ?? 'GENERAL').toUpperCase();
          final sentVal = article.sentimentScore;
          final sentStr = sentVal != null ? '${sentVal >= 0 ? "+" : ""}${sentVal.toStringAsFixed(2)}' : '+0.00';
          final subjVal = article.subjectivityScore;
          final subjStr = subjVal != null ? subjVal.toStringAsFixed(2) : '0.00';
          
          // Full summary text (synopsis/implications or article title)
          final synStr = (article.synopsis != null && article.synopsis!.trim().isNotEmpty)
              ? article.synopsis!.trim()
              : (article.implications != null && article.implications!.trim().isNotEmpty)
                  ? 'Implications: ${article.implications!.trim()}'
                  : article.title;

          // Render Tier 3 News Item
          buffer.writeln(
            rawTier3
                .replaceAll('[ARTICLE_TITLE]', titleStr)
                .replaceAll('[SRC_COUNT]', srcStr)
                .replaceAll('[DATE]', dateStr)
                .replaceAll('[REGION]', regStr)
                .replaceAll('[SECTOR]', secStr)
                .replaceAll('[SENTIMENT]', sentStr)
                .replaceAll('[SUBJECTIVITY]', subjStr)
                .replaceAll('[SYNOPSIS]', synStr),
          );
          buffer.writeln();
        }
      }
      buffer.writeln('--------------------------------------------------------------------------------');
      buffer.writeln();
    }

    buffer.writeln('[ END OF DOCUMENT ]');
    return buffer.toString();
  }
}

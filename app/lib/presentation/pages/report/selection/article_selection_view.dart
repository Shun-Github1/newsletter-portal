import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/presentation/widgets/glass_panel.dart';
import 'package:newsletter_portal/presentation/widgets/article_card.dart';
import 'package:newsletter_portal/presentation/providers/report_provider.dart';

class ArticleSelectionView extends ConsumerWidget {
  const ArticleSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportStateProvider);
    final previewArticles = reportState.previewArticles;
    
    // Calculate total selected articles across all sections
    final selectedCount = reportState.selectedArticleIds.values.fold(0, (sum, set) => sum + set.length);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(context, ref, selectedCount),
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: previewArticles.length,
                itemBuilder: (context, index) {
                  final sectionId = previewArticles.keys.elementAt(index);
                  final articles = previewArticles[sectionId] ?? [];
                  
                  // Find section name from active preset
                  final matchingSections = (reportState.activePreset?.sections ?? []).where((s) => s.id == sectionId);
                  final section = matchingSections.isNotEmpty ? matchingSections.first : null;
                  final sectionName = section?.title ?? 'Section ${index + 1}';

                  return _SectionPanel(
                    sectionName: sectionName,
                    articles: articles,
                    selectedIds: reportState.selectedArticleIds[sectionId] ?? {},
                    onToggleArticle: (articleId) {
                      ref.read(reportStateProvider.notifier).toggleArticle(sectionId, articleId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, int selectedCount) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.accent, size: 20),
                onPressed: () {
                  ref.read(reportStateProvider.notifier).goBack();
                },
                tooltip: 'Back to Configuration',
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Article Selection',
                style: AppTypography.titleLarge,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$selectedCount Selected',
                  style: AppTypography.monoSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: () {
                  ref.read(reportStateProvider.notifier).proceedToPreview();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: const Color(0xFF0D0D0D),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text('Preview Report →', style: AppTypography.monoSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.background)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionPanel extends StatefulWidget {
  final String sectionName;
  final List articles;
  final Set<String> selectedIds;
  final Function(String) onToggleArticle;

  const _SectionPanel({
    required this.sectionName,
    required this.articles,
    required this.selectedIds,
    required this.onToggleArticle,
  });

  @override
  State<_SectionPanel> createState() => _SectionPanelState();
}

class _SectionPanelState extends State<_SectionPanel> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final sectionSelectedCount = widget.articles.where((a) => widget.selectedIds.contains(a.id)).length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.sectionName} ($sectionSelectedCount/${widget.articles.length} selected)',
                    style: AppTypography.titleMedium,
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  ...widget.articles.map((article) {
                    final isSelected = widget.selectedIds.contains(article.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => widget.onToggleArticle(article.id),
                            activeColor: AppColors.accent,
                            checkColor: AppColors.background,
                          ),
                          Expanded(
                            child: ArticleCard(article: article),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

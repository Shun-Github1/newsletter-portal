import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/presentation/widgets/article_card.dart';
import 'package:newsletter_portal/presentation/widgets/app_icon_button.dart';
import 'package:newsletter_portal/presentation/providers/report_provider.dart';

class ArticleSelectionView extends ConsumerWidget {
  const ArticleSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportStateProvider);
    final previewArticles = reportState.previewArticles;
    
    // Calculate total selected articles across all sections
    final selectedCount = reportState.selectedArticleIds.values.fold(0, (sum, set) => sum + set.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopBar(context, ref, selectedCount),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
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
              AppIconButton(
                icon: Icons.arrow_back,
                size: 20,
                onPressed: () {
                  ref.read(reportStateProvider.notifier).goBack();
                },
                tooltip: 'Back to Configuration',
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Article Selection',
                style: AppTypography.pageTitle,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.of(context).surfaceHover,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$selectedCount Selected',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: () {
                  ref.read(reportStateProvider.notifier).proceedToPreview();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: Text('Preview report', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.onAccent)),
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
        color: AppColors.of(context).surfaceVariant,
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
                    style: AppTypography.sectionTitle.copyWith(
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                  AppIcon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
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
                            activeColor: AppColors.of(context).textPrimary,
                            checkColor: AppColors.onAccent,
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
      ),
    );
  }
}

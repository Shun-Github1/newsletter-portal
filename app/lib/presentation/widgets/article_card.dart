import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/domain/entities/article.dart';
import 'package:newsletter_portal/presentation/widgets/glass_panel.dart';
import 'package:newsletter_portal/presentation/widgets/sentiment_indicator.dart';
import 'package:intl/intl.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final bool showCheckbox;
  final bool isSelected;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.showCheckbox = false,
    this.isSelected = false,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? onToggle,
      child: GlassPanelHover(
        padding: const EdgeInsets.all(AppSpacing.md),
        isSelected: isSelected,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCheckbox) ...[
              Checkbox(
                value: isSelected,
                onChanged: (val) => onToggle?.call(),
                activeColor: AppColors.of(context).textPrimary,
                checkColor: Colors.white,
                side: BorderSide(color: AppColors.of(context).border),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SentimentDot(sentiment: article.sentimentScore ?? 0.0),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        article.sourceCount != null ? 'SRC: ${article.sourceCount}' : 'Newsletter',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '•',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat('MMM d, yyyy').format(article.date),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    article.title,
                    style: AppTypography.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.synopsis != null && article.synopsis!.trim().isNotEmpty && article.synopsis != article.title) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      article.synopsis!.trim(),
                      style: AppTypography.bodySmall.copyWith(color: AppColors.of(context).textSecondary, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (article.sector != null)
                        _buildChip(context, article.sector!.toString().split('.').last),
                      if (article.region != null)
                        _buildChip(context, article.region!.toString().split('.').last),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.monoTiny,
      ),
    );
  }
}


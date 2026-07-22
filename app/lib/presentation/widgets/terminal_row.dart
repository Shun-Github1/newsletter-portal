import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/domain/entities/article.dart';
import 'package:newsletter_portal/presentation/widgets/sentiment_indicator.dart';
import 'package:intl/intl.dart';

class TerminalRow extends StatefulWidget {
  final Article article;
  final bool isEven;

  const TerminalRow({
    super.key,
    required this.article,
    required this.isEven,
  });

  @override
  State<TerminalRow> createState() => _TerminalRowState();
}

class _TerminalRowState extends State<TerminalRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = _isHovered
        ? AppColors.of(context).surfaceVariant
        : (widget.isEven ? AppColors.of(context).background : AppColors.of(context).sidebar);

    final timestamp = DateFormat('HH:mm:ss').format(widget.article.date);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: 28,
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                timestamp,
                style: AppTypography.monoExtraSmall,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 80,
              child: _buildMutedText(widget.article.region?.toString().split('.').last.toUpperCase() ?? 'NONE'),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 100,
              child: _buildMutedText(widget.article.sector?.toString().split('.').last.toUpperCase() ?? 'NONE'),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                widget.article.title,
                style: AppTypography.monoSmall.copyWith(
                  color: AppColors.of(context).textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 36,
              child: Center(
                child: Tooltip(
                  message: 'Sentiment: ${widget.article.sentimentScore?.toStringAsFixed(2) ?? "N/A"}',
                  child: SentimentDot(sentiment: widget.article.sentimentScore ?? 0.0, size: 6),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 36,
              child: Center(
                child: Tooltip(
                  message: 'Subjectivity: ${widget.article.subjectivityScore?.toStringAsFixed(2) ?? "N/A"}',
                  child: SubjectivityDot(subjectivity: widget.article.subjectivityScore ?? 0.0, size: 6),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 45,
              child: Text(
                'SRC:${widget.article.sourceCount ?? 0}',
                style: AppTypography.monoTiny,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMutedText(String text) {
    return Text(
      text,
      style: AppTypography.monoTiny,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}


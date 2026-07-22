import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';

class ReportShell extends StatelessWidget {
  const ReportShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: Text('NEWSLETTER REPORT', style: AppTypography.monoMedium.copyWith(color: AppColors.accent, letterSpacing: 2)),
        actions: [
          TextButton(
            onPressed: () => context.go('/terminal'),
            child: Text('Terminal', style: AppTypography.monoSmall.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: Center(
        child: Text(
          'REPORT VIEW COMING SOON',
          style: AppTypography.monoMedium.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}


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
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: AppColors.of(context).sidebar,
        elevation: 0,
        title: Text('Report', style: AppTypography.headlineMedium),
        actions: [
          TextButton(
            onPressed: () => context.go('/terminal'),
            child: Text('Feed', style: AppTypography.labelMedium),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: Center(
        child: Text(
          'Report view coming soon',
          style: AppTypography.bodyMedium,
        ),
      ),
    );
  }
}

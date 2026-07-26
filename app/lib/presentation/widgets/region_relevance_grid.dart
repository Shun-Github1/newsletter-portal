import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';
import 'package:newsletter_portal/presentation/widgets/strength_box.dart';

class RegionRelevanceGrid extends StatelessWidget {
  final Map<String, int> values;
  final Function(String regionTag, int weight) onChanged;

  const RegionRelevanceGrid({
    super.key,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            'Regions',
            style: AppTypography.sectionTitle.copyWith(
              color: AppColors.of(context).textPrimary,
            ),
          ),
        ),
        Column(
          children: AppRegion.values.map((region) {
            return _buildSliderRow(context, region);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSliderRow(BuildContext context, AppRegion region) {
    final currentValue = values[region.tag] ?? values[region.displayName] ?? 1;

    return Container(
      height: 32,
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              region.displayName,
              style: AppTypography.bodySmall.copyWith(color: AppColors.of(context).textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: StrengthBar(
              value: currentValue,
              onChanged: (weight) => onChanged(region.tag, weight),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 16,
            child: Text(
              currentValue.toString(),
              style: AppTypography.monoSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}


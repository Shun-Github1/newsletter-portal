import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';

class RegionRelevanceGrid extends StatelessWidget {
  final Map<String, int> values;
  final Function(String regionTag, int weight) onChanged;

  const RegionRelevanceGrid({
    super.key,
    required this.values,
    required this.onChanged,
  });

  static const List<String> _regions = [
    'North America', 'Europe', 'Asia Pacific', 'Latin America', 'Middle East', 'Africa'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            'Regions',
            style: AppTypography.titleSmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Column(
          children: _regions.map((region) {
            return _buildSliderRow(region);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSliderRow(String region) {
    final currentValue = values[region] ?? 1;

    return Container(
      height: 32,
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              region,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(5, (index) {
                final weight = index + 1;
                final isSelected = weight <= currentValue;
                
                return GestureDetector(
                  onTap: () => onChanged(region, weight),
                  child: Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.border,
                      ),
                    ),
                  ),
                );
              }),
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


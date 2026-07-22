import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';

class SectorRelevanceGrid extends StatelessWidget {
  final Map<int, int> values;
  final Function(int sectorId, int weight) onChanged;

  const SectorRelevanceGrid({
    super.key,
    required this.values,
    required this.onChanged,
  });

  // Mappings for 16 real sectors (1-8 hard, 9-16 soft)
  static const Map<int, String> _hardSectors = {
    1: 'Politics & Government',
    2: 'Business & Economy',
    3: 'Conflict / Military',
    4: 'Crime & Justice',
    5: 'Technology',
    6: 'Environment & Climate',
    7: 'Weather',
    8: 'Real Estate',
  };

  static const Map<int, String> _softSectors = {
    9: 'Science',
    10: 'Health & Medicine',
    11: 'Education',
    12: 'Sports',
    13: 'Arts & Entertainment',
    14: 'Lifestyle & Culture',
    15: 'Religion & Ethics',
    16: 'Opinion & Commentary',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hard Sectors'),
        _buildSectorList(_hardSectors),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Divider(color: AppColors.border),
        ),
        _buildSectionTitle('Soft Sectors'),
        _buildSectorList(_softSectors),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSectorList(Map<int, String> sectors) {
    return Column(
      children: sectors.entries.map((e) {
        return _buildSliderRow(e.key, e.value);
      }).toList(),
    );
  }

  Widget _buildSliderRow(int id, String name) {
    final currentValue = values[id] ?? 1;

    return Container(
      height: 32,
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
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
                  onTap: () => onChanged(id, weight),
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


import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';

typedef TagItem = ({String tag, String displayName});

class TagPicker extends StatefulWidget {
  final List<TagItem> availableTags;
  final Set<String> selectedTags;
  final Function(Set<String>) onChanged;

  const TagPicker({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onChanged,
  });

  @override
  State<TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends State<TagPicker> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    
    // Always prioritize selected tags so user selections remain visible
    final allMatching = widget.availableTags.where((tag) {
      if (widget.selectedTags.contains(tag.tag)) return true;
      if (query.isEmpty) return true;
      return tag.displayName.toLowerCase().contains(query) ||
             tag.tag.toLowerCase().contains(query);
    }).toList();

    // Cap display count to top 30 items to guarantee zero UI lag during search
    final filteredTags = query.isEmpty 
        ? allMatching.take(30).toList() 
        : allMatching.take(50).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search tags...',
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredTags.length,
            itemBuilder: (context, index) {
              final item = filteredTags[index];
              final isSelected = widget.selectedTags.contains(item.tag);
              
              return InkWell(
                onTap: () {
                  final newSelection = Set<String>.from(widget.selectedTags);
                  if (isSelected) {
                    newSelection.remove(item.tag);
                  } else {
                    newSelection.add(item.tag);
                  }
                  widget.onChanged(newSelection);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (val) {
                            final newSelection = Set<String>.from(widget.selectedTags);
                            if (val == true) {
                              newSelection.add(item.tag);
                            } else {
                              newSelection.remove(item.tag);
                            }
                            widget.onChanged(newSelection);
                          },
                          activeColor: AppColors.accent,
                          checkColor: AppColors.background,
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          item.displayName,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


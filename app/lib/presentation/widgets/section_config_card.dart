import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/presentation/widgets/glass_panel.dart';
import 'package:newsletter_portal/presentation/widgets/app_icon_button.dart';
import 'package:newsletter_portal/domain/entities/report_section.dart';
import 'package:newsletter_portal/presentation/widgets/sector_relevance_grid.dart';
import 'package:newsletter_portal/presentation/widgets/region_relevance_grid.dart';
import 'package:newsletter_portal/presentation/widgets/tag_picker.dart';

class SectionConfigCard extends StatefulWidget {
  final ReportSection section;
  final Function(ReportSection) onUpdate;
  final VoidCallback onDelete;
  final List<TagItem> availableTags;

  const SectionConfigCard({
    super.key,
    required this.section,
    required this.onUpdate,
    required this.onDelete,
    required this.availableTags,
  });

  @override
  State<SectionConfigCard> createState() => _SectionConfigCardState();
}

class _SectionConfigCardState extends State<SectionConfigCard> {
  bool _isExpanded = false;
  late TextEditingController _titleController;
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section.title);
    _minController = TextEditingController(text: widget.section.minItems.toString());
    _maxController = TextEditingController(text: widget.section.maxItems.toString());
  }

  @override
  void didUpdateWidget(SectionConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.title != widget.section.title && _titleController.text != widget.section.title) {
      _titleController.text = widget.section.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _updateSection({
    String? title,
    Map<int, int>? sectorWeights,
    Map<String, int>? regionWeights,
    Set<String>? tags,
    int? minItems,
    int? maxItems,
    double? sentimentThreshold,
    bool? showDate,
    bool? showRegionSector,
    bool? showSentimentSubjectivity,
    bool? showSourceCount,
    bool? showSynopsis,
  }) {
    widget.onUpdate(widget.section.copyWith(
      title: title,
      sectorWeights: sectorWeights,
      regionWeights: regionWeights,
      tags: tags?.toList(),
      minItems: minItems,
      maxItems: maxItems,
      sentimentThreshold: sentimentThreshold,
      showDate: showDate,
      showRegionSector: showRegionSector,
      showSentimentSubjectivity: showSentimentSubjectivity,
      showSourceCount: showSourceCount,
      showSynopsis: showSynopsis,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.of(context).surfaceVariant,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  AppIcon(
                    _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _isExpanded
                        ? TextField(
                            controller: _titleController,
                            style: AppTypography.panelTitle.copyWith(
                              color: AppColors.of(context).textSecondary,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (val) => _updateSection(title: val),
                            onTapOutside: (_) => _updateSection(title: _titleController.text),
                          )
                        : Text(
                            widget.section.title,
                            style: AppTypography.panelTitle.copyWith(
                              color: AppColors.of(context).textSecondary,
                            ),
                          ),
                  ),
                  if (!_isExpanded) ...[
                    Text(
                      '${widget.section.sectorWeights.length} sectors, ${widget.section.regionWeights.length} regions',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  AppIconButton(
                    icon: Icons.close,
                    size: 16,
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    tooltip: 'Delete section',
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SectorRelevanceGrid(
                          values: widget.section.sectorWeights,
                          onChanged: (id, weight) {
                            final newWeights = Map<int, int>.from(widget.section.sectorWeights);
                            newWeights[id] = weight;
                            _updateSection(sectorWeights: newWeights);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          children: [
                            RegionRelevanceGrid(
                              values: widget.section.regionWeights,
                              onChanged: (region, weight) {
                                final newWeights = Map<String, int>.from(widget.section.regionWeights);
                                newWeights[region] = weight;
                                _updateSection(regionWeights: newWeights);
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Tags',
                                style: AppTypography.sectionTitle.copyWith(
                                  color: AppColors.of(context).textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TagPicker(
                              availableTags: widget.availableTags,
                              selectedTags: Set.from(widget.section.tags),
                              onChanged: (tags) => _updateSection(tags: tags),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Text('Items:', style: AppTypography.bodySmall),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _minController,
                          keyboardType: TextInputType.number,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.of(context).textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Min',
                            labelStyle: AppTypography.monoTiny,
                            isDense: true,
                          ),
                          onSubmitted: (val) => _updateSection(minItems: int.tryParse(val)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _maxController,
                          keyboardType: TextInputType.number,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.of(context).textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Max',
                            labelStyle: AppTypography.monoTiny,
                            isDense: true,
                          ),
                          onSubmitted: (val) => _updateSection(maxItems: int.tryParse(val)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Text('Relevance Threshold:', style: AppTypography.bodySmall),
                      Expanded(
                        child: Slider(
                          value: widget.section.sentimentThreshold.clamp(0.0, 1.0),
                          min: 0.0,
                          max: 1.0,
                          activeColor: AppColors.of(context).textPrimary,
                          inactiveColor: AppColors.of(context).border,
                          onChanged: (val) => _updateSection(sentimentThreshold: val),
                        ),
                      ),
                      Text(
                        widget.section.sentimentThreshold.clamp(0.0, 1.0).toStringAsFixed(2),
                        style: AppTypography.monoSmall.copyWith(color: AppColors.of(context).textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            _titleController.text = 'New Section 1';
                            _minController.text = '1';
                            _maxController.text = '10';
                            _updateSection(
                              title: 'New Section 1',
                              tags: const {},
                              minItems: 1,
                              maxItems: 10,
                              sentimentThreshold: 0.0,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Section reset to default parameters', style: AppTypography.monoSmall),
                                duration: const Duration(seconds: 2),
                                backgroundColor: AppColors.of(context).surface,
                              ),
                            );
                          },
                          icon: Icon(Icons.refresh, size: 14, color: AppColors.of(context).textSecondary),
                          label: Text('Reset', style: AppTypography.monoTiny.copyWith(fontWeight: FontWeight.bold, color: AppColors.of(context).textSecondary)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.of(context).border),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton.icon(
                          onPressed: () {
                            _updateSection(
                              title: _titleController.text,
                              minItems: int.tryParse(_minController.text),
                              maxItems: int.tryParse(_maxController.text),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Section "${widget.section.title}" saved!', style: AppTypography.monoSmall),
                                duration: const Duration(seconds: 2),
                                backgroundColor: AppColors.of(context).surface,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check, size: 14, color: AppColors.onAccent),
                          label: Text('Save section', style: AppTypography.monoTiny.copyWith(fontWeight: FontWeight.bold, color: AppColors.onAccent)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: AppAnimation.fast,
          ),
        ],
      ),
    );
  }
}


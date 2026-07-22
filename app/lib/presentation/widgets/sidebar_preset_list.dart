import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/presentation/widgets/glass_panel.dart';
import 'package:newsletter_portal/domain/entities/report_preset.dart';
import 'package:intl/intl.dart';

class SidebarPresetList extends StatelessWidget {
  final List<ReportPreset> presets;
  final String? activePresetId;
  final Function(String) onSelect;
  final VoidCallback onAdd;
  final Function(String) onDelete;
  final Function(String, String) onRename;

  const SidebarPresetList({
    super.key,
    required this.presets,
    this.activePresetId,
    required this.onSelect,
    required this.onAdd,
    required this.onDelete,
    required this.onRename,
  });

  void _showContextMenu(BuildContext context, ReportPreset preset, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      items: [
        PopupMenuItem(
          value: 'rename',
          child: Text('Rename', style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
          onTap: () {
            // Delay to allow menu to close before showing dialog
            Future.delayed(Duration.zero, () => _showRenameDialog(context, preset));
          },
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
          onTap: () => onDelete(preset.id),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, ReportPreset preset) {
    final controller = TextEditingController(text: preset.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Rename Preset', style: AppTypography.titleMedium),
          content: TextField(
            controller: controller,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onRename(preset.id, controller.text.trim());
                }
                Navigator.pop(context);
              },
              child: Text('Save', style: AppTypography.labelLarge.copyWith(color: AppColors.accent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Projects',
                style: AppTypography.monoTiny.copyWith(
                  letterSpacing: 1.1,
                ),
              ),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.add, size: 16, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              final isActive = preset.id == activePresetId;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GestureDetector(
                  onSecondaryTapDown: (details) => _showContextMenu(context, preset, details.globalPosition),
                  onLongPressStart: (details) => _showContextMenu(context, preset, details.globalPosition),
                  child: GlassPanelHover(
                    onTap: () => onSelect(preset.id),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    isSelected: isActive,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.name,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isActive ? AppColors.accent : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(preset.updatedAt),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
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


import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/presentation/widgets/glass_panel.dart';
import 'package:newsletter_portal/presentation/widgets/app_icon_button.dart';
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
      color: AppColors.of(context).surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      items: [
        PopupMenuItem(
          value: 'rename',
          child: Text('Rename', style: AppTypography.bodyMedium.copyWith(color: AppColors.of(context).textPrimary)),
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
          backgroundColor: AppColors.of(context).surface,
          title: Text('Rename Preset', style: AppTypography.pageTitle),
          content: TextField(
            controller: controller,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.of(context).textPrimary),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.of(context).border)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.of(context).textPrimary)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.of(context).textSecondary)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onRename(preset.id, controller.text.trim());
                }
                Navigator.pop(context);
              },
              child: Text('Save', style: AppTypography.labelLarge.copyWith(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.w600)),
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
                style: AppTypography.panelTitle.copyWith(
                  color: AppColors.of(context).textPrimary,
                ),
              ),
              AppIconButton(
                icon: Icons.add,
                size: 16,
                onPressed: onAdd,
                padding: const EdgeInsets.all(4),
                tooltip: 'Add project',
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
                            color: AppColors.of(context).textPrimary,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
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


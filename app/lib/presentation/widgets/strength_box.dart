import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';

/// Row of 5 strength cells. Hovering weight N previews boxes 1…N;
/// only committed weights stay filled dark — preview-only cells are grey.
class StrengthBar extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const StrengthBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<StrengthBar> createState() => _StrengthBarState();
}

class _StrengthBarState extends State<StrengthBar> {
  int? _hoverWeight;

  @override
  Widget build(BuildContext context) {
    final previewValue = _hoverWeight ?? widget.value;

    return MouseRegion(
      onExit: (_) => setState(() => _hoverWeight = null),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(5, (index) {
          final weight = index + 1;
          final isCommitted = weight <= widget.value;
          final inPreview = weight <= previewValue;
          return StrengthBox(
            isCommitted: isCommitted && inPreview,
            isPreview: !isCommitted && inPreview,
            isHovered: _hoverWeight != null && weight <= _hoverWeight!,
            onHover: () => setState(() => _hoverWeight = weight),
            onTap: () => widget.onChanged(weight),
          );
        }),
      ),
    );
  }
}

/// Compact strength/weight cell with hover scale + color feedback.
class StrengthBox extends StatelessWidget {
  final bool isCommitted;
  final bool isPreview;
  final bool isHovered;
  final VoidCallback onHover;
  final VoidCallback onTap;

  const StrengthBox({
    super.key,
    required this.isCommitted,
    required this.isPreview,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final Color color;
    final Border? border;
    if (isCommitted) {
      color = isHovered ? colors.iconHover : colors.textPrimary;
      border = null;
    } else if (isPreview) {
      color = colors.textTertiary;
      border = null;
    } else {
      // Outline + surface fill so empty cells stay visible on surfaceVariant panels.
      color = colors.surface;
      border = Border.all(color: colors.border, width: 1);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isHovered ? 1.15 : 1.0,
          duration: AppAnimation.fast,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: AppAnimation.fast,
            curve: Curves.easeOutCubic,
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: border,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';

/// Compact strength/weight cell with hover scale + color feedback.
class StrengthBox extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const StrengthBox({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<StrengthBox> createState() => _StrengthBoxState();
}

class _StrengthBoxState extends State<StrengthBox> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final Color color;
    if (widget.isSelected) {
      color = _hovered ? colors.iconHover : colors.textPrimary;
    } else {
      color = _hovered ? colors.textTertiary : colors.surfaceVariant;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.2 : 1.0,
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
            ),
          ),
        ),
      ),
    );
  }
}

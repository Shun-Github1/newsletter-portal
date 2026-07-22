import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool showBorder;
  final double borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.showBorder = true,
    this.borderRadius = AppRadius.lg,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: AppAnimation.normal,
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                    width: 1,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: panel,
        ),
      );
    }

    return panel;
  }
}

class GlassPanelHover extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool isSelected;

  const GlassPanelHover({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = AppRadius.lg,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<GlassPanelHover> createState() => _GlassPanelHoverState();
}

class _GlassPanelHoverState extends State<GlassPanelHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isSelected
        ? AppColors.accent.withValues(alpha: 0.6)
        : _isHovered
            ? AppColors.borderLight
            : AppColors.border.withValues(alpha: 0.4);

    final bgColor = widget.isSelected
        ? AppColors.accent.withValues(alpha: 0.08)
        : _isHovered
            ? AppColors.surfaceVariant.withValues(alpha: 0.9)
            : AppColors.surface.withValues(alpha: 0.85);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppAnimation.fast,
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

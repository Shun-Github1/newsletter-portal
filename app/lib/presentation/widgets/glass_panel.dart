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
    this.showBorder = false,
    this.borderRadius = AppRadius.lg,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: AppColors.of(context).border, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0x40000000)
                : const Color(0x0A101828),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
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
    final bgColor = widget.isSelected
        ? AppColors.of(context).surfaceHover
        : _isHovered
            ? AppColors.of(context).surfaceVariant
            : AppColors.of(context).surface;

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
            border: widget.isSelected
                ? Border.all(color: AppColors.of(context).textPrimary, width: 1)
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

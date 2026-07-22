import 'package:flutter/material.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';

/// Icon that stays grey by default and highlights to black (light) / white (dark) on hover.
class AppIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final bool active;
  final Color? color;
  final Color? activeColor;
  final Color? hoverColor;

  const AppIcon(
    this.icon, {
    super.key,
    this.size = 18,
    this.active = false,
    this.color,
    this.activeColor,
    this.hoverColor,
  });

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final base = widget.color ?? colors.icon;
    final hover = widget.hoverColor ?? colors.iconHover;
    final active = widget.activeColor ?? colors.iconHover;
    final color = widget.active ? active : (_hovered ? hover : base);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Icon(widget.icon, size: widget.size, color: color),
    );
  }
}

/// Icon button with grey → black/white hover highlight.
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final bool active;
  final bool flipX;
  final EdgeInsetsGeometry padding;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 18,
    this.active = false,
    this.flipX = false,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = widget.active
        ? colors.iconHover
        : (_hovered ? colors.iconHover : colors.icon);

    Widget icon = Icon(widget.icon, size: widget.size, color: color);
    if (widget.flipX) {
      icon = Transform.flip(flipX: true, child: icon);
    }

    final button = MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: widget.padding,
          child: icon,
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

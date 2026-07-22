import 'package:flutter/material.dart';

class SidebarResizeHandle extends StatelessWidget {
  final ValueChanged<double> onDrag;
  final bool isRight;

  const SidebarResizeHandle({
    super.key,
    required this.onDrag,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          final delta = isRight ? -details.delta.dx : details.delta.dx;
          onDrag(delta);
        },
        child: Container(
          width: 6,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

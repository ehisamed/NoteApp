// toggle_text_alignment.dart

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class ToggleTextAlignment extends StatelessWidget {
  final quill.QuillController controller;
  final bool isDark;

  final VoidCallback onAlignLeft;
  final VoidCallback onAlignCenter;
  final VoidCallback onAlignRight;

  const ToggleTextAlignment({
    Key? key,
    required this.controller,
    required this.isDark,
    required this.onAlignLeft,
    required this.onAlignCenter,
    required this.onAlignRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attrs = controller.getSelectionStyle().attributes;
    final alignment = attrs[quill.Attribute.align.key]?.value ?? 'left';

    Color activeColor = Theme.of(context).colorScheme.primary;
    Color inactiveColor = isDark ? Colors.white70 : Colors.black54;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.format_align_left,
              color: alignment == 'left' ? activeColor : inactiveColor),
          onPressed: onAlignLeft,
          tooltip: 'Align Left',
        ),
        IconButton(
          icon: Icon(Icons.format_align_center,
              color: alignment == 'center' ? activeColor : inactiveColor),
          onPressed: onAlignCenter,
          tooltip: 'Align Center',
        ),
        IconButton(
          icon: Icon(Icons.format_align_right,
              color: alignment == 'right' ? activeColor : inactiveColor),
          onPressed: onAlignRight,
          tooltip: 'Align Right',
        ),
      ],
    );
  }
}

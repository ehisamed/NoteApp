import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class ExtraOptions extends StatefulWidget {
  final bool isDark;
  final quill.QuillController controller;
  final VoidCallback onToggleNumberedList;
  final VoidCallback onInsertImage;
  final VoidCallback onInsertCamera;
  final VoidCallback onToggleBulletedList;

  final double selectedFontSize;
  final ValueChanged<double> onFontSizeChanged;

  const ExtraOptions({
    super.key,
    required this.isDark,
    required this.controller,
    required this.onToggleNumberedList,
    required this.onInsertImage,
    required this.onInsertCamera,
    required this.onToggleBulletedList,
    required this.selectedFontSize,
    required this.onFontSizeChanged,
  });

  @override
  State<ExtraOptions> createState() => _ExtraOptionsState();
}

class _ExtraOptionsState extends State<ExtraOptions> {
  static final List<double> fontSizes = [14, 16, 18, 21, 24, 32];

  double get _currentSize => widget.selectedFontSize;

  void _increaseFontSize() {
    final currentIndex = fontSizes.indexWhere((s) => s >= _currentSize);
    if (currentIndex < fontSizes.length - 1) {
      widget.onFontSizeChanged(fontSizes[currentIndex + 1]);
    }
  }

  void _decreaseFontSize() {
    final currentIndex = fontSizes.lastIndexWhere((s) => s <= _currentSize);
    if (currentIndex > 0) {
      widget.onFontSizeChanged(fontSizes[currentIndex - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOrderedList =
        widget.controller
            .getSelectionStyle()
            .attributes[quill.Attribute.list.key]
            ?.value ==
        'ordered';

    final isBulletedList =
        widget.controller
            .getSelectionStyle()
            .attributes[quill.Attribute.list.key]
            ?.value ==
        'bullet';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity, 
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xff171717) : Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize
                .min, 
            children: [
              IconButton(
                icon: Icon(
                  Icons.format_list_numbered,
                  color: isOrderedList
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).hintColor,
                ),
                onPressed: widget.onToggleNumberedList,
              ),
              IconButton(
                icon: Icon(
                  Icons.format_list_bulleted,
                  color: isBulletedList
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).hintColor,
                ),
                onPressed: widget.onToggleBulletedList,
              ),
              IconButton(
                icon: Icon(Icons.image, color: Theme.of(context).hintColor),
                onPressed: widget.onInsertImage,
              ),
              IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).hintColor,
                ),
                onPressed: widget.onInsertCamera,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _decreaseFontSize,
                    icon: Icon(Icons.text_decrease, color: Theme.of(context).hintColor),
                  ),
                  Text(
                    widget.selectedFontSize.toInt().toString(),
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: _increaseFontSize,
                    icon: Icon(Icons.text_increase, color: Theme.of(context).hintColor),
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

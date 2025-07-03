import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:note_app_practice1/features/notes/utils/toggle_text_alignment.dart';

class ExtraOptions extends StatefulWidget {
  final bool isDark;
  final quill.QuillController controller;
  final VoidCallback onToggleNumberedList;
  final VoidCallback onInsertImage;
  final VoidCallback onInsertCamera;
  final VoidCallback onToggleBulletedList;

  final double selectedFontSize;
  final ValueChanged<double> onFontSizeChanged;

  final VoidCallback onAlignLeft;
  final VoidCallback onAlignCenter;
  final VoidCallback onAlignRight;

  final bool showExtraButton;

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
    required this.onAlignLeft,
    required this.onAlignCenter,
    required this.onAlignRight,
    required this.showExtraButton,
  });

  @override
  State<ExtraOptions> createState() => _ExtraOptionsState();
}

class _ExtraOptionsState extends State<ExtraOptions> {
  static final List<double> fontSizes = [14, 16, 18, 21, 24, 32];

  static final List<Color> textColors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  late Color _selectedColor;
  late Color _defaultColor;

  @override
  void initState() {
    super.initState();
    _defaultColor = widget.isDark ? Colors.white : Colors.black;
    _selectedColor = _defaultColor;
  }

  @override
  void didUpdateWidget(covariant ExtraOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      _defaultColor = widget.isDark ? Colors.white : Colors.black;
      if (widget.controller.selection.isCollapsed) {
        setState(() {
          _selectedColor = _defaultColor;
        });
      }
    }
  }

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

  void _applyTextColor(Color color) {
    final hexColor = '#${color.value.toRadixString(16).substring(2)}';
    final attr = quill.Attribute.fromKeyValue('color', hexColor);

    if (!widget.controller.selection.isCollapsed) {
      widget.controller.formatSelection(attr);

      final collapsedSelection = TextSelection.collapsed(
        offset: widget.controller.selection.end,
      );
      widget.controller.updateSelection(
        collapsedSelection,
        quill.ChangeSource.local,
      );
      widget.controller.formatSelection(
        quill.Attribute.clone(quill.Attribute.color, null),
      );

      setState(() {
        _selectedColor = color;
      });
    } else {
      widget.controller.formatSelection(attr);
      setState(() {
        _selectedColor = color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnderlined =
        widget.controller
            .getSelectionStyle()
            .attributes[quill.Attribute.underline.key] !=
        null;

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
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xff171717) : Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.showExtraButton)
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

              if (!widget.showExtraButton)
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
                    icon: Icon(
                      Icons.text_decrease,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Text(
                    widget.selectedFontSize.toInt().toString(),
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: _increaseFontSize,
                    icon: Icon(
                      Icons.text_increase,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),

              ToggleTextAlignment(
                controller: widget.controller,
                isDark: widget.isDark,
                onAlignLeft: widget.onAlignLeft,
                onAlignCenter: widget.onAlignCenter,
                onAlignRight: widget.onAlignRight,
              ),

              IconButton(
                icon: Icon(
                  Icons.format_underline,
                  color: isUnderlined
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).hintColor,
                ),
                onPressed: () {
                  if (isUnderlined) {
                    widget.controller.formatSelection(
                      quill.Attribute.clone(quill.Attribute.underline, null),
                    );
                  } else {
                    widget.controller.formatSelection(
                      quill.Attribute.underline,
                    );
                  }
                  setState(() {});
                },
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButton<Color>(
                  value: _selectedColor,
                  dropdownColor: widget.isDark
                      ? Colors.grey[900]
                      : Colors.white,
                  underline: SizedBox(),
                  iconEnabledColor: widget.isDark ? Colors.white : Colors.black,
                  items: textColors
                      .map(
                        (color) => DropdownMenuItem(
                          value: color,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (color) {
                    if (color != null) {
                      _applyTextColor(color);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

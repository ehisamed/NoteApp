import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/src/editor/style_widgets/checkbox_point.dart';

class CustomCheckboxBuilder implements quill.QuillCheckboxBuilder {
  @override
  Widget build({
    required BuildContext context,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
  }) {
    return QuillCheckboxPoint(
      size: 19,
      value: isChecked,
      enabled: true,
      onChanged: onChanged,
    );
  }
}

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();

  bool isBoldSelected = false;
  bool isItalicSelected = false;
  bool isCheckboxSelected = false;

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final deltaJson = _controller.document.toDelta().toJson();
    final title = _titleController.text;

    print('Title: $title');
    print('Content (Delta): $deltaJson');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note saved')));
  }

  void _toggleBold() {
    final attrs = _controller.getSelectionStyle().attributes;
    final isBold = attrs.containsKey(quill.Attribute.bold.key);
    final isItalic = attrs.containsKey(quill.Attribute.italic.key);

    setState(() {
      if (isBold) {
        _controller.formatSelection(
          quill.Attribute.clone(quill.Attribute.bold, null),
        );
        isBoldSelected = false;
      } else {
        _controller.formatSelection(quill.Attribute.bold);
        if (isItalic) {
          _controller.formatSelection(
            quill.Attribute.clone(quill.Attribute.italic, null),
          );
          isItalicSelected = false;
        }
        isBoldSelected = true;
      }
      _editorFocusNode.requestFocus();
    });
  }

  void _toggleItalic() {
    final attrs = _controller.getSelectionStyle().attributes;
    final isItalic = attrs.containsKey(quill.Attribute.italic.key);
    final isBold = attrs.containsKey(quill.Attribute.bold.key);

    setState(() {
      if (isItalic) {
        _controller.formatSelection(
          quill.Attribute.clone(quill.Attribute.italic, null),
        );
        isItalicSelected = false;
      } else {
        _controller.formatSelection(quill.Attribute.italic);
        if (isBold) {
          _controller.formatSelection(
            quill.Attribute.clone(quill.Attribute.bold, null),
          );
          isBoldSelected = false;
        }
        isItalicSelected = true;
      }
      _editorFocusNode.requestFocus();
    });
  }

  void _toggleCheckbox() {
    final attrs = _controller.getSelectionStyle().attributes;
    final isCheckbox =
        attrs.containsKey(quill.Attribute.unchecked.key) ||
        attrs.containsKey(quill.Attribute.checked.key);

    setState(() {
      if (isCheckbox) {
        // ❌ Удалить чекбокс (сбросить список)
        _controller.formatSelection(
          quill.Attribute.clone(quill.Attribute.list, null),
        );
        isCheckboxSelected = false;
      } else {
        // ✅ Установить чекбокс
        _controller.formatSelection(quill.Attribute.unchecked);
        isCheckboxSelected = true;

        // Убираем другие стили
        if (isBoldSelected) {
          _controller.formatSelection(
            quill.Attribute.clone(quill.Attribute.bold, null),
          );
          isBoldSelected = false;
        }
        if (isItalicSelected) {
          _controller.formatSelection(
            quill.Attribute.clone(quill.Attribute.italic, null),
          );
          isItalicSelected = false;
        }
      }

      _editorFocusNode.requestFocus();
    });
  }

  void _toggleNumberedList() {
    final attrs = _controller.getSelectionStyle().attributes;
    final isOrderedList =
        attrs.containsKey(quill.Attribute.list.key) &&
        attrs[quill.Attribute.list.key]!.value == 'ordered';

    setState(() {
      if (isOrderedList) {
        // Если уже нумерованный список — убираем форматирование списка
        _controller.formatSelection(
          quill.Attribute.clone(quill.Attribute.list, null),
        );
      } else {
        // Иначе устанавливаем нумерованный список
        _controller.formatSelection(quill.Attribute.ol);

        // Можно дополнительно убрать другие стили, если нужно
        if (isBoldSelected) {
          _controller.formatSelection(
            quill.Attribute.clone(quill.Attribute.bold, null),
          );
          isBoldSelected = false;
        }
        if (isItalicSelected) {
          _controller.formatSelection(
            quill.Attribute.clone(quill.Attribute.italic, null),
          );
          isItalicSelected = false;
        }
        if (isCheckboxSelected) {
          _controller.formatSelection(
            quill.Attribute.clone(quill.Attribute.list, null),
          );
          isCheckboxSelected = false;
        }
      }
      _editorFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 65,
        // title: const Text('Create Note'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Заголовок',
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                  ),
                ),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "Июнь 26",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),

                  const SizedBox(width: 12),
                  Text("|", style: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: Colors.grey.shade400
                  ),),
                  const SizedBox(width: 12),

                  Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        minimumSize: Size(0, 0),
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                      ),
                      onPressed: () {
                        // Действие при нажатии
                      },
                      icon: Icon(
                        Icons.add_box_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        'Добавить в категорию',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            
            const SizedBox(height: 22),

            // Editor + Custom Toolbar
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: quill.QuillEditor.basic(
                        controller: _controller,
                        focusNode: _editorFocusNode,
                        config: quill.QuillEditorConfig(
                          placeholder: 'Начните ввод',
                          customStyles: quill.DefaultStyles(
                            paragraph: quill.DefaultTextBlockStyle(
                              TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              const quill.HorizontalSpacing(0, 0),
                              const quill.VerticalSpacing(0, 0),
                              const quill.VerticalSpacing(0, 0),
                              null,
                            ),
                            placeHolder: quill.DefaultTextBlockStyle(
                              TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                              const quill.HorizontalSpacing(0, 0),
                              const quill.VerticalSpacing(0, 0),
                              const quill.VerticalSpacing(0, 0),
                              null,
                            ),
                            lists: quill.DefaultListBlockStyle(
                              TextStyle(fontSize: 16),
                              const quill.HorizontalSpacing(0, 0),
                              const quill.VerticalSpacing(4, 0),
                              const quill.VerticalSpacing(0, 4),
                              null,
                              CustomCheckboxBuilder(), // ✅ вот тут передаётся builder
                            ),
                          ),
                          autoFocus: true,
                        ),
                      ),
                    ),
                  ),
                  // Custom Toolbar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xff171717)
                                    : Colors.black,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.format_bold,
                                      color: isBoldSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context).hintColor,
                                    ),
                                    onPressed: _toggleBold,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.format_italic,
                                      color: isItalicSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context).hintColor,
                                    ),
                                    onPressed: _toggleItalic,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.check_box,
                                      color: isCheckboxSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context).hintColor,
                                    ),
                                    onPressed: _toggleCheckbox,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.format_list_numbered,
                                      color:
                                          _controller
                                                  .getSelectionStyle()
                                                  .attributes[quill
                                                      .Attribute
                                                      .list
                                                      .key]
                                                  ?.value ==
                                              'ordered'
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context).hintColor,
                                    ),
                                    onPressed: _toggleNumberedList,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            style:
                                TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  foregroundColor: Colors.white,
                                ).copyWith(
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.white.withOpacity(0.2),
                                  ),
                                ),
                            onPressed: () {
                              // Логика сохранения
                            },
                            child: const Text(
                              'Сохранить',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

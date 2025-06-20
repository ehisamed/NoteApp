// src/lib/features/notes/view/note_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/services.dart';
import 'package:flutter_quill/src/editor/style_widgets/checkbox_point.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

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
  bool _showExtraOptions = false;
  bool _isRequestingPermission = false;

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

  Future<bool> requestStoragePermission() async {
    if (await Permission.photos.isGranted) {
      print('✅ Already granted');
      return true;
    }

    final result = await Permission.photos.request();

    if (result.isGranted) {
      print('✅ Photos permission granted');
      return true;
    } else {
      print('❌ Photos permission denied');
      return false;
    }
  }

  Future<void> _insertImage() async {
    if (_isRequestingPermission) return;
    _isRequestingPermission = true;

    bool permissionGranted = await requestStoragePermission();
    _isRequestingPermission = false;

    if (!permissionGranted) {
      print('Permission denied');
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageUrl = pickedFile.path;

      final index = _controller.selection.baseOffset;
      final length = _controller.selection.extentOffset - index;

      print('Inserting image at index=$index length=$length path=$imageUrl');

      _controller.replaceText(
        index < 0 ? 0 : index,
        length < 0 ? 0 : length,
        quill.BlockEmbed.image(imageUrl),
        null,
      );

      _editorFocusNode.requestFocus();
      setState(() {}); // если нужно обновить UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 65,
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ).copyWith(elevation: WidgetStateProperty.all(0)),
            onPressed: () async {
              
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dialogTheme: DialogThemeData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate == null) return;

              // Выбор времени
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dialogTheme: DialogThemeData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedTime == null) return;

              // Объединяем дату и время
              final reminderDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Напоминание установлено на: $reminderDateTime',
                  ),
                ),
              );

              print('Выбранное время напоминания: $reminderDateTime');
            },
            icon: Icon(Icons.add_alarm),
            label: Text("Напоминание", style: TextStyle(fontSize: 12)),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: Transform.flip(
                flipX: true,
                flipY: true,
                child: Icon(Icons.subdirectory_arrow_right),
              ),
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Transform.flip(
                flipX: false,
                flipY: true,
                child: Icon(Icons.subdirectory_arrow_right),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _titleController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                buildCounter:
                    (
                      _, {
                      required int currentLength,
                      required bool isFocused,
                      required int? maxLength,
                    }) => null,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.split('\n').length > 4) return oldValue;
                    return newValue;
                  }),
                ],
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

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "Июнь 26",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),

                  const SizedBox(width: 12),
                  Text(
                    "|",
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      color: Colors.grey.shade400,
                    ),
                  ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
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
                          fontSize: 12,
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
                      child: quill.QuillEditor(
                        controller: _controller,
                        focusNode: _editorFocusNode,
                        // embedBuilders: FlutterQuillEmbeds.builders(),
                        scrollController: ScrollController(),
                        config: quill.QuillEditorConfig(
                          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
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

                  if (_showExtraOptions)
                    AnimatedSlide(
                      offset: _showExtraOptions ? Offset(0, 0) : Offset(0, 0.1),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: AnimatedOpacity(
                        opacity: _showExtraOptions ? 1 : 0,
                        duration: Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 2,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Color(0xff262626)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 12,
                                  children: [
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
                                    IconButton(
                                      icon: Icon(
                                        Icons.image,
                                        color: Theme.of(context).hintColor,
                                      ),
                                      onPressed: _insertImage,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Custom Toolbar
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
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
                                    icon: AnimatedRotation(
                                      turns: _showExtraOptions ? 0.5 : 0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_up,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showExtraOptions = !_showExtraOptions;
                                      });
                                    },
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

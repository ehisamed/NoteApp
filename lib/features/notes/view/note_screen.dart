// src/lib/features/notes/view/note_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:flutter_quill/src/editor/style_widgets/checkbox_point.dart';
import 'package:note_app_practice1/features/notes/components/undo_redo_button.dart';
import 'package:note_app_practice1/features/notes/service/insert_image_gallery.dart';
import 'package:note_app_practice1/features/notes/service/insert_image_camera.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:note_app_practice1/features/notes/utils/editor_utils.dart'
    // ignore: library_prefixes
    as editorUtils;
import 'package:note_app_practice1/features/notes/components/dialog.dart';
import 'package:note_app_practice1/l10n/app_localizations.dart';
import 'package:note_app_practice1/features/notes/components/extra_options.dart';

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
  const NoteScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();
  bool _showExtraOptions = false;
  late final InsertImageFromGallery insertImageFromGallery;
  late final InsertImageFromCamera insertImageFromCamera;
  double currentFontSize = 16;

  bool isBoldSelected = false;
  bool isItalicSelected = false;
  bool isCheckboxSelected = false;
  bool _isNumeredListSelected = false;

  @override
  void initState() {
    super.initState();

    insertImageFromGallery = InsertImageFromGallery(
      _controller,
      _editorFocusNode,
    );
    insertImageFromCamera = InsertImageFromCamera(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ignore: unused_element
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
    editorUtils.toggleAttribute(
      controller: _controller,
      attribute: quill.Attribute.bold,
      editorFocusNode: _editorFocusNode,
      clearAttributes: [quill.Attribute.italic],
    );
    setState(() {
      isBoldSelected = !isBoldSelected;
      if (isBoldSelected) isItalicSelected = false;
    });
  }

  void _toggleItalic() {
    editorUtils.toggleAttribute(
      controller: _controller,
      attribute: quill.Attribute.italic,
      editorFocusNode: _editorFocusNode,
      clearAttributes: [quill.Attribute.bold],
    );
    setState(() {
      isItalicSelected = !isItalicSelected;
      if (isItalicSelected) isBoldSelected = false;
    });
  }

  void _toggleCheckbox() {
    editorUtils.toggleCheckbox(
      controller: _controller,
      editorFocusNode: _editorFocusNode,
      isBoldSelected: isBoldSelected,
      isItalicSelected: isItalicSelected,
      setBoldSelected: (val) => setState(() => isBoldSelected = val),
      setItalicSelected: (val) => setState(() => isItalicSelected = val),
      setCheckboxSelected: (val) => setState(() => isCheckboxSelected = val),
    );
  }

  void _toggleNumberedList() {
    editorUtils.toggleNumberedList(
      controller: _controller,
      editorFocusNode: _editorFocusNode,
      isBoldSelected: isBoldSelected,
      isItalicSelected: isItalicSelected,
      isCheckboxSelected: isCheckboxSelected,
      setBoldSelected: (val) => setState(() => isBoldSelected = val),
      setItalicSelected: (val) => setState(() => isItalicSelected = val),
      setCheckboxSelected: (val) => setState(() => isCheckboxSelected = val),
    );

    setState(() {
      _isNumeredListSelected =
          _controller
              .getSelectionStyle()
              .attributes[quill.Attribute.list.key]
              ?.value ==
          'ordered';

      if (_isNumeredListSelected) {
        isItalicSelected = false;
        isBoldSelected = false;
      }
    });
  }

  void _toggleBulletedList() {
    final attrs = _controller.getSelectionStyle().attributes;
    final isBulletedList =
        attrs.containsKey(quill.Attribute.list.key) &&
        attrs[quill.Attribute.list.key]!.value == 'bullet';

    if (isBulletedList) {
      _controller.formatSelection(
        quill.Attribute.clone(quill.Attribute.list, null),
      );
    } else {
      _controller.formatSelection(quill.Attribute.ul);

      if (isBoldSelected) {
        _controller.formatSelection(
          quill.Attribute.clone(quill.Attribute.bold, null),
        );
        setState(() => isBoldSelected = false);
      }
      if (isItalicSelected) {
        _controller.formatSelection(
          quill.Attribute.clone(quill.Attribute.italic, null),
        );
        setState(() => isItalicSelected = false);
      }
      if (isCheckboxSelected) {
        _controller.formatSelection(
          quill.Attribute.clone(quill.Attribute.list, null),
        );
        setState(() => isCheckboxSelected = false);
      }
    }

    _editorFocusNode.requestFocus();

    setState(() {
      // обновляем буллет-состояние если хочешь добавить
    });
  }

  void _insertImage() async {
    final int oldPosition = _controller.selection.baseOffset;

    await insertImageFromGallery.insertImage();

    final newPosition = oldPosition + 1;

    _controller.document.insert(newPosition, '\n');

    _controller.updateSelection(
      TextSelection.collapsed(offset: newPosition + 1),
      quill.ChangeSource.local,
    );

    setState(() {});
  }

  Future<void> _insertImageFromCamera() async {
    final int oldPosition = _controller.selection.baseOffset;

    await insertImageFromCamera.insertImage();

    final newPosition = oldPosition + 1;

    _controller.document.insert(newPosition, '\n');

    _controller.updateSelection(
      TextSelection.collapsed(offset: newPosition + 1),
      quill.ChangeSource.local,
    );

    setState(() {});
  }

  void _onFontSizeChanged(double size) {
    final selection = _controller.selection;
    final sizeAttr = quill.Attribute.fromKeyValue('size', size.toString());

    if (!selection.isCollapsed) {
      // Меняем размер шрифта только если есть выделение
      _controller.formatSelection(sizeAttr);

      setState(() {
        currentFontSize = size;
      });
    }
    // Если выделения нет — ничего не делаем, размер не меняется
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final locale = Localizations.localeOf(context).languageCode;
    final showExtraButton = screenWidth > 400 && locale == 'en';

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
              final pickedDate = await pickDate(context);
              if (pickedDate == null) return;

              final pickedTime = await pickTime(context);
              if (pickedTime == null) return;

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
            label: Text(
              AppLocalizations.of(context)!.noteScreen_reminder,
              style: TextStyle(fontSize: 12),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: UndoRedoButton(
              icon: TransformFlip(
                flipX: true,
                flipY: true,
                child: Icon(Icons.subdirectory_arrow_right),
              ),
              onTap: () {
                if (_controller.hasUndo) {
                  _controller.undo();
                  print('Undo performed');
                }
              },
              onHold: () {
                if (_controller.hasUndo) {
                  _controller.undo();
                  print('Undo hold performed');
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: UndoRedoButton(
              icon: TransformFlip(
                flipX: false,
                flipY: true,
                child: Icon(Icons.subdirectory_arrow_right),
              ),
              onTap: () {
                if (_controller.hasRedo) {
                  _controller.redo();
                  print('Redo performed');
                }
              },
              onHold: () {
                if (_controller.hasRedo) {
                  _controller.redo();
                  print('Redo hold performed');
                }
              },
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
                  hintText: AppLocalizations.of(context)!.noteScreen_title,
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
                      onPressed: () async {
                        final result = await showAddNoteToCategoryDialog(
                          context,
                        );
                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Заметка будет добавлена в категорию',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.add_box_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.noteScreen_addToCategory,
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
                        scrollController: ScrollController(),
                        config: quill.QuillEditorConfig(
                          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                          placeholder: AppLocalizations.of(
                            context,
                          )!.noteScreen_startTyping,
                          customStyles: quill.DefaultStyles(
                            paragraph: quill.DefaultTextBlockStyle(
                              TextStyle(
                                fontSize: currentFontSize,
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
                              CustomCheckboxBuilder(),
                            ),
                          ),
                          autoFocus: true,
                        ),
                      ),
                    ),
                  ),

                  if (_showExtraOptions)
                    ExtraOptions(
                      isDark: isDark,
                      controller: _controller,
                      onToggleNumberedList: _toggleNumberedList,
                      onInsertImage: _insertImage,
                      onInsertCamera: _insertImageFromCamera,
                      onToggleBulletedList: _toggleBulletedList,
                      selectedFontSize: currentFontSize,
                      onFontSizeChanged: _onFontSizeChanged,
                    ),

                  // Custom Toolbar
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      left: 10,
                      right: 10,
                      bottom: 5,
                    ),
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
                                  if (showExtraButton)
                                    IconButton(
                                      highlightColor: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.15),
                                      icon: Icon(
                                        Icons.format_list_numbered,
                                        color: _isNumeredListSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Theme.of(context).hintColor,
                                      ),
                                      onPressed: _toggleNumberedList,
                                    ),

                                  if (showExtraButton)
                                    IconButton(
                                      highlightColor: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.15),
                                      icon: Icon(
                                        Icons.image,
                                        color: Theme.of(context).hintColor,
                                      ),
                                      onPressed: _insertImage,
                                    ),

                                  IconButton(
                                    highlightColor: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.15),
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
                                    highlightColor: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.15),
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
                                    highlightColor: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.15),
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
                                    highlightColor: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.15),
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

                          const SizedBox(width: 10),

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
                                    // ignore: deprecated_member_use
                                    Colors.white.withOpacity(0.2),
                                  ),
                                ),
                            onPressed: () {},
                            child: Text(
                              AppLocalizations.of(context)!.noteScreen_save,
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

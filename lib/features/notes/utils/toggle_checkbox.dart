import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';

void toggleCheckbox({
  required quill.QuillController controller,
  required FocusNode editorFocusNode,
  required bool isBoldSelected,
  required bool isItalicSelected,
  required void Function(bool) setBoldSelected,
  required void Function(bool) setItalicSelected,
  required void Function(bool) setCheckboxSelected,
}) {
  final attrs = controller.getSelectionStyle().attributes;
  final isCheckbox = attrs.containsKey(quill.Attribute.unchecked.key) ||
      attrs.containsKey(quill.Attribute.checked.key);

  if (isCheckbox) {
    controller.formatSelection(quill.Attribute.clone(quill.Attribute.list, null));
    setCheckboxSelected(false);
  } else {
    controller.formatSelection(quill.Attribute.unchecked);
    setCheckboxSelected(true);

    if (isBoldSelected) {
      controller.formatSelection(quill.Attribute.clone(quill.Attribute.bold, null));
      setBoldSelected(false);
    }
    if (isItalicSelected) {
      controller.formatSelection(quill.Attribute.clone(quill.Attribute.italic, null));
      setItalicSelected(false);
    }
  }
  editorFocusNode.requestFocus();
}
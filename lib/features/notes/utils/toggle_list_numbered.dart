import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';

void toggleNumberedList({
  required quill.QuillController controller,
  required FocusNode editorFocusNode,
  required bool isBoldSelected,
  required bool isItalicSelected,
  required bool isCheckboxSelected,
  required void Function(bool) setBoldSelected,
  required void Function(bool) setItalicSelected,
  required void Function(bool) setCheckboxSelected,
}) {
  final attrs = controller.getSelectionStyle().attributes;
  final isOrderedList = attrs.containsKey(quill.Attribute.list.key) &&
      attrs[quill.Attribute.list.key]!.value == 'ordered';

  if (isOrderedList) {
    controller.formatSelection(quill.Attribute.clone(quill.Attribute.list, null));
  } else {
    controller.formatSelection(quill.Attribute.ol);

    if (isBoldSelected) {
      controller.formatSelection(quill.Attribute.clone(quill.Attribute.bold, null));
      setBoldSelected(false);
    }
    if (isItalicSelected) {
      controller.formatSelection(quill.Attribute.clone(quill.Attribute.italic, null));
      setItalicSelected(false);
    }
    if (isCheckboxSelected) {
      controller.formatSelection(quill.Attribute.clone(quill.Attribute.list, null));
      setCheckboxSelected(false);
    }
  }
  editorFocusNode.requestFocus();
}

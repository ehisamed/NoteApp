import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';

void toggleAttribute({
  required quill.QuillController controller,
  required quill.Attribute attribute,
  required FocusNode editorFocusNode,
  List<quill.Attribute>? clearAttributes,
}) {
  final attrs = controller.getSelectionStyle().attributes;
  final isActive = attrs.containsKey(attribute.key);

  if (isActive) {
    controller.formatSelection(quill.Attribute.clone(attribute, null));
  } else {
    controller.formatSelection(attribute);
    if (clearAttributes != null) {
      for (var attr in clearAttributes) {
        if (controller.getSelectionStyle().attributes.containsKey(attr.key)) {
          controller.formatSelection(quill.Attribute.clone(attr, null));
        }
      }
    }
  }

  editorFocusNode.requestFocus();
}

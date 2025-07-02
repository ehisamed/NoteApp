import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class InsertImageFromGallery {
  final quill.QuillController controller;
  final FocusNode editorFocusNode;

  InsertImageFromGallery(this.controller, this.editorFocusNode);

  Future<bool> requestStoragePermission() async {
    if (await Permission.photos.isGranted) {
      return true;
    }
    final result = await Permission.photos.request();
    return result.isGranted;
  }

  Future<void> insertImage() async {
    bool permissionGranted = await requestStoragePermission();
    if (!permissionGranted) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    controller.replaceText(
      index < 0 ? 0 : index,
      length < 0 ? 0 : length,
      quill.BlockEmbed.image(pickedFile.path),
      null,
    );
    editorFocusNode.requestFocus();
  }
}

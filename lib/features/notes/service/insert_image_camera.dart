import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class InsertImageFromCamera {
  final quill.QuillController controller;

  InsertImageFromCamera(this.controller);

  Future<void> insertImage() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await File(photo.path).copy('${appDir.path}/$fileName');

      final index = controller.selection.baseOffset;
      final length = controller.selection.extentOffset - index;

      controller.replaceText(
        index,
        length,
        quill.BlockEmbed.image(savedImage.path),
        null,
      );
    } catch (e) {
      print('Ошибка вставки изображения с камеры: $e');
    }
  }
}

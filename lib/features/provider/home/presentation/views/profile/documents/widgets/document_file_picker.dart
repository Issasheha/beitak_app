// lib/features/provider/home/presentation/views/profile/documents/widgets/document_file_picker.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class DocumentFilePicker {
  static const int maxFilesPerDoc = 2;
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  static const List<String> allowedExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  static Future<List<File>> pickWithFilePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.isEmpty) return <File>[];

      final files = <File>[];
      for (final f in result.files) {
        final path = f.path;
        if (path == null) continue;
        final file = File(path);
        if (await file.exists()) files.add(file);
      }

      return files.take(maxFilesPerDoc).toList();
    } catch (_) {
      return <File>[];
    }
  }

  static Future<List<File>> pickUpToTwoFromGallery(ImagePicker picker) async {
    try {
      final list = await picker.pickMultiImage(imageQuality: 85);
      if (list.isNotEmpty) {
        return list.map((x) => File(x.path)).take(maxFilesPerDoc).toList();
      }
    } catch (_) {}

    final one = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (one == null) return <File>[];
    return <File>[File(one.path)];
  }

  static Future<List<File>> captureUpToTwoFromCamera(
    ImagePicker picker, {
    required Future<bool> Function() askAddMore,
  }) async {
    final result = <File>[];

    while (result.length < maxFilesPerDoc) {
      final xFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (xFile == null) break;

      result.add(File(xFile.path));

      if (result.length >= maxFilesPerDoc) break;

      final addMore = await askAddMore();
      if (!addMore) break;
    }

    return result;
  }

  static Future<String?> validateFiles(List<File> files) async {
    final trimmed = files.take(maxFilesPerDoc).toList();
    if (trimmed.isEmpty) return 'لم يتم اختيار أي ملف';

    for (final f in trimmed) {
      try {
        if (!await f.exists()) return 'الملف غير موجود';
        final bytes = await f.length();
        if (bytes > maxFileSizeBytes) {
          return 'يوجد ملف حجمه أكبر من 5MB. رجاءً اختر ملف أصغر.';
        }
      } catch (_) {
        return 'تعذر قراءة الملف، حاول اختيار ملف آخر';
      }
    }

    return null; // ok
  }
}

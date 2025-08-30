import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  // رفع ملف إلى Supabase Storage
  Future<String?> uploadFile({
    required File file,
    required String bucket,
    String? folder,
  }) async {
    try {
      final fileName = path.basename(file.path);
      final filePath = folder != null ? '$folder/$fileName' : fileName;

      await _supabase.storage.from(bucket).upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final url = _supabase.storage.from(bucket).getPublicUrl(filePath);
      return url;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // رفع بيانات ملف (Uint8List)
  Future<String?> uploadFileData({
    required Uint8List fileData,
    required String fileName,
    required String bucket,
    String? folder,
  }) async {
    try {
      final filePath = folder != null ? '$folder/$fileName' : fileName;

      await _supabase.storage.from(bucket).uploadBinary(
            filePath,
            fileData,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final url = _supabase.storage.from(bucket).getPublicUrl(filePath);
      return url;
    } catch (e) {
      print('Error uploading file data: $e');
      return null;
    }
  }

  // حذف ملف من Supabase Storage
  Future<bool> deleteFile({
    required String filePath,
    required String bucket,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([filePath]);
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  // اختيار ملف من الجهاز
  Future<File?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        return file;
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  // اختيار صورة من الكاميرا
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // اختيار صورة من المعرض
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // رفع صورة كورس
  Future<String?> uploadCourseImage(File imageFile) async {
    return await uploadFile(
      file: imageFile,
      bucket: 'course-images',
      folder: 'courses',
    );
  }

  // رفع فيديو درس
  Future<String?> uploadLessonVideo(File videoFile) async {
    return await uploadFile(
      file: videoFile,
      bucket: 'lesson-videos',
      folder: 'lessons',
    );
  }

  // رفع ملف PDF
  Future<String?> uploadPDF(File pdfFile) async {
    return await uploadFile(
      file: pdfFile,
      bucket: 'lesson-files',
      folder: 'pdfs',
    );
  }

  // رفع ملف صوتي
  Future<String?> uploadAudio(File audioFile) async {
    return await uploadFile(
      file: audioFile,
      bucket: 'lesson-files',
      folder: 'audio',
    );
  }

  // الحصول على حجم الملف
  String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // التحقق من نوع الملف
  bool isValidFileType(String fileName, List<String> allowedExtensions) {
    final extension = path.extension(fileName).toLowerCase();
    return allowedExtensions.contains(extension);
  }

  // الحصول على أيقونة الملف حسب نوعه
  String getFileIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.pdf':
        return '📄';
      case '.doc':
      case '.docx':
        return '📝';
      case '.xls':
      case '.xlsx':
        return '📊';
      case '.ppt':
      case '.pptx':
        return '📋';
      case '.mp4':
      case '.avi':
      case '.mov':
        return '🎥';
      case '.mp3':
      case '.wav':
        return '🎵';
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return '🖼️';
      case '.zip':
      case '.rar':
        return '📦';
      default:
        return '📎';
    }
  }
}

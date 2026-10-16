import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Copies picked profile photos into app-owned storage so their paths persist.
class ProfilePhotoService {
  final ImagePicker _picker;

  ProfilePhotoService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  Future<String?> pickAndSave({
    required ImageSource source,
    required String userId,
  }) async {
    final photo = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (photo == null) return null;

    final documents = await getApplicationDocumentsDirectory();
    final fileName = photo.path.split(RegExp(r'[/\\]')).last;
    final extensionIndex = fileName.lastIndexOf('.');
    final extension =
        extensionIndex <= 0 ? '.jpg' : fileName.substring(extensionIndex);
    final destination = File(
        '${documents.path}${Platform.pathSeparator}profile_${userId}_${DateTime.now().microsecondsSinceEpoch}$extension');
    await File(photo.path).copy(destination.path);
    return destination.path;
  }

  Future<void> remove(String photoPath) async {
    final photo = File(photoPath);
    if (await photo.exists()) await photo.delete();
  }
}

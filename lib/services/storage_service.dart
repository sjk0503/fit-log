import 'dart:convert';
import 'dart:io';

import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../models/ootd_photo.dart';

class StorageService {
  static const String _photosDirName = 'ootd_photos';
  static const String _metadataFileName = 'photos_metadata.json';
  static const _uuid = Uuid();

  Directory? _photosDir;
  File? _metadataFile;

  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _photosDir = Directory(path.join(appDir.path, _photosDirName));
    _metadataFile = File(path.join(appDir.path, _metadataFileName));

    if (!await _photosDir!.exists()) {
      await _photosDir!.create(recursive: true);
    }
  }

  Future<OotdPhoto> savePhoto(File imageFile) async {
    if (_photosDir == null) await initialize();

    final id = _uuid.v4();
    final timestamp = DateTime.now();
    final fileName = '${timestamp.millisecondsSinceEpoch}_$id.jpg';
    final savedPath = path.join(_photosDir!.path, fileName);

    await imageFile.copy(savedPath);

    // Save to device gallery
    await ImageGallerySaverPlus.saveFile(savedPath, name: 'FitLog_$fileName');

    final photo = OotdPhoto(
      id: id,
      filePath: savedPath,
      createdAt: timestamp,
    );

    await _addPhotoMetadata(photo);

    return photo;
  }

  Future<List<OotdPhoto>> loadPhotos() async {
    if (_metadataFile == null) await initialize();

    if (!await _metadataFile!.exists()) {
      return [];
    }

    try {
      final content = await _metadataFile!.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      final photos = jsonList
          .map((json) => OotdPhoto.fromJson(json as Map<String, dynamic>))
          .where((photo) => photo.exists)
          .toList();

      // Sort by date descending (newest first)
      photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return photos;
    } catch (e) {
      return [];
    }
  }

  Future<void> deletePhoto(OotdPhoto photo) async {
    if (_metadataFile == null) await initialize();

    // Delete file
    if (photo.exists) {
      await photo.file.delete();
    }

    // Update metadata
    final photos = await loadPhotos();
    photos.removeWhere((p) => p.id == photo.id);
    await _saveMetadata(photos);
  }

  Future<void> _addPhotoMetadata(OotdPhoto photo) async {
    final photos = await loadPhotos();
    photos.insert(0, photo);
    await _saveMetadata(photos);
  }

  Future<void> _saveMetadata(List<OotdPhoto> photos) async {
    if (_metadataFile == null) await initialize();

    final jsonList = photos.map((p) => p.toJson()).toList();
    await _metadataFile!.writeAsString(json.encode(jsonList));
  }

  Future<File> saveLayoutImage(File imageFile) async {
    if (_photosDir == null) await initialize();

    final timestamp = DateTime.now();
    final fileName = 'layout_${timestamp.millisecondsSinceEpoch}.jpg';
    final savedPath = path.join(_photosDir!.path, fileName);

    await imageFile.copy(savedPath);

    // Save to device gallery
    await ImageGallerySaverPlus.saveFile(savedPath, name: 'FitLog_Layout_$fileName');

    return File(savedPath);
  }
}

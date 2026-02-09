import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/ootd_photo.dart';
import '../utils/constants.dart';

class ImageService {
  static const int layoutOutputSize = 2048;

  Future<File> createLayoutImage({
    required List<OotdPhoto> photos,
    required LayoutType layoutType,
    Color backgroundColor = Colors.white,
  }) async {
    final cellWidth = layoutOutputSize ~/ layoutType.columns;
    final cellHeight = layoutOutputSize ~/ layoutType.rows;

    final outputImage = img.Image(
      width: layoutOutputSize,
      height: cellHeight * layoutType.rows,
    );

    // Fill background
    img.fill(
      outputImage,
      color: img.ColorRgb8(
        (backgroundColor.r * 255).round(),
        (backgroundColor.g * 255).round(),
        (backgroundColor.b * 255).round(),
      ),
    );

    // Place photos in grid
    for (int i = 0; i < layoutType.totalCells && i < photos.length; i++) {
      final row = i ~/ layoutType.columns;
      final col = i % layoutType.columns;

      final photoFile = photos[i].file;
      if (!photoFile.existsSync()) continue;

      final photoBytes = await photoFile.readAsBytes();
      final photoImage = img.decodeImage(photoBytes);

      if (photoImage != null) {
        // Crop to square and resize
        final croppedPhoto = _cropToSquare(photoImage);
        final resizedPhoto = img.copyResize(
          croppedPhoto,
          width: cellWidth,
          height: cellHeight,
        );

        // Composite onto output
        img.compositeImage(
          outputImage,
          resizedPhoto,
          dstX: col * cellWidth,
          dstY: row * cellHeight,
        );
      }
    }

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final outputPath = path.join(
      tempDir.path,
      'layout_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(img.encodeJpg(outputImage, quality: 95));

    return outputFile;
  }

  img.Image _cropToSquare(img.Image image) {
    final size = image.width < image.height ? image.width : image.height;
    final x = (image.width - size) ~/ 2;
    final y = (image.height - size) ~/ 2;

    return img.copyCrop(
      image,
      x: x,
      y: y,
      width: size,
      height: size,
    );
  }

  Future<Uint8List?> loadImageBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
    return null;
  }
}

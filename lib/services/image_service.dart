import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/widgets.dart' show Color;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/ootd_photo.dart';
import '../utils/constants.dart';

class ImageService {
  /// Composes [photos] into a single grid image and returns the saved file
  /// (in temp dir; caller persists via StorageService).
  ///
  /// Options:
  ///  - [resolution]: standard (~2K square) or high (~4K square)
  ///  - [tonePreset]: tone-shift applied to the whole composite
  ///  - [watermark]: small "fit-log" mark in the bottom-right corner
  ///  - [backgroundColor]: padding color around / between cells
  Future<File> createLayoutImage({
    required List<OotdPhoto> photos,
    required LayoutType layoutType,
    Color backgroundColor = const Color(0xFFFAF8F5),
    ExportResolution resolution = ExportResolution.standard,
    TonePreset tonePreset = TonePreset.none,
    bool watermark = true,
  }) async {
    final outputW = resolution.outputSize;
    final cellWidth = outputW ~/ layoutType.columns;
    final cellHeight = outputW ~/ layoutType.columns;
    final outputH = cellHeight * layoutType.rows;

    final outputImage = img.Image(width: outputW, height: outputH);

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

      try {
        final photoBytes = await photoFile.readAsBytes();
        final photoImage = img.decodeImage(photoBytes);
        if (photoImage == null) continue;

        final cropped = _cropToSquare(photoImage);
        final resized = img.copyResize(
          cropped,
          width: cellWidth,
          height: cellHeight,
          interpolation: img.Interpolation.average,
        );

        img.compositeImage(
          outputImage,
          resized,
          dstX: col * cellWidth,
          dstY: row * cellHeight,
        );
      } catch (e) {
        debugPrint('cell $i decode/composite failed: $e');
      }
    }

    // Apply tone preset to the whole canvas
    final toned = _applyTone(outputImage, tonePreset);

    // Apply watermark
    final stamped = watermark ? _applyWatermark(toned) : toned;

    // Save
    final tempDir = await getTemporaryDirectory();
    final outputPath = path.join(
      tempDir.path,
      'layout_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(
      img.encodeJpg(stamped, quality: resolution.jpegQuality),
    );
    return outputFile;
  }

  img.Image _cropToSquare(img.Image image) {
    final size = image.width < image.height ? image.width : image.height;
    final x = (image.width - size) ~/ 2;
    final y = (image.height - size) ~/ 2;
    return img.copyCrop(image, x: x, y: y, width: size, height: size);
  }

  img.Image _applyTone(img.Image image, TonePreset preset) {
    if (preset == TonePreset.none) return image;

    // Mono: full desaturation.
    if (preset == TonePreset.mono) {
      return img.grayscale(image);
    }

    img.Image work = image;

    // Saturation
    if (preset.saturation != 0) {
      work = img.adjustColor(work, saturation: 1.0 + preset.saturation);
    }

    // Contrast (image package treats 100 = unchanged)
    if (preset.contrast != 0) {
      work = img.contrast(work, contrast: 100 + preset.contrast * 100);
    }

    // Warmth: shift the red channel up and the blue channel down (or vice
    // versa) to approximate a temperature shift without doing real Lab math.
    if (preset.warmth != 0) {
      final redShift = (preset.warmth * 24).round();
      final blueShift = (-preset.warmth * 24).round();
      work = img.colorOffset(work, red: redShift, blue: blueShift);
    }

    // Vignette
    if (preset.vignette > 0) {
      work = img.vignette(
        work,
        start: 1.0 - preset.vignette,
        end: 1.0,
        amount: preset.vignette * 1.5,
      );
    }

    return work;
  }

  img.Image _applyWatermark(img.Image image) {
    // Small text mark in the bottom-right corner. Uses the bundled bitmap
    // font from the `image` package — kept intentionally subtle so it does
    // not fight the photo content.
    final font = img.arial24;
    const text = 'fit-log';
    // Estimate text width for the bundled bitmap font (~ 11 px per char).
    final approxW = text.length * 11;
    final approxH = 24;
    final padding = (image.width * 0.02).round().clamp(12, 48);

    img.drawString(
      image,
      text,
      font: font,
      x: image.width - approxW - padding,
      y: image.height - approxH - padding,
      color: img.ColorRgba8(255, 255, 255, 180),
    );

    return image;
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

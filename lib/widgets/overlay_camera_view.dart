import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/ootd_photo.dart';
import '../utils/constants.dart';

class OverlayCameraView extends StatelessWidget {
  final CameraController? cameraController;
  final OotdPhoto? referencePhoto;
  final double opacity;
  final VoidCallback? onSelectReference;

  const OverlayCameraView({
    super.key,
    required this.cameraController,
    this.referencePhoto,
    this.opacity = 0.5,
    this.onSelectReference,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview (bottom layer)
        _buildCameraPreview(),

        // Reference photo overlay (top layer)
        if (referencePhoto != null && referencePhoto!.exists)
          Opacity(
            opacity: opacity,
            child: Image.file(
              referencePhoto!.file,
              fit: BoxFit.cover,
            ),
          ),

        // Overlay indicator when no reference
        if (referencePhoto == null)
          Positioned(
            top: AppSizes.paddingLarge,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onSelectReference,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  child: Text(
                    AppLocalizations.of(context).selectAReferencePhoto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: cameraController!.value.previewSize!.height,
            height: cameraController!.value.previewSize!.width,
            child: CameraPreview(cameraController!),
          ),
        ),
      ),
    );
  }
}

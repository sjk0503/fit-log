import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/ootd_photo.dart';
import '../utils/constants.dart';

class SplitCameraView extends StatelessWidget {
  final CameraController? cameraController;
  final OotdPhoto? referencePhoto;
  final bool isLeftReference;
  final VoidCallback? onSwapSides;
  final VoidCallback? onSelectReference;

  const SplitCameraView({
    super.key,
    required this.cameraController,
    this.referencePhoto,
    this.isLeftReference = true,
    this.onSwapSides,
    this.onSelectReference,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: isLeftReference
              ? _buildReferencePanel(context)
              : _buildCameraPanel(),
        ),
        Container(
          width: 2,
          color: AppColors.primary,
        ),
        Expanded(
          child: isLeftReference
              ? _buildCameraPanel()
              : _buildReferencePanel(context),
        ),
      ],
    );
  }

  Widget _buildReferencePanel(BuildContext context) {
    if (referencePhoto == null || !referencePhoto!.exists) {
      final l10n = AppLocalizations.of(context);
      return GestureDetector(
        onTap: onSelectReference,
        child: Container(
          color: AppColors.background,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  l10n.selectReference,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onSelectReference,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: Image.file(referencePhoto!.file),
        ),
      ),
    );
  }

  Widget _buildCameraPanel() {
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

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: cameraController!.value.previewSize!.height,
          height: cameraController!.value.previewSize!.width,
          child: CameraPreview(cameraController!),
        ),
      ),
    );
  }
}

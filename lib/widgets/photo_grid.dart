import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/ootd_photo.dart';
import '../utils/constants.dart';

class PhotoGrid extends StatelessWidget {
  final List<OotdPhoto> photos;
  final Function(OotdPhoto)? onPhotoTap;
  final Function(OotdPhoto)? onPhotoLongPress;
  final int crossAxisCount;
  final double spacing;

  const PhotoGrid({
    super.key,
    required this.photos,
    this.onPhotoTap,
    this.onPhotoLongPress,
    this.crossAxisCount = 3,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              l10n.noPhotos,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              l10n.takeFirstPhoto,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return PhotoGridItem(
          photo: photo,
          onTap: () => onPhotoTap?.call(photo),
          onLongPress: () => onPhotoLongPress?.call(photo),
        );
      },
    );
  }
}

class PhotoGridItem extends StatelessWidget {
  final OotdPhoto photo;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PhotoGridItem({
    super.key,
    required this.photo,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Hero(
        tag: 'photo_${photo.id}',
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
          ),
          child: photo.exists
              ? Image.file(
                  photo.file,
                  fit: BoxFit.cover,
                  cacheWidth: 300,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.background,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                )
              : Container(
                  color: AppColors.background,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
      ),
    );
  }
}

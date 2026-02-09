import 'package:flutter/material.dart';

import '../models/ootd_photo.dart';
import '../utils/constants.dart';

class LayoutComposer extends StatelessWidget {
  final List<OotdPhoto> selectedPhotos;
  final LayoutType layoutType;
  final Color backgroundColor;
  final Function(int)? onCellTap;

  const LayoutComposer({
    super.key,
    required this.selectedPhotos,
    required this.layoutType,
    this.backgroundColor = Colors.white,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: layoutType.columns / layoutType.rows,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layoutType.columns,
            ),
            itemCount: layoutType.totalCells,
            itemBuilder: (context, index) {
              return _buildCell(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    final hasPhoto = index < selectedPhotos.length;
    final photo = hasPhoto ? selectedPhotos[index] : null;

    return GestureDetector(
      onTap: () => onCellTap?.call(index),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: hasPhoto && photo!.exists
            ? Image.file(
                photo.file,
                fit: BoxFit.cover,
                cacheWidth: 400,
              )
            : Center(
                child: Icon(
                  Icons.add,
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  size: 32,
                ),
              ),
      ),
    );
  }
}

class LayoutTypeSelector extends StatelessWidget {
  final LayoutType selectedType;
  final Function(LayoutType) onSelected;

  const LayoutTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: LayoutType.values.map((type) {
        final isSelected = type == selectedType;
        return GestureDetector(
          onTap: () => onSelected(type),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGridPreview(type, isSelected),
                const SizedBox(height: 4),
                Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridPreview(LayoutType type, bool isSelected) {
    final color = isSelected ? Colors.white : AppColors.textSecondary;
    return SizedBox(
      width: 32,
      height: 32 * type.rows / type.columns,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: type.columns,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: type.totalCells,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              border: Border.all(color: color, width: 0.5),
            ),
          );
        },
      ),
    );
  }
}

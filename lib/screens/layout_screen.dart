import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/ootd_photo.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/layout_composer.dart';

class LayoutScreen extends StatefulWidget {
  final List<OotdPhoto> initialPhotos;
  final List<OotdPhoto> allPhotos;

  const LayoutScreen({
    super.key,
    required this.initialPhotos,
    required this.allPhotos,
  });

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  final ImageService _imageService = ImageService();
  final StorageService _storageService = StorageService();

  late List<OotdPhoto> _selectedPhotos;
  LayoutType _layoutType = LayoutType.grid2x2;
  Color _backgroundColor = Colors.white;
  bool _isSaving = false;

  final List<Color> _backgroundColors = [
    Colors.white,
    Colors.black,
    const Color(0xFFF5F5F5),
    const Color(0xFFE0E0E0),
    AppColors.primary.withValues(alpha: 0.1),
  ];

  @override
  void initState() {
    super.initState();
    _selectedPhotos = List.from(widget.initialPhotos);
    _storageService.initialize();
  }

  void _onCellTap(int index) async {
    final photo = await _showPhotoSelector();
    if (photo != null) {
      setState(() {
        if (index < _selectedPhotos.length) {
          _selectedPhotos[index] = photo;
        } else {
          while (_selectedPhotos.length < index) {
            _selectedPhotos.add(widget.allPhotos.first);
          }
          _selectedPhotos.add(photo);
        }
      });
    }
  }

  Future<OotdPhoto?> _showPhotoSelector() async {
    return showModalBottomSheet<OotdPhoto>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Text(
                  l10n.selectPhoto,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: widget.allPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = widget.allPhotos[index];
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, photo),
                      child: Image.file(
                        photo.file,
                        fit: BoxFit.cover,
                        cacheWidth: 200,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveLayout() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectAtLeastOnePhoto)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final layoutImage = await _imageService.createLayoutImage(
        photos: _selectedPhotos,
        layoutType: _layoutType,
        backgroundColor: _backgroundColor,
      );

      await _storageService.saveLayoutImage(layoutImage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.layoutSavedToGallery),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToSaveLayout}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.createLayout,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveLayout,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    l10n.save,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Layout preview
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: LayoutComposer(
                  selectedPhotos: _selectedPhotos,
                  layoutType: _layoutType,
                  backgroundColor: _backgroundColor,
                  onCellTap: _onCellTap,
                ),
              ),
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.layout,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                LayoutTypeSelector(
                  selectedType: _layoutType,
                  onSelected: (type) {
                    setState(() => _layoutType = type);
                  },
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                Text(
                  l10n.background,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Row(
                  children: _backgroundColors.map((color) {
                    final isSelected = color == _backgroundColor;
                    return GestureDetector(
                      onTap: () => setState(() => _backgroundColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 20,
                                color: color == Colors.white || color == const Color(0xFFF5F5F5)
                                    ? AppColors.primary
                                    : Colors.white,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

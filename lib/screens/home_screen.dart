import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/ootd_photo.dart';
import '../services/locale_service.dart';
import '../services/storage_service.dart';
import '../services/tutorial_service.dart';
import '../utils/constants.dart';
import '../widgets/photo_grid.dart';
import '../widgets/tutorial_overlay.dart';
import 'camera_screen.dart';
import 'layout_screen.dart';
import 'photo_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final TutorialService _tutorialService = TutorialService();
  final GlobalKey _languageKey = GlobalKey();
  final GlobalKey _cameraFabKey = GlobalKey();
  List<OotdPhoto> _photos = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  bool _showTutorial = false;
  final Set<String> _selectedPhotoIds = {};

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final shouldShow = await _tutorialService.shouldShowHomeTutorial();
    if (shouldShow && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      await _storageService.initialize();
      final photos = await _storageService.loadPhotos();
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToLoadPhotos}: $e')),
        );
      }
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedPhotoIds.clear();
      }
    });
  }

  void _togglePhotoSelection(OotdPhoto photo) {
    setState(() {
      if (_selectedPhotoIds.contains(photo.id)) {
        _selectedPhotoIds.remove(photo.id);
      } else {
        _selectedPhotoIds.add(photo.id);
      }
    });
  }

  Future<void> _deleteSelectedPhotos() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePhotos),
        content: Text(l10n.deleteSelectedPhotos(_selectedPhotoIds.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final id in _selectedPhotoIds) {
        final photo = _photos.firstWhere((p) => p.id == id);
        await _storageService.deletePhoto(photo);
      }
      _toggleSelectionMode();
      _loadPhotos();
    }
  }

  void _openCamera({OotdPhoto? referencePhoto}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(referencePhoto: referencePhoto),
      ),
    );
    if (result == true) {
      _loadPhotos();
    }
  }

  void _openLayout() async {
    final selectedPhotos = _selectedPhotoIds
        .map((id) => _photos.firstWhere((p) => p.id == id))
        .toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LayoutScreen(
          initialPhotos: selectedPhotos.isNotEmpty ? selectedPhotos : _photos.take(4).toList(),
          allPhotos: _photos,
        ),
      ),
    );

    if (_isSelectionMode) {
      _toggleSelectionMode();
    }
  }

  void _showPhotoDetail(OotdPhoto photo) {
    if (_isSelectionMode) {
      _togglePhotoSelection(photo);
      return;
    }

    final index = _photos.indexOf(photo);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(
          photos: _photos,
          initialIndex: index >= 0 ? index : 0,
          onUseAsReference: (p) => _openCamera(referencePhoto: p),
          onDelete: (p) async {
            await _storageService.deletePhoto(p);
            _loadPhotos();
          },
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final localeService = LocaleService();
    final currentLocale = localeService.locale;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        final options = <_LanguageOption>[
          _LanguageOption(null, l10n.systemDefault, ''),
          _LanguageOption(const Locale('en'), 'English', ''),
          _LanguageOption(const Locale('ko'), '한국어', ''),
          _LanguageOption(const Locale('ja'), '日本語', ''),
          _LanguageOption(const Locale('zh'), '中文', ''),
        ];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.language,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...options.map((option) {
                final isSelected = option.locale?.languageCode ==
                    currentLocale?.languageCode;
                final isSystemDefault = option.locale == null && currentLocale == null;
                final selected = isSelected || isSystemDefault;

                return ListTile(
                  title: Text(option.label),
                  trailing: selected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    localeService.setLocale(option.locale);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final scaffold = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: _isSelectionMode
            ? null
            : IconButton(
                key: _languageKey,
                icon: const Icon(Icons.language, color: AppColors.textPrimary),
                onPressed: _showLanguageSelector,
              ),
        title: Text(
          _isSelectionMode
              ? l10n.nSelected(_selectedPhotoIds.length)
              : l10n.appName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.grid_view, color: AppColors.primary),
              onPressed: _selectedPhotoIds.isNotEmpty ? _openLayout : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _selectedPhotoIds.isNotEmpty ? _deleteSelectedPhotos : null,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: _toggleSelectionMode,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.grid_view, color: AppColors.textPrimary),
              onPressed: _photos.isNotEmpty ? _openLayout : null,
            ),
            IconButton(
              icon: const Icon(Icons.checklist, color: AppColors.textPrimary),
              onPressed: _photos.isNotEmpty ? _toggleSelectionMode : null,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadPhotos,
              color: AppColors.primary,
              child: _isSelectionMode
                  ? _buildSelectionGrid()
                  : PhotoGrid(
                      photos: _photos,
                      onPhotoTap: _showPhotoDetail,
                      onPhotoLongPress: (photo) {
                        _toggleSelectionMode();
                        _togglePhotoSelection(photo);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        key: _cameraFabKey,
        onPressed: () => _openCamera(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );

    if (_showTutorial) {
      return Stack(
        children: [
          scaffold,
          TutorialOverlay(
            steps: [
              TutorialStep(
                targetKey: _languageKey,
                message: l10n.tutorialChangeLanguage,
              ),
              TutorialStep(
                targetKey: _cameraFabKey,
                message: l10n.tutorialTakePhoto,
              ),
            ],
            onComplete: () {
              _tutorialService.completeHomeTutorial();
              setState(() => _showTutorial = false);
            },
          ),
        ],
      );
    }

    return scaffold;
  }

  Widget _buildSelectionGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        final isSelected = _selectedPhotoIds.contains(photo.id);
        return GestureDetector(
          onTap: () => _togglePhotoSelection(photo),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                photo.file,
                fit: BoxFit.cover,
                cacheWidth: 300,
              ),
              if (isSelected)
                Container(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption {
  final Locale? locale;
  final String label;
  final String subtitle;

  _LanguageOption(this.locale, this.label, this.subtitle);
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/ootd_photo.dart';
import '../services/camera_service.dart';
import '../services/storage_service.dart';
import '../services/tutorial_service.dart';
import '../utils/constants.dart';
import '../utils/permissions.dart';
import '../widgets/overlay_camera_view.dart';
import '../widgets/split_camera_view.dart';
import '../widgets/tutorial_overlay.dart';

class CameraScreen extends StatefulWidget {
  final OotdPhoto? referencePhoto;

  const CameraScreen({
    super.key,
    this.referencePhoto,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final StorageService _storageService = StorageService();
  final TutorialService _tutorialService = TutorialService();
  final GlobalKey _modeToggleKey = GlobalKey();
  final GlobalKey _captureKey = GlobalKey();
  final GlobalKey _swapKey = GlobalKey();

  CameraMode _currentMode = CameraMode.split;
  OotdPhoto? _referencePhoto;
  double _overlayOpacity = 0.3;
  bool _isLeftReference = true;
  bool _isCapturing = false;
  bool _hasPermission = false;
  String? _errorMessage;
  FlashMode _flashMode = FlashMode.off;
  bool _photosTaken = false;
  bool _showTutorial = false;
  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _referencePhoto = widget.referencePhoto;
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final hasPermission = await PermissionUtils.requestCameraPermission();
    if (!hasPermission) {
      setState(() {
        _hasPermission = false;
        _errorMessage = null;
      });
      return;
    }

    await PermissionUtils.requestStoragePermission();

    try {
      await _cameraService.initialize();
      await _cameraService.setFlashMode(_flashMode);
      await _storageService.initialize();
      setState(() {
        _hasPermission = true;
        _errorMessage = null;
      });
      _checkTutorial();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _checkTutorial() async {
    final shouldShow = await _tutorialService.shouldShowCameraTutorial();
    if (shouldShow && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _takePicture() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final file = await _cameraService.takePicture();
      if (file != null) {
        await _storageService.savePhoto(file);
        _photosTaken = true;
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.photoSaved),
              duration: const Duration(milliseconds: 800),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToSavePhoto}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _currentMode = _currentMode == CameraMode.split
          ? CameraMode.overlay
          : CameraMode.split;
    });
  }

  void _swapSides() {
    setState(() {
      _isLeftReference = !_isLeftReference;
    });
  }

  Future<void> _cycleFlashMode() async {
    final next = switch (_flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };
    await _cameraService.setFlashMode(next);
    setState(() => _flashMode = next);
  }

  IconData _flashIcon() {
    return switch (_flashMode) {
      FlashMode.off => Icons.flash_off,
      FlashMode.auto => Icons.flash_auto,
      FlashMode.always => Icons.flash_on,
      _ => Icons.flash_off,
    };
  }

  void _handleFocusTap(TapDownDetails details, BoxConstraints constraints) {
    final dx = details.localPosition.dx / constraints.maxWidth;
    final dy = details.localPosition.dy / constraints.maxHeight;
    final point = Offset(dx.clamp(0.0, 1.0), dy.clamp(0.0, 1.0));

    _cameraService.setFocusPoint(point);

    setState(() {
      _focusPoint = details.localPosition;
      _showFocusIndicator = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showFocusIndicator = false);
      }
    });
  }

  Future<void> _selectReferencePhoto() async {
    final photos = await _storageService.loadPhotos();
    if (!mounted || photos.isEmpty) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noPhotosAvailable)),
        );
      }
      return;
    }

    final selected = await showModalBottomSheet<OotdPhoto>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.selectReferencePhoto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, photo),
                      child: Image.file(
                        photo.file,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
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

    if (selected != null && mounted) {
      setState(() {
        _referencePhoto = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scaffold = Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildCameraView()),
            if (_currentMode == CameraMode.overlay) _buildOpacitySlider(),
            _buildBottomControls(),
          ],
        ),
      ),
    );

    if (_showTutorial) {
      return Stack(
        children: [
          scaffold,
          TutorialOverlay(
            steps: [
              TutorialStep(
                targetKey: _modeToggleKey,
                message: l10n.tutorialSwitchMode,
              ),
              TutorialStep(
                targetKey: _captureKey,
                message: l10n.tutorialCapture,
              ),
              TutorialStep(
                targetKey: _swapKey,
                message: l10n.tutorialSwapSides,
              ),
            ],
            onComplete: () {
              _tutorialService.completeCameraTutorial();
              setState(() => _showTutorial = false);
            },
          ),
        ],
      );
    }

    return scaffold;
  }

  Widget _buildTopBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.paddingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context, _photosTaken),
                ),
                IconButton(
                  icon: Icon(_flashIcon(), color: Colors.white),
                  onPressed: _hasPermission ? _cycleFlashMode : null,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            child: Text(
              _currentMode == CameraMode.split
                  ? l10n.splitMode
                  : l10n.overlayMode,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.cameraswitch, color: Colors.white),
                  onPressed: _cameraService.hasMultipleCameras
                      ? () async {
                          await _cameraService.switchCamera();
                          await _cameraService.setFlashMode(_flashMode);
                          setState(() {});
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_hasPermission || _errorMessage != null) {
      final l10n = AppLocalizations.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              _errorMessage ?? l10n.cameraPermissionRequired,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            ElevatedButton(
              onPressed: _initializeCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    final cameraView = _currentMode == CameraMode.split
        ? SplitCameraView(
            cameraController: _cameraService.controller,
            referencePhoto: _referencePhoto,
            isLeftReference: _isLeftReference,
            onSwapSides: _swapSides,
            onSelectReference: _selectReferencePhoto,
          )
        : OverlayCameraView(
            cameraController: _cameraService.controller,
            referencePhoto: _referencePhoto,
            opacity: _overlayOpacity,
            onSelectReference: _selectReferencePhoto,
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => _handleFocusTap(details, constraints),
          child: Stack(
            children: [
              cameraView,
              if (_showFocusIndicator && _focusPoint != null)
                Positioned(
                  left: _focusPoint!.dx - 30,
                  top: _focusPoint!.dy - 30,
                  child: IgnorePointer(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpacitySlider() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLarge,
        vertical: AppSizes.paddingSmall,
      ),
      child: Row(
        children: [
          const Icon(Icons.opacity, color: Colors.white54, size: 20),
          Expanded(
            child: Slider(
              value: _overlayOpacity,
              max: 0.5,
              onChanged: (value) {
                setState(() => _overlayOpacity = value);
              },
              activeColor: AppColors.primary,
              inactiveColor: Colors.white24,
            ),
          ),
          Text(
            '${(_overlayOpacity * 100).round()}%',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mode toggle
          IconButton(
            key: _modeToggleKey,
            onPressed: _toggleMode,
            icon: Icon(
              _currentMode == CameraMode.split
                  ? Icons.layers
                  : Icons.view_column,
              color: Colors.white,
              size: 28,
            ),
          ),
          // Capture button
          GestureDetector(
            key: _captureKey,
            onTap: _hasPermission && !_isCapturing ? _takePicture : null,
            child: Container(
              width: AppSizes.captureButtonSize,
              height: AppSizes.captureButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isCapturing ? Colors.grey : AppColors.primary,
                ),
                child: _isCapturing
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          // Swap sides (only for split mode)
          IconButton(
            key: _swapKey,
            onPressed: _currentMode == CameraMode.split ? _swapSides : null,
            icon: Icon(
              Icons.swap_horiz,
              color: _currentMode == CameraMode.split
                  ? Colors.white
                  : Colors.white24,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

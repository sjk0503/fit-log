import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import '../design/design.dart';
import '../models/ootd_photo.dart';
import '../services/camera_service.dart';
import '../services/storage_service.dart';
import '../services/tutorial_service.dart';
import '../utils/constants.dart';
import '../utils/permissions.dart';

class CameraScreen extends StatefulWidget {
  final OotdPhoto? referencePhoto;

  const CameraScreen({super.key, this.referencePhoto});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final StorageService _storageService = StorageService();
  final TutorialService _tutorialService = TutorialService();

  CameraMode _currentMode = CameraMode.split;
  OotdPhoto? _referencePhoto;
  double _overlayOpacity = 0.45; // 0..1
  bool _isLeftReference = true;
  bool _isCapturing = false;
  bool _hasPermission = false;
  String? _errorMessage;
  FlashMode _flashMode = FlashMode.off;
  bool _photosTaken = false;
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
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _hasPermission = true;
        _errorMessage = null;
      });
      _checkTutorial();
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _checkTutorial() async {
    final shouldShow = await _tutorialService.shouldShowCameraTutorial();
    if (shouldShow && mounted) {
      // Tutorial overlay is appended in build(); for now we just mark it done.
      _tutorialService.completeCameraTutorial();
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
          FLToastHost.show(
            context,
            message: '사진이 저장되었어요 · 갤러리에도 추가됨',
            icon: FLIcon.check,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        FLToastHost.show(context, message: '저장 실패');
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _currentMode = _currentMode == CameraMode.split
          ? CameraMode.overlay
          : CameraMode.split;
    });
  }

  void _swapSides() => setState(() => _isLeftReference = !_isLeftReference);

  Future<void> _cycleFlashMode() async {
    final next = switch (_flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };
    await _cameraService.setFlashMode(next);
    setState(() => _flashMode = next);
  }

  String _flashLabel() => switch (_flashMode) {
        FlashMode.off => 'OFF',
        FlashMode.auto => 'AUTO',
        FlashMode.always => 'ON',
        _ => 'OFF',
      };

  void _handleFocusTap(TapDownDetails details, BoxConstraints constraints) {
    final dx = details.localPosition.dx / constraints.maxWidth;
    final dy = details.localPosition.dy / constraints.maxHeight;
    final point = Offset(dx.clamp(0.0, 1.0), dy.clamp(0.0, 1.0));
    _cameraService.setFocusPoint(point);
    setState(() {
      _focusPoint = details.localPosition;
      _showFocusIndicator = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showFocusIndicator = false);
    });
  }

  Future<void> _selectReferencePhoto() async {
    final photos = await _storageService.loadPhotos();
    if (!mounted) return;
    if (photos.isEmpty) {
      FLToastHost.show(context, message: '레퍼런스로 쓸 사진이 없어요');
      return;
    }
    final selected = await showFLSheet<OotdPhoto>(
      context,
      heightFraction: 0.78,
      builder: (ctx) => _RefPickerBody(
        photos: photos,
        currentRefId: _referencePhoto?.id,
      ),
    );
    if (selected != null && mounted) {
      setState(() => _referencePhoto = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0A0908),
      child: Stack(
        children: [
          Positioned.fill(child: _buildBody()),
          // Top chrome
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _TopBar(
                mode: _currentMode,
                onClose: () => Navigator.pop(context, _photosTaken),
                onModeChange: (m) {
                  if (m != _currentMode) _toggleMode();
                },
                flashLabel: _flashLabel(),
                onFlash: _hasPermission ? _cycleFlashMode : null,
              ),
            ),
          ),
          // Mode-specific overlays
          if (_currentMode == CameraMode.split && _hasPermission)
            const _SplitGuide(),
          if (_currentMode == CameraMode.split && _hasPermission)
            Positioned(
              left: 0,
              right: 0,
              bottom: 124,
              child: Center(
                child: _SmallGlassButton(
                  icon: FLIcon.flip,
                  label: '좌우 바꾸기',
                  onPressed: _swapSides,
                ),
              ),
            ),
          if (_currentMode == CameraMode.split && _hasPermission)
            const Positioned(
              left: 0,
              right: 0,
              top: 110,
              child: Center(
                child: _ModeHintPill(text: '분할선에 어깨를 맞춰보세요'),
              ),
            ),
          if (_currentMode == CameraMode.overlay &&
              _hasPermission &&
              _referencePhoto != null)
            Positioned(
              left: 16,
              top: MediaQuery.of(context).padding.top + 76,
              child: _ReferenceBadge(photo: _referencePhoto!),
            ),
          if (_currentMode == CameraMode.overlay && _hasPermission)
            Positioned(
              left: 16,
              right: 16,
              bottom: 124,
              child: _OpacitySliderCard(
                opacity: _overlayOpacity,
                onChanged: (v) => setState(() => _overlayOpacity = v),
              ),
            ),
          // Shutter row
          if (_hasPermission)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 28,
              child: _ShutterRow(
                onPickReference: _selectReferencePhoto,
                onShutter: _isCapturing ? null : _takePicture,
                isCapturing: _isCapturing,
                onSwitchCamera: _cameraService.hasMultipleCameras
                    ? () async {
                        await _cameraService.switchCamera();
                        await _cameraService.setFlashMode(_flashMode);
                        if (mounted) setState(() {});
                      }
                    : null,
              ),
            ),
          // Focus indicator
          if (_showFocusIndicator && _focusPoint != null)
            Positioned(
              left: _focusPoint!.dx - 30,
              top: _focusPoint!.dy - 30,
              child: IgnorePointer(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFFFD86A), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasPermission || _errorMessage != null) {
      return _PermissionFallback(
        errorMessage: _errorMessage,
        onRetry: _initializeCamera,
      );
    }
    final preview = _CameraPreview(controller: _cameraService.controller);
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (d) => _handleFocusTap(d, constraints),
          behavior: HitTestBehavior.opaque,
          child: _currentMode == CameraMode.split
              ? Row(
                  children: [
                    Expanded(
                      child: _isLeftReference
                          ? _ReferenceFill(photo: _referencePhoto)
                          : preview,
                    ),
                    Expanded(
                      child: _isLeftReference
                          ? preview
                          : _ReferenceFill(photo: _referencePhoto),
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    preview,
                    if (_referencePhoto != null)
                      IgnorePointer(
                        child: Opacity(
                          opacity: _overlayOpacity,
                          child: _ReferenceFill(photo: _referencePhoto),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

// ─── Camera preview wrapper ─────────────────────────────────────────────

class _CameraPreview extends StatelessWidget {
  final CameraController? controller;
  const _CameraPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const ColoredBox(color: Color(0xFF0A0908));
    }
    return ClipRect(
      child: Center(
        child: AspectRatio(
          aspectRatio: 1 / controller!.value.aspectRatio,
          child: CameraPreview(controller!),
        ),
      ),
    );
  }
}

class _ReferenceFill extends StatelessWidget {
  final OotdPhoto? photo;
  const _ReferenceFill({required this.photo});

  @override
  Widget build(BuildContext context) {
    if (photo == null || !photo!.exists) {
      return Container(
        color: const Color(0xFF15110D),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FLIconView(FLIcon.image,
                  size: 28, color: const Color(0x66FAF8F5)),
              const SizedBox(height: 12),
              const Text(
                '레퍼런스를\n선택해 주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FLFonts.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0x99FAF8F5),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Image(
      image: FileImage(photo!.file),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
    );
  }
}

// ─── Top bar (close + mode toggle + flash chip) ─────────────────────────

class _TopBar extends StatelessWidget {
  final CameraMode mode;
  final VoidCallback onClose;
  final ValueChanged<CameraMode> onModeChange;
  final String flashLabel;
  final VoidCallback? onFlash;

  const _TopBar({
    required this.mode,
    required this.onClose,
    required this.onModeChange,
    required this.flashLabel,
    required this.onFlash,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FLIconBtn(
          icon: FLIcon.close,
          tone: FLIconBtnTone.cameraGlass,
          iconColor: const Color(0xFFFAF8F5),
          onPressed: onClose,
        ),
        const Spacer(),
        _ModePill(mode: mode, onChange: onModeChange),
        const Spacer(),
        _FlashChip(label: flashLabel, onPressed: onFlash),
      ],
    );
  }
}

class _ModePill extends StatelessWidget {
  final CameraMode mode;
  final ValueChanged<CameraMode> onChange;

  const _ModePill({required this.mode, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return FLGlass(
      tone: FLGlassTone.cameraGlass,
      borderRadius: BorderRadius.circular(FLRadii.full),
      blurSigma: 14,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeChip(
              icon: FLIcon.split,
              label: '분할',
              active: mode == CameraMode.split,
              onTap: () => onChange(CameraMode.split),
            ),
            _ModeChip(
              icon: FLIcon.overlay,
              label: '오버레이',
              active: mode == CameraMode.overlay,
              onTap: () => onChange(CameraMode.overlay),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final FLIcon icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? const Color(0xFF1A1816) : const Color(0xFFFAF8F5);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFFAF8F5)
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(FLRadii.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FLIconView(icon, size: 14, color: fg, strokeWidth: 1.8),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: FLFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _FlashChip({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 40,
        child: FLGlass(
          tone: FLGlassTone.cameraGlass,
          borderRadius: BorderRadius.circular(FLRadii.full),
          blurSigma: 14,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: disabled ? 0.3 : (label == 'OFF' ? 0.55 : 1.0),
                child: FLIconView(
                  FLIcon.flash,
                  size: 16,
                  color: const Color(0xFFFAF8F5),
                  strokeWidth: 1.8,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FLFonts.mono,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFAF8F5)
                      .withValues(alpha: disabled ? 0.3 : 1.0),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Split mode guide (divider + alignment ticks) ───────────────────────

class _SplitGuide extends StatelessWidget {
  const _SplitGuide();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Center(
              child: Container(
                width: 1,
                color: const Color(0x8CFFFFFF),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: LayoutBuilder(
              builder: (context, c) {
                return Stack(
                  children: [
                    for (final y in [0.18, 0.5, 0.82])
                      Positioned(
                        left: c.maxWidth / 2 - 9,
                        top: c.maxHeight * y - 9,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xF2FFFFFF),
                            border: Border.all(
                                color: const Color(0x261A1816), width: 1),
                            borderRadius:
                                BorderRadius.circular(FLRadii.full),
                          ),
                          child: Center(
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A1816),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeHintPill extends StatelessWidget {
  final String text;
  const _ModeHintPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return FLGlass(
      tone: FLGlassTone.cameraGlass,
      borderRadius: BorderRadius.circular(FLRadii.full),
      blurSigma: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xCCFAF8F5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: FLFonts.sans,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAF8F5),
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallGlassButton extends StatelessWidget {
  final FLIcon icon;
  final String label;
  final VoidCallback onPressed;

  const _SmallGlassButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: FLGlass(
        tone: FLGlassTone.cameraGlass,
        borderRadius: BorderRadius.circular(FLRadii.full),
        blurSigma: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FLIconView(icon,
                size: 14,
                color: const Color(0xFFFAF8F5),
                strokeWidth: 1.8),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: FLFonts.sans,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFAF8F5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reference badge (overlay mode) ─────────────────────────────────────

class _ReferenceBadge extends StatelessWidget {
  final OotdPhoto photo;
  const _ReferenceBadge({required this.photo});

  @override
  Widget build(BuildContext context) {
    return FLGlass(
      tone: FLGlassTone.cameraGlass,
      borderRadius: BorderRadius.circular(FLRadii.full),
      blurSigma: 14,
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '레퍼런스',
            style: TextStyle(
              fontFamily: FLFonts.sans,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xCCFAF8F5),
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(FLRadii.full),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x2EFFFFFF), width: 1),
                borderRadius: BorderRadius.circular(FLRadii.full),
              ),
              clipBehavior: Clip.antiAlias,
              child: photo.exists
                  ? Image(
                      image: FileImage(photo.file),
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Opacity slider card (overlay mode) ─────────────────────────────────

class _OpacitySliderCard extends StatelessWidget {
  final double opacity;
  final ValueChanged<double> onChanged;

  const _OpacitySliderCard({
    required this.opacity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FLGlass(
      tone: FLGlassTone.cameraGlass,
      borderRadius: BorderRadius.circular(24),
      blurSigma: 18,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: FLSlider(
        value: opacity,
        onChanged: onChanged,
        label: '투명도',
      ),
    );
  }
}

// ─── Shutter row (image picker · shutter · camera flip) ─────────────────

class _ShutterRow extends StatelessWidget {
  final VoidCallback onPickReference;
  final VoidCallback? onShutter;
  final bool isCapturing;
  final VoidCallback? onSwitchCamera;

  const _ShutterRow({
    required this.onPickReference,
    required this.onShutter,
    required this.isCapturing,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SquareGlassBtn(icon: FLIcon.image, onPressed: onPickReference),
          _ShutterButton(onPressed: onShutter, isCapturing: isCapturing),
          _SquareGlassBtn(icon: FLIcon.flip, onPressed: onSwitchCamera),
        ],
      ),
    );
  }
}

class _SquareGlassBtn extends StatelessWidget {
  final FLIcon icon;
  final VoidCallback? onPressed;

  const _SquareGlassBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: FLGlass(
          tone: FLGlassTone.cameraGlass,
          borderRadius: BorderRadius.circular(18),
          blurSigma: 14,
          child: Center(
            child: FLIconView(
              icon,
              size: 22,
              color: const Color(0xFFFAF8F5)
                  .withValues(alpha: disabled ? 0.3 : 1.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isCapturing;

  const _ShutterButton({required this.onPressed, required this.isCapturing});

  @override
  State<_ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<_ShutterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            border:
                Border.all(color: const Color(0xEBFFFFFF), width: 3),
            borderRadius: BorderRadius.circular(FLRadii.full),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: widget.isCapturing
                  ? const Color(0xFFC2614A)
                  : const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(FLRadii.full),
            ),
            child: widget.isCapturing
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: _MiniSpinner(),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _MiniSpinner extends StatefulWidget {
  const _MiniSpinner();

  @override
  State<_MiniSpinner> createState() => _MiniSpinnerState();
}

class _MiniSpinnerState extends State<_MiniSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (_, __) => Transform.rotate(
        angle: _ac.value * 6.283,
        child: CustomPaint(painter: _SpinnerPainter()),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFAF8F5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      0,
      4.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Permission fallback ────────────────────────────────────────────────

class _PermissionFallback extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const _PermissionFallback({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FLIconView(FLIcon.camera,
                size: 48, color: const Color(0x66FAF8F5)),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? '카메라 권한이 필요해요',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: FLFonts.sans,
                fontSize: 14,
                color: Color(0xB3FAF8F5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FLButton(
              label: '다시 시도',
              kind: FLButtonKind.primary,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reference picker sheet body ────────────────────────────────────────

class _RefPickerBody extends StatelessWidget {
  final List<OotdPhoto> photos;
  final String? currentRefId;

  const _RefPickerBody({required this.photos, required this.currentRefId});

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REFERENCE',
                        style: FLType.label.copyWith(
                            color: t.c.textMuted, letterSpacing: 1.32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '레퍼런스 사진 선택',
                        style: FLType.titleLg.copyWith(
                            color: t.c.textPrimary, letterSpacing: -0.4),
                      ),
                    ],
                  ),
                ),
                FLIconBtn(
                  icon: FLIcon.close,
                  tone: FLIconBtnTone.surface,
                  size: 36,
                  iconSize: 16,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1,
              ),
              itemCount: photos.length,
              itemBuilder: (context, i) {
                final p = photos[i];
                final selected = p.id == currentRefId;
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(p),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(FLRadii.sm),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: t.c.bgMuted),
                        if (p.exists)
                          Image(
                            image: FileImage(p.file),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) =>
                                ColoredBox(color: t.c.bgMuted),
                          ),
                        if (selected)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: t.c.accentBrand, width: 2),
                              borderRadius:
                                  BorderRadius.circular(FLRadii.sm),
                            ),
                          ),
                        if (selected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: t.c.accentBrand,
                                borderRadius:
                                    BorderRadius.circular(FLRadii.full),
                              ),
                              child: Center(
                                child: FLIconView(
                                  FLIcon.check,
                                  size: 12,
                                  color: const Color(0xFFFFFFFF),
                                  strokeWidth: 2.4,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

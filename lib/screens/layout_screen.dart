import 'package:flutter/widgets.dart';

import '../design/design.dart';
import '../models/ootd_photo.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

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
  Color _bgColor = const Color(0xFFFAF8F5);
  bool _isSaving = false;

  static const _bgOptions = <Color>[
    Color(0xFFFAF8F5),
    Color(0xFFF4EFE8),
    Color(0xFF1A1816),
    Color(0xFFEBE5DC),
    Color(0xFFC2614A),
  ];

  int get _cellCount => _layoutType.rows * _layoutType.columns;

  @override
  void initState() {
    super.initState();
    _selectedPhotos = List.of(widget.initialPhotos);
    _storageService.initialize();
  }

  Future<void> _replacePhoto(int index) async {
    final picked = await showFLSheet<OotdPhoto>(
      context,
      heightFraction: 0.78,
      builder: (ctx) => _PhotoPickerBody(photos: widget.allPhotos),
    );
    if (picked != null && mounted) {
      setState(() {
        if (index < _selectedPhotos.length) {
          _selectedPhotos[index] = picked;
        } else {
          _selectedPhotos.add(picked);
        }
      });
    }
  }

  Future<void> _addMorePhotos() async {
    final picked = await showFLSheet<OotdPhoto>(
      context,
      heightFraction: 0.78,
      builder: (ctx) => _PhotoPickerBody(photos: widget.allPhotos),
    );
    if (picked != null && mounted) {
      setState(() {
        if (_selectedPhotos.length < _cellCount) {
          _selectedPhotos.add(picked);
        } else {
          _selectedPhotos[_cellCount - 1] = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_selectedPhotos.isEmpty) {
      FLToastHost.show(context, message: '사진을 1장 이상 선택해 주세요');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final layoutImage = await _imageService.createLayoutImage(
        photos: _selectedPhotos,
        layoutType: _layoutType,
        backgroundColor: _bgColor,
      );
      await _storageService.saveLayoutImage(layoutImage);
      if (!mounted) return;
      FLToastHost.show(
        context,
        message: '레이아웃이 갤러리에 저장됐어요',
        icon: FLIcon.check,
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      FLToastHost.show(context, message: '레이아웃 저장 실패');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return ColoredBox(
      color: t.c.bgCanvas,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
              child: Row(
                children: [
                  FLIconBtn(
                    icon: FLIcon.close,
                    tone: FLIconBtnTone.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '레이아웃 합성',
                        style: FLType.titleSm.copyWith(
                            color: t.c.textPrimary,
                            letterSpacing: -0.2),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSaving ? null : _save,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: t.c.accentBrand
                            .withValues(alpha: _isSaving ? 0.4 : 1.0),
                        borderRadius: BorderRadius.circular(FLRadii.full),
                      ),
                      child: Text(
                        _isSaving ? '저장 중…' : '저장',
                        style: const TextStyle(
                          fontFamily: FLFonts.sans,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Center(
                  child: _LayoutPreview(
                    layoutType: _layoutType,
                    bgColor: _bgColor,
                    photos: _selectedPhotos,
                    onCellTap: _replacePhoto,
                  ),
                ),
              ),
            ),
            // Layout chooser
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LAYOUT',
                    style: FLType.label.copyWith(
                        color: t.c.textMuted, letterSpacing: 1.32),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final L in LayoutType.values) ...[
                        Expanded(
                          child: _LayoutChip(
                            type: L,
                            active: L == _layoutType,
                            onTap: () => setState(() => _layoutType = L),
                          ),
                        ),
                        if (L != LayoutType.values.last)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Background colors
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              child: Row(
                children: [
                  Text(
                    'BG',
                    style: FLType.label.copyWith(
                        color: t.c.textMuted, letterSpacing: 1.32),
                  ),
                  const SizedBox(width: 12),
                  for (final col in _bgOptions) ...[
                    GestureDetector(
                      onTap: () => setState(() => _bgColor = col),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: col,
                          borderRadius:
                              BorderRadius.circular(FLRadii.full),
                          border: Border.all(
                            color: _bgColor == col
                                ? t.c.accentBrand
                                : t.c.borderDefault,
                            width: _bgColor == col ? 2 : 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            // Counter row
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: FLType.bodySm.copyWith(
                            color: t.c.textSecondary),
                        children: [
                          const TextSpan(text: '선택된 사진  '),
                          TextSpan(
                            text:
                                '${_selectedPhotos.length.clamp(0, _cellCount)}',
                            style: TextStyle(
                              fontFamily: FLFonts.mono,
                              color: t.c.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' / $_cellCount',
                            style: const TextStyle(
                              fontFamily: FLFonts.mono,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FLButton(
                    label: '사진 추가',
                    kind: FLButtonKind.ghost,
                    size: FLButtonSize.sm,
                    leadingIcon: FLIcon.plus,
                    onPressed: _addMorePhotos,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Preview ─────────────────────────────────────────────────────────────

class _LayoutPreview extends StatelessWidget {
  final LayoutType layoutType;
  final Color bgColor;
  final List<OotdPhoto> photos;
  final void Function(int index) onCellTap;

  const _LayoutPreview({
    required this.layoutType,
    required this.bgColor,
    required this.photos,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    final cells = layoutType.rows * layoutType.columns;
    final wide = layoutType.columns >= layoutType.rows;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: wide ? 320 : 260),
      child: AspectRatio(
        aspectRatio: layoutType.columns / layoutType.rows,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: t.isDark ? FLShadows.darkLg : FLShadows.lightLg,
          ),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layoutType.columns,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: cells,
            itemBuilder: (context, i) {
              final hasPhoto = i < photos.length;
              return GestureDetector(
                onTap: () => onCellTap(i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: hasPhoto && photos[i].exists
                      ? Image(
                          image: FileImage(photos[i].file),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) =>
                              ColoredBox(color: t.c.bgMuted),
                        )
                      : Container(
                          color: t.c.bgMuted,
                          alignment: Alignment.center,
                          child: FLIconView(
                            FLIcon.plus,
                            size: 16,
                            color: t.c.textMuted,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Layout chip ─────────────────────────────────────────────────────────

class _LayoutChip extends StatelessWidget {
  final LayoutType type;
  final bool active;
  final VoidCallback onTap;

  const _LayoutChip({
    required this.type,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: active ? t.c.accentBrandFill : t.c.bgElevated,
          border: Border.all(
            color: active ? t.c.accentBrand : t.c.borderSubtle,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(FLRadii.md),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: _MiniLayout(
                type: type,
                color: active ? t.c.accentBrand : t.c.textMuted,
                opacity: active ? 1.0 : 0.55,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              type.label,
              style: FLType.label.copyWith(color: t.c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniLayout extends StatelessWidget {
  final LayoutType type;
  final Color color;
  final double opacity;

  const _MiniLayout({
    required this.type,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: type.columns / type.rows,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: type.columns,
          crossAxisSpacing: 1.5,
          mainAxisSpacing: 1.5,
        ),
        itemCount: type.rows * type.columns,
        itemBuilder: (context, _) => Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

// ─── Photo picker sheet body ────────────────────────────────────────────

class _PhotoPickerBody extends StatelessWidget {
  final List<OotdPhoto> photos;
  const _PhotoPickerBody({required this.photos});

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
                        'PHOTO',
                        style: FLType.label.copyWith(
                            color: t.c.textMuted,
                            letterSpacing: 1.32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '사진 선택',
                        style: FLType.titleLg.copyWith(
                            color: t.c.textPrimary,
                            letterSpacing: -0.4),
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
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: photos.length,
              itemBuilder: (context, i) {
                final p = photos[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(p),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(FLRadii.sm),
                    child: p.exists
                        ? Image(
                            image: FileImage(p.file),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) =>
                                ColoredBox(color: t.c.bgMuted),
                          )
                        : ColoredBox(color: t.c.bgMuted),
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

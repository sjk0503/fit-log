import 'package:flutter/material.dart' show MaterialPageRoute, Navigator;
import 'package:flutter/widgets.dart';

import '../design/design.dart';
import '../models/ootd_photo.dart';
import '../services/locale_service.dart';
import '../services/storage_service.dart';
import '../services/tutorial_service.dart';
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

  List<OotdPhoto> _photos = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  // ignore: unused_field
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
      if (!mounted) return;
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      FLToastHost.show(context, message: '사진을 불러오지 못했어요');
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedPhotoIds.clear();
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
    final result = await showFLConfirm<bool>(
      context,
      title: '사진을 삭제할까요?',
      body:
          '선택한 ${_selectedPhotoIds.length}장의 OOTD 사진이 라이브러리와 시스템 갤러리에서 모두 삭제됩니다. 되돌릴 수 없어요.',
      primary: const FLDialogAction(label: '삭제', value: true),
      secondary: const FLDialogAction(label: '취소', value: false),
      destructive: true,
    );
    if (result == true) {
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
        builder: (context) =>
            CameraScreen(referencePhoto: referencePhoto),
      ),
    );
    if (result == true) _loadPhotos();
  }

  void _openLayout() async {
    final selectedPhotos = _selectedPhotoIds
        .map((id) => _photos.firstWhere((p) => p.id == id))
        .toList();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LayoutScreen(
          initialPhotos: selectedPhotos.isNotEmpty
              ? selectedPhotos
              : _photos.take(4).toList(),
          allPhotos: _photos,
        ),
      ),
    );
    if (_isSelectionMode) _toggleSelectionMode();
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

  void _showLanguageSheet() {
    showFLSheet<void>(
      context,
      heightFraction: 0.55,
      builder: (ctx) => const _LanguageSheetBody(),
    );
  }

  // ── derived data ───────────────────────────────────────────────────────

  ({int total, int thisMonth, int streak}) get _stats {
    if (_photos.isEmpty) return (total: 0, thisMonth: 0, streak: 0);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final today = DateTime(now.year, now.month, now.day);
    int thisMonth = 0;
    final dates = <DateTime>{};
    for (final p in _photos) {
      if (!p.createdAt.isBefore(monthStart)) thisMonth++;
      dates.add(DateTime(
          p.createdAt.year, p.createdAt.month, p.createdAt.day));
    }
    int streak = 0;
    var d = today;
    while (dates.contains(d)) {
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return (total: _photos.length, thisMonth: thisMonth, streak: streak);
  }

  List<_PhotoGroup> get _groups {
    if (_photos.isEmpty) return [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeekStart = today.subtract(const Duration(days: 7));

    final todayG = <OotdPhoto>[];
    final yesterdayG = <OotdPhoto>[];
    final lastWeekG = <OotdPhoto>[];
    final monthlyG = <String, List<OotdPhoto>>{};

    for (final p in _photos) {
      final pd = DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day);
      if (pd == today) {
        todayG.add(p);
      } else if (pd == yesterday) {
        yesterdayG.add(p);
      } else if (pd.isAfter(lastWeekStart)) {
        lastWeekG.add(p);
      } else {
        final key = '${pd.year}-${pd.month.toString().padLeft(2, '0')}';
        monthlyG.putIfAbsent(key, () => []).add(p);
      }
    }

    final groups = <_PhotoGroup>[];
    if (todayG.isNotEmpty) {
      groups.add(_PhotoGroup(
        label: '오늘',
        sub: _formatDate(today),
        photos: todayG,
      ));
    }
    if (yesterdayG.isNotEmpty) {
      groups.add(_PhotoGroup(
        label: '어제',
        sub: _formatDate(yesterday),
        photos: yesterdayG,
      ));
    }
    if (lastWeekG.isNotEmpty) {
      final from = lastWeekG.last.createdAt;
      final to = lastWeekG.first.createdAt;
      groups.add(_PhotoGroup(
        label: '지난 주',
        sub: '${from.month}.${from.day} — ${to.month}.${to.day}',
        photos: lastWeekG,
      ));
    }
    final monthKeys = monthlyG.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final k in monthKeys) {
      final ms = k.split('-');
      groups.add(_PhotoGroup(
        label: '${int.parse(ms[1])}월',
        sub: '${monthlyG[k]!.length}장',
        photos: monthlyG[k]!,
      ));
    }
    return groups;
  }

  String _formatDate(DateTime d) {
    const wd = ['월', '화', '수', '목', '금', '토', '일'];
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')} ${wd[d.weekday - 1]}';
  }

  // ── build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    final mq = MediaQuery.of(context);
    final isEmpty = _photos.isEmpty && !_isLoading;

    return ColoredBox(
      color: t.c.bgCanvas,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _Header(
                  isSelecting: _isSelectionMode,
                  selectedCount: _selectedPhotoIds.length,
                  onLanguage: _showLanguageSheet,
                  onCancelSelect: _toggleSelectionMode,
                ),
                if (!_isSelectionMode && !isEmpty && !_isLoading)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                    child: _StatsStrip(stats: _stats),
                  ),
                Expanded(
                  child: _isLoading
                      ? const _LoadingState()
                      : (isEmpty
                          ? _EmptyState(onShoot: () => _openCamera())
                          : _GroupedGrid(
                              groups: _groups,
                              isSelecting: _isSelectionMode,
                              selectedIds: _selectedPhotoIds,
                              onTap: _showPhotoDetail,
                              onLongPress: (p) {
                                _toggleSelectionMode();
                                _togglePhotoSelection(p);
                              },
                              bottomPadding: 120 + mq.padding.bottom,
                            )),
                ),
              ],
            ),
            if (!_isLoading && !isEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 22 + mq.padding.bottom,
                child: Center(
                  child: _isSelectionMode
                      ? _SelectionActions(
                          enabled: _selectedPhotoIds.isNotEmpty,
                          onDelete: _deleteSelectedPhotos,
                          onLayout: _openLayout,
                        )
                      : _FloatingActions(
                          onShoot: () => _openCamera(),
                          onLayout: _photos.isNotEmpty ? _openLayout : null,
                          onSelect: _toggleSelectionMode,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGroup {
  final String label;
  final String sub;
  final List<OotdPhoto> photos;
  const _PhotoGroup(
      {required this.label, required this.sub, required this.photos});
}

// ─── Header ───────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isSelecting;
  final int selectedCount;
  final VoidCallback onLanguage;
  final VoidCallback onCancelSelect;

  const _Header({
    required this.isSelecting,
    required this.selectedCount,
    required this.onLanguage,
    required this.onCancelSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIT—LOG',
                  style: TextStyle(
                    fontFamily: FLFonts.sans,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: t.c.textMuted,
                    letterSpacing: 1.32,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSelecting ? '$selectedCount장 선택됨' : '라이브러리',
                  style: FLType.displayMd.copyWith(
                      color: t.c.textPrimary, letterSpacing: -0.6),
                ),
              ],
            ),
          ),
          if (isSelecting)
            FLButton(
              label: '취소',
              kind: FLButtonKind.ghost,
              size: FLButtonSize.sm,
              onPressed: onCancelSelect,
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FLIconBtn(
                  icon: FLIcon.globe,
                  onPressed: onLanguage,
                ),
                const SizedBox(width: 6),
                FLIconBtn(
                  icon: FLIcon.settings,
                  onPressed: () {},
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Stats strip ──────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final ({int total, int thisMonth, int streak}) stats;
  const _StatsStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatPill(value: '${stats.total}', label: '총 OOTD')),
        const SizedBox(width: 8),
        Expanded(
            child: _StatPill(value: '${stats.thisMonth}', label: '이번 달')),
        const SizedBox(width: 8),
        Expanded(
            child: _StatPill(value: '${stats.streak}', label: '연속 일자')),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: t.c.bgElevated,
        border: Border.all(color: t.c.borderSubtle, width: 1),
        borderRadius: BorderRadius.circular(FLRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: FLFonts.mono,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: t.c.textPrimary,
              letterSpacing: -0.4,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: FLType.caption.copyWith(color: t.c.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Grouped grid ─────────────────────────────────────────────────────────

class _GroupedGrid extends StatelessWidget {
  final List<_PhotoGroup> groups;
  final bool isSelecting;
  final Set<String> selectedIds;
  final void Function(OotdPhoto) onTap;
  final void Function(OotdPhoto) onLongPress;
  final double bottomPadding;

  const _GroupedGrid({
    required this.groups,
    required this.isSelecting,
    required this.selectedIds,
    required this.onTap,
    required this.onLongPress,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(22, 8, 22, bottomPadding),
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final g = groups[i];
        return Padding(
          padding: EdgeInsets.only(bottom: i == groups.length - 1 ? 0 : 18),
          child: _Group(
            group: g,
            isSelecting: isSelecting,
            selectedIds: selectedIds,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        );
      },
    );
  }
}

class _Group extends StatelessWidget {
  final _PhotoGroup group;
  final bool isSelecting;
  final Set<String> selectedIds;
  final void Function(OotdPhoto) onTap;
  final void Function(OotdPhoto) onLongPress;

  const _Group({
    required this.group,
    required this.isSelecting,
    required this.selectedIds,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                group.label,
                style: FLType.titleSm.copyWith(
                    color: t.c.textPrimary, letterSpacing: -0.2),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  group.sub,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FLFonts.mono,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: t.c.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        _PhotoGrid(
          photos: group.photos,
          isSelecting: isSelecting,
          selectedIds: selectedIds,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ],
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<OotdPhoto> photos;
  final bool isSelecting;
  final Set<String> selectedIds;
  final void Function(OotdPhoto) onTap;
  final void Function(OotdPhoto) onLongPress;

  const _PhotoGrid({
    required this.photos,
    required this.isSelecting,
    required this.selectedIds,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) {
        final p = photos[i];
        final selected = selectedIds.contains(p.id);
        return _PhotoTile(
          photo: p,
          isSelecting: isSelecting,
          selected: selected,
          onTap: () => onTap(p),
          onLongPress: () => onLongPress(p),
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final OotdPhoto photo;
  final bool isSelecting;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PhotoTile({
    required this.photo,
    required this.isSelecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: t.c.bgMuted),
            if (photo.exists)
              Image(
                image: FileImage(photo.file),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) =>
                    ColoredBox(color: t.c.bgMuted),
              ),
            if (isSelecting)
              ColoredBox(
                color: selected
                    ? t.c.accentBrandFill
                    : const Color(0x0D000000),
              ),
            if (isSelecting)
              Positioned(
                top: 8,
                right: 8,
                child: _SelectCircle(selected: selected),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectCircle extends StatelessWidget {
  final bool selected;
  const _SelectCircle({required this.selected});

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? t.c.accentBrand : const Color(0x8CFFFFFF),
        border: selected
            ? null
            : Border.all(color: const Color(0xE6FFFFFF), width: 1.5),
        borderRadius: BorderRadius.circular(FLRadii.full),
      ),
      child: selected
          ? Center(
              child: FLIconView(
                FLIcon.check,
                size: 14,
                color: const Color(0xFFFFFFFF),
                strokeWidth: 2.4,
              ),
            )
          : null,
    );
  }
}

// ─── Loading / Empty ──────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: _PulseDot(color: t.c.accentBrand),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
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
      builder: (_, __) {
        final s = (_ac.value * 2 - 1).abs();
        return Center(
          child: Container(
            width: 12 + 8 * (1 - s),
            height: 12 + 8 * (1 - s),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.4 + 0.6 * (1 - s)),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onShoot;
  const _EmptyState({required this.onShoot});

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: t.c.bgElevated,
              border: Border.all(color: t.c.borderSubtle, width: 1),
              borderRadius: BorderRadius.circular(FLRadii.xl),
              boxShadow: t.isDark ? FLShadows.darkLg : FLShadows.lightLg,
            ),
            child: GridView.count(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              children: List.generate(4, (i) {
                return Container(
                  decoration: BoxDecoration(
                    color: t.c.bgMuted.withValues(alpha: 0.5 + i * 0.15),
                    borderRadius: BorderRadius.circular(FLRadii.sm),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '첫 OOTD를 남겨보세요',
            style: FLType.titleLg.copyWith(
                color: t.c.textPrimary, letterSpacing: -0.4),
          ),
          const SizedBox(height: 10),
          Text(
            '매일 같은 포즈로 기록하면\n옷차림의 변화가 한눈에 보여요',
            textAlign: TextAlign.center,
            style: FLType.bodyMd.copyWith(
                color: t.c.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 28),
          FLButton(
            label: '첫 사진 찍기',
            size: FLButtonSize.lg,
            leadingIcon: FLIcon.camera,
            onPressed: onShoot,
          ),
        ],
      ),
    );
  }
}

// ─── Floating action bars ─────────────────────────────────────────────────

class _FloatingActions extends StatelessWidget {
  final VoidCallback onShoot;
  final VoidCallback? onLayout;
  final VoidCallback onSelect;

  const _FloatingActions({
    required this.onShoot,
    required this.onLayout,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return FLGlass(
      borderRadius: BorderRadius.circular(FLRadii.full),
      padding: const EdgeInsets.all(6),
      blurSigma: 18,
      boxShadow: t.isDark ? FLShadows.darkLg : FLShadows.lightLg,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShootButton(onPressed: onShoot),
          const SizedBox(width: 4),
          _GhostFloatingBtn(
            label: '합성',
            icon: FLIcon.layers,
            onPressed: onLayout,
          ),
          _GhostFloatingBtn(
            label: '선택',
            onPressed: onSelect,
          ),
        ],
      ),
    );
  }
}

class _ShootButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _ShootButton({required this.onPressed});

  @override
  State<_ShootButton> createState() => _ShootButtonState();
}

class _ShootButtonState extends State<_ShootButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 48,
          padding: const EdgeInsets.fromLTRB(16, 0, 22, 0),
          decoration: BoxDecoration(
            color: t.c.accentBrand,
            borderRadius: BorderRadius.circular(FLRadii.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FLIconView(FLIcon.camera,
                  size: 18,
                  color: const Color(0xFFFFFFFF),
                  strokeWidth: 1.8),
              const SizedBox(width: 8),
              const Text(
                '오늘 OOTD 찍기',
                style: TextStyle(
                  fontFamily: FLFonts.sans,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostFloatingBtn extends StatelessWidget {
  final String label;
  final FLIcon? icon;
  final VoidCallback? onPressed;

  const _GhostFloatingBtn({
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    final disabled = onPressed == null;
    final fg = t.c.textSecondary.withValues(alpha: disabled ? 0.4 : 1.0);
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              FLIconView(icon!, size: 16, color: fg, strokeWidth: 1.8),
              const SizedBox(width: 6),
            ],
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

class _SelectionActions extends StatelessWidget {
  final bool enabled;
  final VoidCallback onDelete;
  final VoidCallback onLayout;

  const _SelectionActions({
    required this.enabled,
    required this.onDelete,
    required this.onLayout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: FLButton(
              label: '삭제',
              kind: FLButtonKind.secondary,
              leadingIcon: FLIcon.trash,
              fullWidth: true,
              onPressed: enabled ? onDelete : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FLButton(
              label: '레이아웃 합성',
              kind: FLButtonKind.primary,
              leadingIcon: FLIcon.layers,
              fullWidth: true,
              onPressed: enabled ? onLayout : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Language sheet body ──────────────────────────────────────────────────

class _LanguageSheetBody extends StatelessWidget {
  const _LanguageSheetBody();

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    final localeService = LocaleService();
    final current = localeService.locale;

    final langs = <_LangOption>[
      const _LangOption(null, '시스템 기본', 'System default', 'AUTO'),
      const _LangOption(Locale('ko'), '한국어', 'Korean', 'KO'),
      const _LangOption(Locale('en'), 'English', '영어', 'EN'),
      const _LangOption(Locale('ja'), '日本語', '일본어', 'JA'),
      const _LangOption(Locale('zh'), '中文', '중국어', 'ZH'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LANGUAGE',
                  style: FLType.label.copyWith(
                      color: t.c.textMuted, letterSpacing: 1.32),
                ),
                const SizedBox(height: 4),
                Text(
                  '언어 선택',
                  style: FLType.titleLg.copyWith(
                      color: t.c.textPrimary, letterSpacing: -0.4),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                for (final l in langs)
                  _LangRow(
                    option: l,
                    selected: l.locale?.languageCode ==
                            current?.languageCode &&
                        (l.locale == null) == (current == null),
                    onTap: () {
                      localeService.setLocale(l.locale);
                      Navigator.of(context).maybePop();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LangOption {
  final Locale? locale;
  final String label;
  final String sub;
  final String code;
  const _LangOption(this.locale, this.label, this.sub, this.code);
}

class _LangRow extends StatelessWidget {
  final _LangOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LangRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? t.c.accentBrandFill
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(FLRadii.md),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? t.c.accentBrand : t.c.bgMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                option.code,
                style: TextStyle(
                  fontFamily: FLFonts.mono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected ? const Color(0xFFFFFFFF) : t.c.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: FLType.bodyLg.copyWith(
                      color: t.c.textPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.sub,
                    style: FLType.bodySm.copyWith(color: t.c.textMuted),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.c.accentBrand,
                  borderRadius: BorderRadius.circular(FLRadii.full),
                ),
                child: FLIconView(
                  FLIcon.check,
                  size: 13,
                  color: const Color(0xFFFFFFFF),
                  strokeWidth: 2.4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

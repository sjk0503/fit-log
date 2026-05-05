import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../design/design.dart';
import '../models/ootd_photo.dart';

class PhotoViewerScreen extends StatefulWidget {
  final List<OotdPhoto> photos;
  final int initialIndex;
  final void Function(OotdPhoto photo)? onUseAsReference;
  final void Function(OotdPhoto photo)? onDelete;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
    this.onUseAsReference,
    this.onDelete,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUI() => setState(() => _showUI = !_showUI);

  String _formatDate(DateTime d) {
    const wd = ['월', '화', '수', '목', '금', '토', '일'];
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')} ${wd[d.weekday - 1]}';
  }

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _confirmDelete() async {
    final photo = widget.photos[_currentIndex];
    final ok = await showFLConfirm<bool>(
      context,
      title: '사진을 삭제할까요?',
      body: '이 OOTD 사진이 라이브러리와 시스템 갤러리에서 모두 삭제됩니다. 되돌릴 수 없어요.',
      primary: const FLDialogAction(label: '삭제', value: true),
      secondary: const FLDialogAction(label: '취소', value: false),
      destructive: true,
    );
    if (ok == true && mounted) {
      Navigator.of(context).pop();
      widget.onDelete?.call(photo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final photo = widget.photos[_currentIndex];
    return ColoredBox(
      color: const Color(0xFF0A0908),
      child: Stack(
        children: [
          // Photo PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final p = widget.photos[index];
              return GestureDetector(
                onTap: _toggleUI,
                child: Center(
                  child: AnimatedScale(
                    scale: 1.0,
                    duration: Duration.zero,
                    child: Image(
                      image: FileImage(p.file),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              );
            },
          ),
          // Top bar
          AnimatedOpacity(
            opacity: _showUI ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showUI,
              child: Padding(
                padding:
                    EdgeInsets.fromLTRB(16, mq.padding.top + 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FLIconBtn(
                      icon: FLIcon.back,
                      tone: FLIconBtnTone.cameraGlass,
                      iconColor: const Color(0xFFFAF8F5),
                      iconSize: 20,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    FLGlass(
                      tone: FLGlassTone.cameraGlass,
                      borderRadius: BorderRadius.circular(FLRadii.full),
                      blurSigma: 14,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        _formatDate(photo.createdAt),
                        style: const TextStyle(
                          fontFamily: FLFonts.sans,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFAF8F5),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    FLIconBtn(
                      icon: FLIcon.more,
                      tone: FLIconBtnTone.cameraGlass,
                      iconColor: const Color(0xFFFAF8F5),
                      iconSize: 20,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Metadata strip
          if (widget.photos.isNotEmpty)
            AnimatedOpacity(
              opacity: _showUI ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showUI,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, 0, 16, mq.padding.bottom + 110),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FLGlass(
                      tone: FLGlassTone.cameraGlass,
                      borderRadius: BorderRadius.circular(16),
                      blurSigma: 14,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Meta(label: '시간', value: _formatTime(photo.createdAt)),
                          const _MetaDivider(),
                          _Meta(
                              label: '인덱스',
                              value:
                                  '${_currentIndex + 1}/${widget.photos.length}'),
                          const _MetaDivider(),
                          _Meta(
                              label: '날짜',
                              value:
                                  '${photo.createdAt.month}.${photo.createdAt.day}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Bottom actions
          AnimatedOpacity(
            opacity: _showUI ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showUI,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 0, 16, mq.padding.bottom + 22),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(child: _GlassActionBtn(
                        icon: FLIcon.trash,
                        label: '삭제',
                        onPressed: _confirmDelete,
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _GlassActionBtn(
                        icon: FLIcon.redo,
                        label: '이 포즈로 다시 찍기',
                        accent: true,
                        onPressed: () {
                          final p = widget.photos[_currentIndex];
                          Navigator.of(context).pop();
                          widget.onUseAsReference?.call(p);
                        },
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final String label;
  final String value;
  const _Meta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: FLFonts.sans,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0x99FAF8F5),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: FLFonts.mono,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFAF8F5),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaDivider extends StatelessWidget {
  const _MetaDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0x1FFFFFFF),
    );
  }
}

class _GlassActionBtn extends StatelessWidget {
  final FLIcon icon;
  final String label;
  final VoidCallback onPressed;
  final bool accent;

  const _GlassActionBtn({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    if (accent) {
      return GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFC2614A),
            borderRadius: BorderRadius.circular(FLRadii.full),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FLIconView(icon,
                  size: 18,
                  color: const Color(0xFFFFFFFF),
                  strokeWidth: 1.8),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: FLFonts.sans,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52,
        child: FLGlass(
          tone: FLGlassTone.cameraGlass,
          borderRadius: BorderRadius.circular(FLRadii.full),
          blurSigma: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FLIconView(icon,
                  size: 18,
                  color: const Color(0xFFFAF8F5),
                  strokeWidth: 1.8),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: FLFonts.sans,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFAF8F5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

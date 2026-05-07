import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../design/design.dart';
import '../models/ootd_photo.dart';

/// Time-lapse playback + GIF export.
///
/// Plays the user's selected photos as a fast slideshow to preview, then on
/// "GIF로 저장" encodes them into an animated GIF and saves the file to the
/// system photo library.
class TimelapseScreen extends StatefulWidget {
  final List<OotdPhoto> photos;
  final String? title;

  const TimelapseScreen({
    super.key,
    required this.photos,
    this.title,
  });

  @override
  State<TimelapseScreen> createState() => _TimelapseScreenState();
}

class _TimelapseScreenState extends State<TimelapseScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  int _frame = 0;
  // Frames per second for preview playback. The exported GIF uses the same
  // speed so what the user sees matches what is saved.
  double _fps = 4;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(_tick);
    _ac.repeat(reverse: false);
  }

  @override
  void dispose() {
    _ac.removeListener(_tick);
    _ac.dispose();
    super.dispose();
  }

  int _lastTickMs = 0;

  void _tick() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final intervalMs = (1000 / _fps).round();
    if (now - _lastTickMs >= intervalMs) {
      _lastTickMs = now;
      if (mounted) {
        setState(() {
          _frame = (_frame + 1) % widget.photos.length;
        });
      }
    }
  }

  Future<void> _export() async {
    if (_exporting || widget.photos.isEmpty) return;
    setState(() => _exporting = true);
    try {
      final file = await _encodeGif(widget.photos, _fps);
      final bytes = await file.readAsBytes();
      await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(bytes),
        name: 'fit-log-timelapse-${DateTime.now().millisecondsSinceEpoch}',
      );
      if (!mounted) return;
      FLToastHost.show(
        context,
        message: 'GIF가 갤러리에 저장됐어요',
        icon: FLIcon.check,
      );
    } catch (_) {
      if (!mounted) return;
      FLToastHost.show(context, message: '저장 실패');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<File> _encodeGif(List<OotdPhoto> photos, double fps) async {
    // Encode at a smaller size to keep GIF file size manageable —
    // GIFs grow fast with resolution.
    const maxSide = 720;
    final delayCs = (100 / fps).round(); // GIF delay is in 1/100 sec

    final encoder = img.GifEncoder(
      repeat: 0, // loop forever
      samplingFactor: 10,
    );

    for (final p in photos) {
      if (!p.exists) continue;
      final raw = img.decodeImage(await p.file.readAsBytes());
      if (raw == null) continue;
      final scaled = _fit(raw, maxSide);
      encoder.addFrame(scaled, duration: delayCs);
    }

    final bytes = encoder.finish();
    final tempDir = await getTemporaryDirectory();
    final out = File(path.join(
      tempDir.path,
      'timelapse_${DateTime.now().millisecondsSinceEpoch}.gif',
    ));
    if (bytes == null) throw 'gif encode returned null';
    await out.writeAsBytes(bytes);
    return out;
  }

  img.Image _fit(img.Image src, int maxSide) {
    final ratio = src.width / src.height;
    int w, h;
    if (ratio >= 1) {
      w = maxSide;
      h = (maxSide / ratio).round();
    } else {
      h = maxSide;
      w = (maxSide * ratio).round();
    }
    return img.copyResize(src, width: w, height: h,
        interpolation: img.Interpolation.average);
  }

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    if (widget.photos.isEmpty) {
      return ColoredBox(
        color: t.c.bgCanvas,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FLIconView(FLIcon.image, size: 40, color: t.c.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    '재생할 사진이 없어요',
                    style: FLType.titleSm.copyWith(color: t.c.textPrimary),
                  ),
                  const SizedBox(height: 18),
                  FLButton(
                    label: '닫기',
                    kind: FLButtonKind.ghost,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final current = widget.photos[_frame];
    return ColoredBox(
      color: t.c.bgCanvas,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  FLIconBtn(
                    icon: FLIcon.close,
                    tone: FLIconBtnTone.outline,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title ?? '타임랩스',
                        style: FLType.titleSm.copyWith(
                          color: t.c.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _exporting ? null : _export,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: t.c.accentBrand
                            .withValues(alpha: _exporting ? 0.4 : 1.0),
                        borderRadius: BorderRadius.circular(FLRadii.full),
                      ),
                      child: Text(
                        _exporting ? '저장 중…' : 'GIF로 저장',
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
            // Player
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.c.bgInset,
                        borderRadius:
                            BorderRadius.circular(FLRadii.lg),
                        boxShadow: t.isDark
                            ? FLShadows.darkLg
                            : FLShadows.lightLg,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (current.exists)
                            Image(
                              image: FileImage(current.file),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: _FrameIndicator(
                              current: _frame + 1,
                              total: widget.photos.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Speed control
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'SPEED',
                        style: FLType.label.copyWith(
                            color: t.c.textMuted, letterSpacing: 1.32),
                      ),
                      const Spacer(),
                      Text(
                        '${_fps.toStringAsFixed(0)} fps',
                        style: TextStyle(
                          fontFamily: FLFonts.mono,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: t.c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _SpeedSlider(
                    value: _fps,
                    onChanged: (v) => setState(() => _fps = v),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '느리게 1 fps  ~  빠르게 15 fps',
                    style: FLType.caption.copyWith(color: t.c.textMuted),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
          ],
        ),
      ),
    );
  }
}

class _FrameIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _FrameIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(FLRadii.full),
      ),
      child: Text(
        '$current / $total',
        style: const TextStyle(
          fontFamily: FLFonts.mono,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFAF8F5),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SpeedSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _SpeedSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final pct = ((value - 1) / 14).clamp(0.0, 1.0);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => _update(d.localPosition.dx, c.maxWidth),
          onPanUpdate: (d) => _update(d.localPosition.dx, c.maxWidth),
          onTapDown: (d) => _update(d.localPosition.dx, c.maxWidth),
          child: SizedBox(
            height: 32,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: t.c.bgMuted,
                    borderRadius: BorderRadius.circular(FLRadii.full),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: t.c.accentBrand,
                      borderRadius: BorderRadius.circular(FLRadii.full),
                    ),
                  ),
                ),
                Positioned(
                  left: pct * c.maxWidth - 12,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: t.c.bgElevated,
                      border:
                          Border.all(color: t.c.accentBrand, width: 2),
                      borderRadius: BorderRadius.circular(FLRadii.full),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          offset: Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _update(double dx, double width) {
    final pct = (dx / width).clamp(0.0, 1.0);
    final v = 1 + pct * 14; // 1..15 fps
    onChanged(v.roundToDouble());
  }
}

import 'package:flutter/widgets.dart';

import '../tokens.dart';

/// Custom slider used by the camera overlay-mode opacity control.
/// Always rendered on dark glass, so colors are baked in (white track + thumb).
class FLSlider extends StatefulWidget {
  final double value; // 0..1
  final ValueChanged<double> onChanged;
  final String? label;
  final String Function(double)? valueFormatter;

  const FLSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.valueFormatter,
  });

  @override
  State<FLSlider> createState() => _FLSliderState();
}

class _FLSliderState extends State<FLSlider> {
  bool _dragging = false;

  void _updateFromGlobalX(double globalX, BoxConstraints c, RenderBox box) {
    final local = box.globalToLocal(Offset(globalX, 0));
    final ratio = (local.dx / c.maxWidth).clamp(0.0, 1.0);
    widget.onChanged(ratio);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.label != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.label!.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: FLFonts.sans,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                        color: Color(0xFFFAF8F5),
                      ),
                    ),
                    Text(
                      widget.valueFormatter?.call(widget.value) ??
                          '${(widget.value * 100).round()}%',
                      style: const TextStyle(
                        fontFamily: FLFonts.mono,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFAF8F5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) {
                setState(() => _dragging = true);
                final box = context.findRenderObject() as RenderBox;
                _updateFromGlobalX(d.globalPosition.dx, constraints, box);
              },
              onPanUpdate: (d) {
                final box = context.findRenderObject() as RenderBox;
                _updateFromGlobalX(d.globalPosition.dx, constraints, box);
              },
              onPanEnd: (_) => setState(() => _dragging = false),
              onTapDown: (d) {
                final box = context.findRenderObject() as RenderBox;
                _updateFromGlobalX(d.globalPosition.dx, constraints, box);
              },
              child: SizedBox(
                height: 32,
                child: CustomPaint(
                  painter: _SliderPainter(
                    value: widget.value.clamp(0.0, 1.0),
                    dragging: _dragging,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double value;
  final bool dragging;

  _SliderPainter({required this.value, required this.dragging});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, centerY - 3, size.width, 6),
      const Radius.circular(999),
    );
    canvas.drawRRect(
      trackRect,
      Paint()..color = const Color(0x2EFFFFFF),
    );

    final filledWidth = size.width * value;
    if (filledWidth > 0) {
      final filledRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, centerY - 3, filledWidth, 6),
        const Radius.circular(999),
      );
      canvas.drawRRect(
        filledRect,
        Paint()..color = const Color(0xEBFFFFFF),
      );
    }

    final thumbCenter = Offset(filledWidth, centerY);
    final thumbRadius = dragging ? 15.0 : 14.0;
    canvas.drawCircle(
      thumbCenter,
      thumbRadius + 2,
      Paint()
        ..color = const Color(0x59000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      thumbCenter,
      thumbRadius,
      Paint()..color = const Color(0xFFFAF8F5),
    );
  }

  @override
  bool shouldRepaint(_SliderPainter old) =>
      old.value != value || old.dragging != dragging;
}

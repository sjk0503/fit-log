import 'package:flutter/widgets.dart';

import 'fl_glass.dart';
import '../icons.dart';
import '../theme.dart';
import '../tokens.dart';

/// Circular icon-only button.
///
/// Three tones cover every spot the design uses:
/// - [FLIconBtnTone.surface] — small filled chip on regular screens (40x40)
/// - [FLIconBtnTone.outline] — bordered transparent button (40x40)
/// - [FLIconBtnTone.cameraGlass] — frosted dark glass for camera chrome (40x40)
class FLIconBtn extends StatefulWidget {
  final FLIcon icon;
  final VoidCallback? onPressed;
  final FLIconBtnTone tone;
  final double size;
  final double iconSize;
  final Color? iconColor;

  const FLIconBtn({
    super.key,
    required this.icon,
    this.onPressed,
    this.tone = FLIconBtnTone.surface,
    this.size = 40,
    this.iconSize = 18,
    this.iconColor,
  });

  @override
  State<FLIconBtn> createState() => _FLIconBtnState();
}

class _FLIconBtnState extends State<FLIconBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    final disabled = widget.onPressed == null;

    Widget core() {
      final color = widget.iconColor ??
          (widget.tone == FLIconBtnTone.cameraGlass
              ? t.c.cameraFg
              : t.c.textPrimary);
      return Center(
        child: FLIconView(widget.icon,
            size: widget.iconSize,
            color: color.withValues(alpha: disabled ? 0.4 : 1.0)),
      );
    }

    Widget body;
    switch (widget.tone) {
      case FLIconBtnTone.surface:
        body = Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: t.c.bgMuted,
            border: Border.all(color: t.c.borderSubtle, width: 1),
            borderRadius: BorderRadius.circular(FLRadii.full),
          ),
          child: core(),
        );
        break;
      case FLIconBtnTone.outline:
        body = Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            border: Border.all(color: t.c.borderDefault, width: 1),
            borderRadius: BorderRadius.circular(FLRadii.full),
          ),
          child: core(),
        );
        break;
      case FLIconBtnTone.cameraGlass:
        body = SizedBox(
          width: widget.size,
          height: widget.size,
          child: FLGlass(
            tone: FLGlassTone.cameraGlass,
            borderRadius: BorderRadius.circular(FLRadii.full),
            blurSigma: 14,
            child: core(),
          ),
        );
        break;
    }

    return GestureDetector(
      onTap: disabled ? null : widget.onPressed,
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: body,
      ),
    );
  }
}

enum FLIconBtnTone { surface, outline, cameraGlass }

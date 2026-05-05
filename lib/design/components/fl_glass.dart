import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../theme.dart';
import '../tokens.dart';

/// Frosted-glass surface used everywhere a control needs to float over
/// content (camera chrome, floating action bar, sheets, dialogs, toast).
///
/// `tone` chooses the fill/stroke palette:
/// - `auto` — follows the FLTheme brightness (use on regular screens)
/// - `cameraGlass` — always-dark glass used over the live camera preview
/// - `cameraGlassStrong` — stronger dark glass for sheets over the camera
class FLGlass extends StatelessWidget {
  final Widget child;
  final FLGlassTone tone;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final List<BoxShadow>? boxShadow;

  const FLGlass({
    super.key,
    required this.child,
    this.tone = FLGlassTone.auto,
    this.borderRadius = BorderRadius.zero,
    this.padding,
    this.blurSigma = FLBlur.md,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    late final Color fill;
    late final Color stroke;
    switch (tone) {
      case FLGlassTone.auto:
        fill = t.c.glassFill;
        stroke = t.c.glassStroke;
        break;
      case FLGlassTone.cameraGlass:
        fill = t.c.cameraGlass;
        stroke = t.c.cameraStroke;
        break;
      case FLGlassTone.cameraGlassStrong:
        fill = t.c.cameraGlassStrong;
        stroke = t.c.cameraStroke;
        break;
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: stroke, width: 1),
            borderRadius: borderRadius,
            boxShadow: boxShadow,
          ),
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );
  }
}

enum FLGlassTone { auto, cameraGlass, cameraGlassStrong }

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The icon set used across Fit-Log.
///
/// SVG sources are copied verbatim from `design/primitives.jsx`. All icons are
/// 24x24, 1.6px stroke, rounded join/cap. Stroke color is templated so a single
/// SVG string can be tinted at the call site.
enum FLIcon {
  camera,
  grid,
  layers,
  split,
  overlay,
  shutter,
  flip,
  close,
  back,
  more,
  check,
  trash,
  redo,
  settings,
  globe,
  image,
  plus,
  lock,
  spark,
  ratio,
  flash,
}

class FLIconView extends StatelessWidget {
  final FLIcon icon;
  final double size;
  final Color color;
  final double strokeWidth;

  const FLIconView(
    this.icon, {
    super.key,
    this.size = 22,
    required this.color,
    this.strokeWidth = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    final hex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final svg = _svg(icon, hex, strokeWidth);
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
    );
  }
}

String _svg(FLIcon icon, String stroke, double sw) {
  final p =
      'fill="none" stroke="$stroke" stroke-width="$sw" stroke-linecap="round" stroke-linejoin="round"';
  switch (icon) {
    case FLIcon.camera:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="M3 8.5C3 7.4 3.9 6.5 5 6.5h2l1.5-2h7L17 6.5h2c1.1 0 2 .9 2 2V18a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8.5Z"/>'
          '<circle cx="12" cy="13" r="3.6" $p/>'
          '</svg>';
    case FLIcon.grid:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<rect x="3.5" y="3.5" width="7" height="7" rx="1.5" $p/>'
          '<rect x="13.5" y="3.5" width="7" height="7" rx="1.5" $p/>'
          '<rect x="3.5" y="13.5" width="7" height="7" rx="1.5" $p/>'
          '<rect x="13.5" y="13.5" width="7" height="7" rx="1.5" $p/>'
          '</svg>';
    case FLIcon.layers:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="M12 3 3 8l9 5 9-5-9-5Z"/>'
          '<path $p d="M3 13l9 5 9-5"/>'
          '</svg>';
    case FLIcon.split:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<rect x="3.5" y="3.5" width="17" height="17" rx="2.5" $p/>'
          '<path $p d="M12 4v16"/>'
          '</svg>';
    case FLIcon.overlay:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<circle cx="9" cy="11" r="5.5" $p/>'
          '<circle cx="15" cy="13" r="5.5" $p opacity="0.55"/>'
          '</svg>';
    case FLIcon.shutter:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<circle cx="12" cy="12" r="9" $p/>'
          '<circle cx="12" cy="12" r="6.2" fill="$stroke" stroke="none"/>'
          '</svg>';
    case FLIcon.flip:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="M4 7h11l-2-2"/>'
          '<path $p d="M20 17H9l2 2"/>'
          '</svg>';
    case FLIcon.close:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="M6 6l12 12M18 6 6 18"/>'
          '</svg>';
    case FLIcon.back:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="M14.5 5 7.5 12l7 7"/>'
          '</svg>';
    case FLIcon.more:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<circle cx="5.5" cy="12" r="1.4" fill="$stroke" stroke="none"/>'
          '<circle cx="12" cy="12" r="1.4" fill="$stroke" stroke="none"/>'
          '<circle cx="18.5" cy="12" r="1.4" fill="$stroke" stroke="none"/>'
          '</svg>';
    case FLIcon.check:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="m5 12.5 4.5 4.5L19 7.5"/>'
          '</svg>';
    case FLIcon.trash:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="M4 7h16M9 7V5.5A1.5 1.5 0 0 1 10.5 4h3A1.5 1.5 0 0 1 15 5.5V7M6.5 7l1 12.2c.05.7.6 1.3 1.4 1.3h6.2c.8 0 1.4-.6 1.4-1.3L17.5 7"/>'
          '</svg>';
    case FLIcon.redo:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="M20 9V4l-5 5"/>'
          '<path $p d="M20 9H9.5A5.5 5.5 0 0 0 4 14.5v0A5.5 5.5 0 0 0 9.5 20h6"/>'
          '</svg>';
    case FLIcon.settings:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<circle cx="12" cy="12" r="2.8" $p/>'
          '<path $p d="M19.5 12c0-.6-.06-1.18-.18-1.74l1.7-1.36-1.5-2.6-2.06.7a7.5 7.5 0 0 0-3-1.74L14 3h-4l-.46 2.26a7.5 7.5 0 0 0-3 1.74l-2.06-.7-1.5 2.6 1.7 1.36c-.12.56-.18 1.14-.18 1.74s.06 1.18.18 1.74l-1.7 1.36 1.5 2.6 2.06-.7a7.5 7.5 0 0 0 3 1.74L10 21h4l.46-2.26a7.5 7.5 0 0 0 3-1.74l2.06.7 1.5-2.6-1.7-1.36c.12-.56.18-1.14.18-1.74Z"/>'
          '</svg>';
    case FLIcon.globe:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<circle cx="12" cy="12" r="8.5" $p/>'
          '<path $p d="M3.5 12h17M12 3.5c2.6 2.5 4 5.5 4 8.5s-1.4 6-4 8.5c-2.6-2.5-4-5.5-4-8.5s1.4-6 4-8.5Z"/>'
          '</svg>';
    case FLIcon.image:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<rect x="3.5" y="4.5" width="17" height="15" rx="2" $p/>'
          '<circle cx="9" cy="10" r="1.6" $p/>'
          '<path $p d="m4 18 5-5 5 4 3-3 3 3"/>'
          '</svg>';
    case FLIcon.plus:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="M12 5v14M5 12h14"/>'
          '</svg>';
    case FLIcon.lock:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<rect x="4.5" y="10.5" width="15" height="10" rx="2" $p/>'
          '<path $p d="M8 10.5V7a4 4 0 0 1 8 0v3.5"/>'
          '</svg>';
    case FLIcon.spark:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="M12 4v3M12 17v3M4 12h3M17 12h3M6.5 6.5l2 2M15.5 15.5l2 2M17.5 6.5l-2 2M8.5 15.5l-2 2"/>'
          '</svg>';
    case FLIcon.ratio:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<rect x="3.5" y="3.5" width="17" height="17" rx="2" $p/>'
          '<path $p d="M8 8h3M8 8v3M16 16h-3M16 16v-3"/>'
          '</svg>';
    case FLIcon.flash:
      return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path $p d="M13 2.5 4.5 14h6l-1 7.5 9-12.5h-6l.5-7.5Z"/>'
          '</svg>';
  }
}

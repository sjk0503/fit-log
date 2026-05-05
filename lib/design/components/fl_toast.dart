import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../tokens.dart';

/// Pill-shaped toast shown briefly at the top of the screen.
///
/// Use [FLToastHost.show] from any screen — it inserts an overlay entry that
/// fades in/out, so callers don't have to manage state themselves.
class FLToastHost {
  FLToastHost._();

  static Future<void> show(
    BuildContext context, {
    required String message,
    FLIcon? icon,
    Duration duration = const Duration(milliseconds: 1800),
  }) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (_) => _FLToastWidget(message: message, icon: icon),
    );
    overlay.insert(entry);
    await Future<void>.delayed(duration);
    entry.remove();
  }
}

class _FLToastWidget extends StatefulWidget {
  final String message;
  final FLIcon? icon;

  const _FLToastWidget({required this.message, this.icon});

  @override
  State<_FLToastWidget> createState() => _FLToastWidgetState();
}

class _FLToastWidgetState extends State<_FLToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _opacity = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
    _ac.forward();
    _exitTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) _ac.reverse();
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Positioned(
      top: mq.padding.top + 16,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _slide,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FLRadii.full),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xEB1A1816),
                      borderRadius: BorderRadius.circular(FLRadii.full),
                      border: Border.all(
                          color: const Color(0x2EFFFFFF), width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x59000000),
                          offset: Offset(0, 12),
                          blurRadius: 32,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          FLIconView(widget.icon!,
                              size: 16,
                              color: const Color(0xFFFAF8F5),
                              strokeWidth: 2),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontFamily: FLFonts.sans,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFAF8F5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

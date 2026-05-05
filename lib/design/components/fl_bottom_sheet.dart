import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../theme.dart';
import '../tokens.dart';

/// Bottom sheet with a frosted background and a top grabber.
///
/// Used by the language picker and the camera reference-photo picker.
/// `builder` receives the active scroll controller; if you want a scrollable
/// body, hook it up — otherwise ignore.
Future<T?> showFLSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext) builder,
  double? heightFraction, // 0..1 of screen height
  bool dimBackground = true,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: dimBackground
          ? const Color(0x6B1A1816)
          : const Color(0x00000000),
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, a, b) => _FLSheetShell(
        heightFraction: heightFraction,
        child: builder(ctx),
      ),
      transitionsBuilder: (ctx, a, b, child) {
        final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    ),
  );
}

class _FLSheetShell extends StatelessWidget {
  final Widget child;
  final double? heightFraction;

  const _FLSheetShell({super.key, required this.child, this.heightFraction});

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    final mq = MediaQuery.of(context);
    final maxH = heightFraction != null
        ? mq.size.height * heightFraction!
        : mq.size.height * 0.8;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                constraints: BoxConstraints(maxHeight: maxH),
                decoration: BoxDecoration(
                  color: t.isDark
                      ? const Color(0xEB16140F)
                      : const Color(0xEBFAF8F5),
                  border: Border(
                    top: BorderSide(color: t.c.glassStroke, width: 1),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, bottom: 8),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: t.isDark
                                ? const Color(0x2EFFFFFF)
                                : const Color(0x2E1A1816),
                            borderRadius:
                                BorderRadius.circular(FLRadii.full),
                          ),
                        ),
                      ),
                      Flexible(child: child),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

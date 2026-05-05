import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../theme.dart';
import '../tokens.dart';
import 'fl_button.dart';

/// Confirmation dialog used for destructive or important actions.
///
/// Returns the [FLDialogAction.value] of whichever action the user picks, or
/// `null` if the dialog is dismissed by tapping the scrim.
Future<T?> showFLConfirm<T>(
  BuildContext context, {
  required String title,
  required String body,
  required FLDialogAction<T> primary,
  FLDialogAction<T>? secondary,
  bool destructive = false,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: const Color(0x6B1A1816),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, a, b) => _FLDialogShell(
        title: title,
        body: body,
        primary: primary,
        secondary: secondary,
        destructive: destructive,
      ),
      transitionsBuilder: (ctx, a, b, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    ),
  );
}

class FLDialogAction<T> {
  final String label;
  final T value;

  const FLDialogAction({required this.label, required this.value});
}

class _FLDialogShell<T> extends StatelessWidget {
  final String title;
  final String body;
  final FLDialogAction<T> primary;
  final FLDialogAction<T>? secondary;
  final bool destructive;

  const _FLDialogShell({
    super.key,
    required this.title,
    required this.body,
    required this.primary,
    this.secondary,
    required this.destructive,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: t.isDark
                          ? const Color(0xFA201D17)
                          : const Color(0xFAFFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: t.c.borderSubtle, width: 1),
                      boxShadow: t.isDark
                          ? FLShadows.darkLg
                          : FLShadows.lightLg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: FLType.titleMd.copyWith(
                              color: t.c.textPrimary, letterSpacing: -0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          body,
                          style: FLType.bodySm
                              .copyWith(color: t.c.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            if (secondary != null)
                              Expanded(
                                child: FLButton(
                                  label: secondary!.label,
                                  kind: FLButtonKind.ghost,
                                  fullWidth: true,
                                  onPressed: () => Navigator.of(context)
                                      .pop(secondary!.value),
                                ),
                              ),
                            if (secondary != null) const SizedBox(width: 8),
                            Expanded(
                              child: FLButton(
                                label: primary.label,
                                kind: FLButtonKind.primary,
                                fullWidth: true,
                                overrideBg: destructive ? t.c.danger : null,
                                onPressed: () => Navigator.of(context)
                                    .pop(primary.value),
                              ),
                            ),
                          ],
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

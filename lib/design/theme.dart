import 'package:flutter/material.dart';

import 'tokens.dart';

/// Provides Fit-Log color tokens to the widget subtree.
///
/// Visual widgets must read colors via `FLTheme.of(context).c` instead of
/// touching `FLColors.light` / `FLColors.dark` directly. The wiring at the
/// MaterialApp root flips between light and dark based on the platform
/// brightness (and any future user override).
class FLTheme extends InheritedWidget {
  final FLColors c;
  final Brightness brightness;

  const FLTheme({
    super.key,
    required this.c,
    required this.brightness,
    required super.child,
  });

  bool get isDark => brightness == Brightness.dark;

  static FLTheme of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<FLTheme>();
    assert(theme != null, 'FLTheme.of() called without a FLTheme ancestor');
    return theme!;
  }

  @override
  bool updateShouldNotify(FLTheme oldWidget) =>
      brightness != oldWidget.brightness;
}

/// Wraps [child] with an [FLTheme] derived from the platform brightness.
///
/// Drop this immediately under `MaterialApp.builder` so every screen sees the
/// right tokens without each one calling `MediaQuery` itself.
class FLThemeScope extends StatelessWidget {
  final Widget child;
  final Brightness? brightnessOverride;

  const FLThemeScope({
    super.key,
    required this.child,
    this.brightnessOverride,
  });

  @override
  Widget build(BuildContext context) {
    final brightness =
        brightnessOverride ?? MediaQuery.platformBrightnessOf(context);
    final colors =
        brightness == Brightness.dark ? FLColors.dark : FLColors.light;
    return FLTheme(
      brightness: brightness,
      c: colors,
      child: DefaultTextStyle(
        style: FLType.bodyMd.copyWith(color: colors.textPrimary),
        child: child,
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../theme.dart';
import '../tokens.dart';

enum FLButtonKind { primary, secondary, ghost, danger }

enum FLButtonSize { sm, md, lg }

/// Pill-shaped action button. Used for all CTAs and secondary actions on
/// regular screens. Camera-overlay buttons that need to float over the live
/// preview should use [FLGlass] + [FLIconBtn] instead.
class FLButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final FLButtonKind kind;
  final FLButtonSize size;
  final FLIcon? leadingIcon;
  final bool fullWidth;
  final Color? overrideBg;

  const FLButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = FLButtonKind.primary,
    this.size = FLButtonSize.md,
    this.leadingIcon,
    this.fullWidth = false,
    this.overrideBg,
  });

  @override
  State<FLButton> createState() => _FLButtonState();
}

class _FLButtonState extends State<FLButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    final disabled = widget.onPressed == null;

    final dims = switch (widget.size) {
      FLButtonSize.sm => (h: 36.0, px: 14.0, fs: 13.0, iconSize: 14.0, gap: 6.0),
      FLButtonSize.md => (h: 48.0, px: 20.0, fs: 15.0, iconSize: 16.0, gap: 8.0),
      FLButtonSize.lg => (h: 56.0, px: 24.0, fs: 16.0, iconSize: 18.0, gap: 10.0),
    };

    final palette = switch (widget.kind) {
      FLButtonKind.primary =>
        (bg: t.c.accentBrand, fg: t.c.textOnAccent, border: const Color(0x00000000)),
      FLButtonKind.secondary =>
        (bg: t.c.bgMuted, fg: t.c.textPrimary, border: t.c.borderDefault),
      FLButtonKind.ghost =>
        (bg: const Color(0x00000000), fg: t.c.textPrimary, border: t.c.borderDefault),
      FLButtonKind.danger =>
        (bg: const Color(0x00000000), fg: t.c.danger, border: t.c.borderDefault),
    };

    final bg = widget.overrideBg ?? palette.bg;
    final fg = palette.fg.withValues(alpha: disabled ? 0.4 : 1.0);

    return GestureDetector(
      onTap: disabled ? null : widget.onPressed,
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: dims.h,
          padding: EdgeInsets.symmetric(horizontal: dims.px),
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: palette.border, width: 1),
            borderRadius: BorderRadius.circular(FLRadii.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leadingIcon != null) ...[
                FLIconView(widget.leadingIcon!,
                    size: dims.iconSize, color: fg, strokeWidth: 1.8),
                SizedBox(width: dims.gap),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: FLFonts.sans,
                  fontSize: dims.fs,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

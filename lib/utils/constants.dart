// Pure data enums shared across screens / services. All visual constants
// (colors, spacing, typography) live in `lib/design/tokens.dart`.

enum CameraMode {
  split,
  overlay,
}

enum LayoutType {
  grid2x2(2, 2, '2x2'),
  grid2x3(2, 3, '2x3'),
  grid3x2(3, 2, '3x2'),
  grid3x3(3, 3, '3x3'),
  grid4x2(4, 2, '4x2'),
  grid3x4(3, 4, '3x4'),
  grid4x4(4, 4, '4x4'),
  grid5x5(5, 5, '5x5');

  final int columns;
  final int rows;
  final String label;

  const LayoutType(this.columns, this.rows, this.label);

  int get totalCells => columns * rows;
}

/// Output resolution preset for layout composition / export.
///
/// `standard` produces social-ready images (~2K square), `high` produces
/// print-ready images (~4K square). Higher takes ~4x the memory.
enum ExportResolution {
  standard(2048, 92),
  high(4096, 95);

  final int outputSize;
  final int jpegQuality;

  const ExportResolution(this.outputSize, this.jpegQuality);
}

/// Color/tone preset applied to the entire composited grid before saving.
///
/// `none` writes pixels unchanged. The other presets apply a global tone
/// shift so the saved grid feels like a coherent set even if photos were
/// taken under different lighting.
enum TonePreset {
  none('원본', 0, 0, 0, 0),
  warm('웜', 0.10, 0.0, -0.05, 0.06),
  cool('쿨', -0.08, 0.0, 0.05, 0.04),
  film('필름', 0.05, -0.05, -0.02, 0.10),
  mono('모노', 0.0, -1.0, 0.0, 0.0);

  /// Saturation delta in [-1, 1]. Negative desaturates.
  final double saturation;

  /// Hue shift toward warm (positive) / cool (negative) in [-0.2, 0.2].
  final double warmth;

  /// Contrast delta in [-0.2, 0.2].
  final double contrast;

  /// Vignette strength in [0, 0.3].
  final double vignette;

  final String label;

  const TonePreset(
    this.label,
    this.warmth,
    this.saturation,
    this.contrast,
    this.vignette,
  );
}

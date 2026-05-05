// Fit-Log Design Tokens
window.FL_TOKENS = {
  light: {
    // surfaces (warm neutral)
    "bg.canvas":        "#F4EFE8",   // app background, slightly warm
    "bg.surface":       "#FAF8F5",   // primary surface
    "bg.elevated":      "#FFFFFF",   // cards / sheets
    "bg.muted":         "#EBE5DC",   // secondary fills, dividers
    "bg.inset":         "#E2DBD0",   // pressed / inset
    "bg.scrim":         "rgba(26,24,22,0.42)",
    "glass.fill":       "rgba(255,253,250,0.72)",
    "glass.stroke":     "rgba(255,255,255,0.55)",
    // text
    "text.primary":     "#1A1816",
    "text.secondary":   "#5C5650",
    "text.muted":       "#8A8278",
    "text.disabled":    "#B5AEA4",
    "text.onAccent":    "#FFFFFF",
    "text.onBlack":     "#FAF8F5",
    // accent (warm terracotta)
    "accent.brand":     "#C2614A",
    "accent.brandHi":   "#D67459",
    "accent.brandLo":   "#A2503D",
    "accent.brandFill": "rgba(194,97,74,0.12)",
    // semantic
    "danger":           "#B0432E",
    "success":          "#5C7A4A",
    // strokes
    "border.subtle":    "rgba(26,24,22,0.06)",
    "border.default":   "rgba(26,24,22,0.10)",
    "border.strong":    "rgba(26,24,22,0.18)",
    // camera UI is always on dark
    "camera.fg":        "#FAF8F5",
    "camera.glass":     "rgba(20,18,16,0.55)",
    "camera.glassStrong":"rgba(20,18,16,0.78)",
    "camera.stroke":    "rgba(255,255,255,0.16)",
    "camera.guide":     "rgba(255,255,255,0.85)",
  },
  dark: {
    "bg.canvas":        "#0F0E0D",
    "bg.surface":       "#16140F",
    "bg.elevated":      "#201D17",
    "bg.muted":         "#2A2620",
    "bg.inset":         "#35302A",
    "bg.scrim":         "rgba(0,0,0,0.55)",
    "glass.fill":       "rgba(40,36,32,0.55)",
    "glass.stroke":     "rgba(255,255,255,0.08)",
    "text.primary":     "#F4EFE8",
    "text.secondary":   "#B6AEA3",
    "text.muted":       "#7E7770",
    "text.disabled":    "#4D4842",
    "text.onAccent":    "#1A1816",
    "text.onBlack":     "#FAF8F5",
    "accent.brand":     "#D67459",
    "accent.brandHi":   "#E68C6E",
    "accent.brandLo":   "#B25940",
    "accent.brandFill": "rgba(214,116,89,0.15)",
    "danger":           "#E07A66",
    "success":          "#A4C087",
    "border.subtle":    "rgba(255,255,255,0.05)",
    "border.default":   "rgba(255,255,255,0.09)",
    "border.strong":    "rgba(255,255,255,0.16)",
    "camera.fg":        "#FAF8F5",
    "camera.glass":     "rgba(20,18,16,0.55)",
    "camera.glassStrong":"rgba(20,18,16,0.78)",
    "camera.stroke":    "rgba(255,255,255,0.16)",
    "camera.guide":     "rgba(255,255,255,0.85)",
  },
  // shared scalars
  type: {
    fontStack: "'Pretendard', 'Pretendard Variable', -apple-system, system-ui, sans-serif",
    mono: "'JetBrains Mono', 'SF Mono', ui-monospace, monospace",
    // size / weight / line / tracking
    "display.lg": { size: 36, weight: 700, line: 1.08, track: -0.02 },
    "display.md": { size: 28, weight: 700, line: 1.12, track: -0.02 },
    "title.lg":   { size: 22, weight: 600, line: 1.20, track: -0.015 },
    "title.md":   { size: 18, weight: 600, line: 1.25, track: -0.01 },
    "title.sm":   { size: 16, weight: 600, line: 1.30, track: -0.005 },
    "body.lg":    { size: 15, weight: 500, line: 1.45, track: 0 },
    "body.md":    { size: 14, weight: 500, line: 1.45, track: 0 },
    "body.sm":    { size: 13, weight: 500, line: 1.40, track: 0 },
    "label":      { size: 12, weight: 600, line: 1.30, track: 0.02 },
    "caption":    { size: 11, weight: 500, line: 1.30, track: 0.02 },
    "mono.md":    { size: 13, weight: 500, line: 1.30, track: 0, family: "mono" },
  },
  space: { 0: 0, 1: 4, 2: 8, 3: 12, 4: 16, 5: 20, 6: 24, 7: 32, 8: 40, 9: 48, 10: 64 },
  radius: { xs: 6, sm: 10, md: 14, lg: 20, xl: 28, full: 999 },
  shadow: {
    light: {
      sm: "0 1px 2px rgba(26,24,22,0.06), 0 1px 1px rgba(26,24,22,0.04)",
      md: "0 4px 12px rgba(26,24,22,0.08), 0 1px 3px rgba(26,24,22,0.05)",
      lg: "0 16px 32px -8px rgba(26,24,22,0.16), 0 4px 8px rgba(26,24,22,0.06)",
      glow: "0 0 0 4px rgba(194,97,74,0.18)",
    },
    dark: {
      sm: "0 1px 2px rgba(0,0,0,0.40)",
      md: "0 4px 14px rgba(0,0,0,0.45)",
      lg: "0 18px 40px -8px rgba(0,0,0,0.55), 0 4px 10px rgba(0,0,0,0.40)",
      glow: "0 0 0 4px rgba(214,116,89,0.22)",
    }
  },
  blur: { sm: 8, md: 16, lg: 28 },
};

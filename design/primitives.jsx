// Fit-Log shared primitives (icons, glass surfaces, tokens helper)
const { useState, useEffect, useRef, useMemo } = React;

window.useThemeTokens = function(mode) {
  const t = window.FL_TOKENS;
  return useMemo(() => ({
    c: t[mode],
    type: t.type,
    space: t.space,
    radius: t.radius,
    shadow: t.shadow[mode],
    blur: t.blur,
    mode,
  }), [mode]);
};

// ─────── ICONS — custom-drawn, 1.5px stroke, rounded ───────
window.Icon = function Icon({ name, size = 22, color = "currentColor", strokeWidth = 1.6 }) {
  const s = { width: size, height: size, display: "block", flexShrink: 0 };
  const p = { fill: "none", stroke: color, strokeWidth, strokeLinecap: "round", strokeLinejoin: "round" };
  switch (name) {
    case "camera": return (
      <svg viewBox="0 0 24 24" style={s}>
        <path {...p} d="M3 8.5C3 7.4 3.9 6.5 5 6.5h2l1.5-2h7L17 6.5h2c1.1 0 2 .9 2 2V18a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8.5Z"/>
        <circle cx="12" cy="13" r="3.6" {...p}/>
      </svg>);
    case "grid": return (
      <svg viewBox="0 0 24 24" style={s}>
        <rect x="3.5" y="3.5" width="7" height="7" rx="1.5" {...p}/>
        <rect x="13.5" y="3.5" width="7" height="7" rx="1.5" {...p}/>
        <rect x="3.5" y="13.5" width="7" height="7" rx="1.5" {...p}/>
        <rect x="13.5" y="13.5" width="7" height="7" rx="1.5" {...p}/>
      </svg>);
    case "layers": return (
      <svg viewBox="0 0 24 24" style={s}>
        <path {...p} d="M12 3 3 8l9 5 9-5-9-5Z"/>
        <path {...p} d="M3 13l9 5 9-5"/>
      </svg>);
    case "split": return (
      <svg viewBox="0 0 24 24" style={s}>
        <rect x="3.5" y="3.5" width="17" height="17" rx="2.5" {...p}/>
        <path {...p} d="M12 4v16"/>
      </svg>);
    case "overlay": return (
      <svg viewBox="0 0 24 24" style={s}>
        <circle cx="9" cy="11" r="5.5" {...p}/>
        <circle cx="15" cy="13" r="5.5" {...p} opacity="0.55"/>
      </svg>);
    case "shutter": return (
      <svg viewBox="0 0 24 24" style={s}>
        <circle cx="12" cy="12" r="9" {...p}/>
        <circle cx="12" cy="12" r="6.2" fill={color} stroke="none"/>
      </svg>);
    case "flip": return (
      <svg viewBox="0 0 24 24" style={s}>
        <path {...p} d="M4 7h11l-2-2"/>
        <path {...p} d="M20 17H9l2 2"/>
      </svg>);
    case "close": return (
      <svg viewBox="0 0 24 24" style={s}>
        <path {...p} d="M6 6l12 12M18 6 6 18"/>
      </svg>);
    case "back": return (
      <svg viewBox="0 0 24 24" style={s}>
        <path {...p} d="M14.5 5 7.5 12l7 7"/>
      </svg>);
    case "more": return (
      <svg viewBox="0 0 24 24" style={s}>
        <circle cx="5.5" cy="12" r="1.4" fill={color} stroke="none"/>
        <circle cx="12" cy="12" r="1.4" fill={color} stroke="none"/>
        <circle cx="18.5" cy="12" r="1.4" fill={color} stroke="none"/>
      </svg>);
    case "check": return (
      <svg viewBox="0 0 24 24" style={s}>
        <path {...p} d="m5 12.5 4.5 4.5L19 7.5"/>
      </svg>);
    case "trash": return (
      <svg viewBox="0 0 24 24" style={s}>
        <path {...p} d="M4 7h16M9 7V5.5A1.5 1.5 0 0 1 10.5 4h3A1.5 1.5 0 0 1 15 5.5V7M6.5 7l1 12.2c.05.7.6 1.3 1.4 1.3h6.2c.8 0 1.4-.6 1.4-1.3L17.5 7"/>
      </svg>);
    case "redo": return (
      <svg viewBox="0 0 24 24" style={s}>
        <path {...p} d="M20 9V4l-5 5"/>
        <path {...p} d="M20 9H9.5A5.5 5.5 0 0 0 4 14.5v0A5.5 5.5 0 0 0 9.5 20h6"/>
      </svg>);
    case "settings": return (
      <svg viewBox="0 0 24 24" style={s}>
        <circle cx="12" cy="12" r="2.8" {...p}/>
        <path {...p} d="M19.5 12c0-.6-.06-1.18-.18-1.74l1.7-1.36-1.5-2.6-2.06.7a7.5 7.5 0 0 0-3-1.74L14 3h-4l-.46 2.26a7.5 7.5 0 0 0-3 1.74l-2.06-.7-1.5 2.6 1.7 1.36c-.12.56-.18 1.14-.18 1.74s.06 1.18.18 1.74l-1.7 1.36 1.5 2.6 2.06-.7a7.5 7.5 0 0 0 3 1.74L10 21h4l.46-2.26a7.5 7.5 0 0 0 3-1.74l2.06.7 1.5-2.6-1.7-1.36c.12-.56.18-1.14.18-1.74Z"/>
      </svg>);
    case "globe": return (
      <svg viewBox="0 0 24 24" style={s}>
        <circle cx="12" cy="12" r="8.5" {...p}/>
        <path {...p} d="M3.5 12h17M12 3.5c2.6 2.5 4 5.5 4 8.5s-1.4 6-4 8.5c-2.6-2.5-4-5.5-4-8.5s1.4-6 4-8.5Z"/>
      </svg>);
    case "image": return (
      <svg viewBox="0 0 24 24" style={s}>
        <rect x="3.5" y="4.5" width="17" height="15" rx="2" {...p}/>
        <circle cx="9" cy="10" r="1.6" {...p}/>
        <path {...p} d="m4 18 5-5 5 4 3-3 3 3"/>
      </svg>);
    case "plus": return (
      <svg viewBox="0 0 24 24" style={s}>
        <path {...p} d="M12 5v14M5 12h14"/>
      </svg>);
    case "lock": return (
      <svg viewBox="0 0 24 24" style={s}>
        <rect x="4.5" y="10.5" width="15" height="10" rx="2" {...p}/>
        <path {...p} d="M8 10.5V7a4 4 0 0 1 8 0v3.5"/>
      </svg>);
    case "spark": return (
      <svg viewBox="0 0 24 24" style={s}>
        <path {...p} d="M12 4v3M12 17v3M4 12h3M17 12h3M6.5 6.5l2 2M15.5 15.5l2 2M17.5 6.5l-2 2M8.5 15.5l-2 2"/>
      </svg>);
    case "ratio": return (
      <svg viewBox="0 0 24 24" style={s}>
        <rect x="3.5" y="3.5" width="17" height="17" rx="2" {...p}/>
        <path {...p} d="M8 8h3M8 8v3M16 16h-3M16 16v-3"/>
      </svg>);
    default: return null;
  }
};

// Glass surface
window.Glass = function Glass({ children, dark, style, ...rest }) {
  const fill = dark ? "rgba(20,18,16,0.55)" : "rgba(255,253,250,0.72)";
  const stroke = dark ? "rgba(255,255,255,0.08)" : "rgba(255,255,255,0.55)";
  return (
    <div style={{
      background: fill,
      backdropFilter: "blur(16px) saturate(160%)",
      WebkitBackdropFilter: "blur(16px) saturate(160%)",
      border: `1px solid ${stroke}`,
      ...style,
    }} {...rest}>{children}</div>
  );
};

// Status bar (no system look)
window.StatusBar = function StatusBar({ tone = "dark" }) {
  const fg = tone === "light" ? "#FAF8F5" : "#1A1816";
  return (
    <div style={{
      height: 44, padding: "0 22px", display: "flex", alignItems: "center",
      justifyContent: "space-between", color: fg, fontSize: 14, fontWeight: 600,
      letterSpacing: -0.2, fontFeatureSettings: '"tnum"',
    }}>
      <span>9:41</span>
      <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
        {/* signal */}
        <svg width="17" height="11" viewBox="0 0 17 11"><g fill={fg}>
          <rect x="0" y="7" width="3" height="4" rx="0.6"/>
          <rect x="4.5" y="5" width="3" height="6" rx="0.6"/>
          <rect x="9" y="3" width="3" height="8" rx="0.6"/>
          <rect x="13.5" y="0" width="3" height="11" rx="0.6"/>
        </g></svg>
        {/* battery */}
        <svg width="26" height="12" viewBox="0 0 26 12">
          <rect x="0.5" y="0.5" width="22" height="11" rx="2.6" fill="none" stroke={fg} strokeOpacity="0.4"/>
          <rect x="2" y="2" width="19" height="8" rx="1.4" fill={fg}/>
          <rect x="23.5" y="3.5" width="2" height="5" rx="1" fill={fg} opacity="0.5"/>
        </svg>
      </div>
    </div>
  );
};

// Custom button — pill, glass-on-camera, solid-on-light
window.FLButton = function FLButton({ children, kind = "primary", size = "md", icon, onClick, dark, fullWidth, style }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  const sizes = {
    sm: { h: 36, px: 14, fs: 13 },
    md: { h: 48, px: 20, fs: 15 },
    lg: { h: 56, px: 24, fs: 16 },
  }[size];
  const palette = {
    primary: { bg: c["accent.brand"], fg: c["text.onAccent"], border: "transparent" },
    secondary: { bg: c["bg.muted"], fg: c["text.primary"], border: c["border.default"] },
    ghost: { bg: "transparent", fg: c["text.primary"], border: c["border.default"] },
    danger: { bg: "transparent", fg: c["danger"], border: c["border.default"] },
  }[kind];
  return (
    <button onClick={onClick} style={{
      height: sizes.h, padding: `0 ${sizes.px}px`,
      background: palette.bg, color: palette.fg,
      border: `1px solid ${palette.border}`,
      borderRadius: 999,
      fontSize: sizes.fs, fontWeight: 600, letterSpacing: -0.1,
      display: "inline-flex", alignItems: "center", justifyContent: "center", gap: 8,
      width: fullWidth ? "100%" : "auto",
      cursor: "pointer", fontFamily: "inherit",
      ...style,
    }}>
      {icon}
      {children}
    </button>
  );
};

// Custom slider — opacity slider for overlay mode
window.FLSlider = function FLSlider({ value, onChange, dark, label, min = 0, max = 100, suffix = "%" }) {
  const ref = useRef();
  const [drag, setDrag] = useState(false);
  const pct = ((value - min) / (max - min)) * 100;
  const start = (e) => {
    setDrag(true);
    move(e);
    window.addEventListener("mousemove", move);
    window.addEventListener("mouseup", end);
  };
  const move = (e) => {
    const r = ref.current.getBoundingClientRect();
    const x = (e.clientX || (e.touches && e.touches[0].clientX)) - r.left;
    const v = Math.max(min, Math.min(max, Math.round(min + (x / r.width) * (max - min))));
    onChange(v);
  };
  const end = () => { setDrag(false); window.removeEventListener("mousemove", move); window.removeEventListener("mouseup", end); };

  return (
    <div style={{ width: "100%", userSelect: "none" }}>
      {label && <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 10, color: "#FAF8F5", fontSize: 12, fontWeight: 600, letterSpacing: 0.4, textTransform: "uppercase" }}>
        <span>{label}</span>
        <span style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 13, letterSpacing: 0 }}>{value}{suffix}</span>
      </div>}
      <div ref={ref} onMouseDown={start} style={{
        position: "relative", height: 32, display: "flex", alignItems: "center",
        cursor: "pointer", touchAction: "none",
      }}>
        <div style={{ position: "absolute", left: 0, right: 0, height: 6, borderRadius: 999, background: "rgba(255,255,255,0.18)" }}/>
        <div style={{ position: "absolute", left: 0, width: `${pct}%`, height: 6, borderRadius: 999, background: "rgba(255,255,255,0.92)" }}/>
        <div style={{
          position: "absolute", left: `calc(${pct}% - 14px)`, width: 28, height: 28, borderRadius: 999,
          background: "#FAF8F5",
          boxShadow: "0 4px 12px rgba(0,0,0,0.35), 0 0 0 1px rgba(0,0,0,0.05)",
          transform: drag ? "scale(1.08)" : "scale(1)",
          transition: drag ? "none" : "transform 0.15s ease",
        }}/>
      </div>
    </div>
  );
};

// Toast — small pill
window.FLToast = function FLToast({ children, dark, icon }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <div style={{
      display: "inline-flex", alignItems: "center", gap: 10,
      padding: "12px 18px",
      background: dark ? "rgba(40,36,32,0.92)" : "rgba(26,24,22,0.92)",
      backdropFilter: "blur(20px)",
      WebkitBackdropFilter: "blur(20px)",
      color: "#FAF8F5",
      borderRadius: 999,
      fontSize: 13, fontWeight: 500,
      boxShadow: "0 12px 32px rgba(0,0,0,0.35)",
      border: `1px solid ${dark ? "rgba(255,255,255,0.08)" : "rgba(255,255,255,0.18)"}`,
    }}>
      {icon && <Icon name={icon} size={16} color="#FAF8F5"/>}
      {children}
    </div>
  );
};

Object.assign(window, { useThemeTokens: window.useThemeTokens });

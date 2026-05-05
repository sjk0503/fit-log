// Phone screen frame & placeholder photo system
const { useState: useState_p, useEffect: useEffect_p, useMemo: useMemo_p } = React;

// Phone — pure rounded screen (no bezel), 390×844
window.PhoneScreen = function PhoneScreen({ children, dark, style }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <div style={{
      width: 390, height: 844,
      background: c["bg.canvas"],
      borderRadius: 44,
      overflow: "hidden",
      position: "relative",
      color: c["text.primary"],
      fontFamily: window.FL_TOKENS.type.fontStack,
      boxShadow: dark
        ? "0 30px 60px -20px rgba(0,0,0,0.45), 0 0 0 1px rgba(255,255,255,0.04)"
        : "0 30px 60px -20px rgba(26,24,22,0.18), 0 0 0 1px rgba(26,24,22,0.06)",
      ...style,
    }}>{children}</div>
  );
};

// Photo placeholder — generates a unique pseudo-photo SVG per id (stripes + tint + icon),
// labelled with monospace caption to make clear this is a placeholder.
window.Photo = function Photo({ id = 0, label, ratio = "1:1", style, mode = "card", showLabel = true }) {
  const palettes = [
    ["#D7C7AE", "#C2B099", "OOTD · 베이지"],
    ["#A8B5A8", "#90A090", "OOTD · 올리브"],
    ["#C8B8C8", "#A89AA8", "OOTD · 라일락"],
    ["#B8A89A", "#9A8A7C", "OOTD · 모카"],
    ["#9DAABF", "#7E8DA6", "OOTD · 슬레이트"],
    ["#D9B8A0", "#B8967E", "OOTD · 테라"],
    ["#B0B0B0", "#909090", "OOTD · 그레이"],
    ["#C9CFC0", "#A9B0A0", "OOTD · 세이지"],
    ["#E0CDB5", "#C0AD95", "OOTD · 샌드"],
    ["#9A9A9A", "#7A7A7A", "OOTD · 차콜"],
    ["#BFA9C6", "#9F89A6", "OOTD · 와인"],
    ["#A1B0AC", "#81908C", "OOTD · 민트"],
  ];
  const p = palettes[((id % palettes.length) + palettes.length) % palettes.length];
  const [c1, c2, name] = p;
  return (
    <div style={{
      width: "100%", height: "100%", position: "relative", overflow: "hidden",
      background: `linear-gradient(160deg, ${c1} 0%, ${c2} 100%)`,
      ...style,
    }}>
      {/* diagonal stripe pattern */}
      <svg width="100%" height="100%" style={{ position: "absolute", inset: 0, opacity: 0.18 }}>
        <defs>
          <pattern id={`stripe-${id}`} patternUnits="userSpaceOnUse" width="14" height="14" patternTransform="rotate(35)">
            <line x1="0" y1="0" x2="0" y2="14" stroke="rgba(0,0,0,0.55)" strokeWidth="1"/>
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill={`url(#stripe-${id})`}/>
      </svg>
      {/* simple silhouette suggestion of a person */}
      <svg viewBox="0 0 100 140" style={{ position: "absolute", left: "50%", top: "50%", transform: "translate(-50%, -50%)", width: "55%", opacity: 0.32 }}>
        <circle cx="50" cy="32" r="13" fill="rgba(0,0,0,0.4)"/>
        <path d="M22 130 C22 90 30 65 50 65 C70 65 78 90 78 130 Z" fill="rgba(0,0,0,0.4)"/>
      </svg>
      {showLabel && mode !== "tile" && (
        <div style={{
          position: "absolute", left: 8, bottom: 8,
          fontFamily: "'JetBrains Mono', monospace",
          fontSize: 9, color: "rgba(0,0,0,0.55)",
          padding: "3px 7px", borderRadius: 4,
          background: "rgba(255,255,255,0.45)",
          letterSpacing: 0.2,
        }}>{label || name}</div>
      )}
    </div>
  );
};

// Fit-Log — Design Tokens reference page
const { useState: uS3 } = React;

window.Screen_Tokens = function Screen_Tokens({ dark }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  const t = window.FL_TOKENS.type;

  return (
    <div style={{
      width: 1140, padding: 48,
      background: c["bg.canvas"], color: c["text.primary"],
      fontFamily: t.fontStack, minHeight: 1500,
    }}>
      {/* Header */}
      <div style={{ marginBottom: 40 }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: c["text.muted"], letterSpacing: 1.4, textTransform: "uppercase" }}>FIT—LOG · DESIGN TOKENS</div>
        <div style={{ fontSize: 44, fontWeight: 700, color: c["text.primary"], letterSpacing: -1, marginTop: 8 }}>{dark ? "다크 모드 토큰" : "라이트 모드 토큰"}</div>
        <div style={{ fontSize: 15, color: c["text.secondary"], marginTop: 8, maxWidth: 560, lineHeight: 1.55 }}>
          Flutter 코드에 그대로 옮길 수 있도록 시맨틱 네이밍으로 정리했습니다. 모든 컴포넌트는 OS 기본 위젯이 아닌 자체 구현입니다.
        </div>
      </div>

      {/* Colors */}
      <Section title="01 · Color" dark={dark}>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 12 }}>
          {Object.entries(window.FL_TOKENS[dark ? "dark" : "light"]).map(([k, v]) => (
            <Swatch key={k} name={k} value={v} dark={dark}/>
          ))}
        </div>
      </Section>

      {/* Type */}
      <Section title="02 · Typography" dark={dark}>
        <div style={{ display: "flex", flexDirection: "column", gap: 4 }}>
          {Object.entries(t).filter(([k]) => !["fontStack", "mono"].includes(k)).map(([k, spec]) => (
            <TypeRow key={k} name={k} spec={spec} dark={dark}/>
          ))}
        </div>
      </Section>

      {/* Spacing */}
      <Section title="03 · Spacing" dark={dark}>
        <div style={{ display: "flex", alignItems: "flex-end", gap: 16 }}>
          {Object.entries(window.FL_TOKENS.space).map(([k, v]) => (
            <div key={k} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 8 }}>
              <div style={{ width: Math.max(v, 4), height: Math.max(v, 4), background: c["accent.brand"], borderRadius: 2 }}/>
              <div style={{ fontSize: 11, fontFamily: "'JetBrains Mono', monospace", color: c["text.muted"] }}>space-{k}</div>
              <div style={{ fontSize: 13, fontWeight: 600 }}>{v}px</div>
            </div>
          ))}
        </div>
      </Section>

      {/* Radius */}
      <Section title="04 · Radius" dark={dark}>
        <div style={{ display: "flex", gap: 16 }}>
          {Object.entries(window.FL_TOKENS.radius).map(([k, v]) => (
            <div key={k} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 10 }}>
              <div style={{
                width: 80, height: 80,
                background: c["bg.elevated"], borderRadius: Math.min(v, 40),
                border: `1px solid ${c["border.subtle"]}`,
              }}/>
              <div style={{ fontSize: 11, fontFamily: "'JetBrains Mono', monospace", color: c["text.muted"] }}>radius-{k}</div>
              <div style={{ fontSize: 13, fontWeight: 600 }}>{v === 999 ? "full" : `${v}px`}</div>
            </div>
          ))}
        </div>
      </Section>

      {/* Shadow */}
      <Section title="05 · Shadow & Blur" dark={dark}>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 16 }}>
          {Object.entries(window.FL_TOKENS.shadow[dark ? "dark" : "light"]).map(([k, v]) => (
            <div key={k} style={{ padding: 24, background: c["bg.canvas"] }}>
              <div style={{
                height: 80, borderRadius: 16,
                background: c["bg.elevated"], boxShadow: v,
                border: `1px solid ${c["border.subtle"]}`,
              }}/>
              <div style={{ fontSize: 11, fontFamily: "'JetBrains Mono', monospace", color: c["text.muted"], marginTop: 14 }}>shadow-{k}</div>
            </div>
          ))}
        </div>
        <div style={{ display: "flex", gap: 16, marginTop: 24 }}>
          {Object.entries(window.FL_TOKENS.blur).map(([k, v]) => (
            <div key={k} style={{ flex: 1, position: "relative", height: 80, borderRadius: 14, overflow: "hidden", background: `linear-gradient(120deg, ${c["accent.brand"]} 0%, ${c["accent.brandHi"]} 100%)` }}>
              <div style={{ position: "absolute", inset: 0, background: "rgba(0,0,0,0.04)", backdropFilter: `blur(${v}px)`, WebkitBackdropFilter: `blur(${v}px)`, display: "flex", alignItems: "center", justifyContent: "center", color: "#FFF", fontSize: 12, fontWeight: 600, fontFamily: "'JetBrains Mono', monospace" }}>
                blur-{k} · {v}px
              </div>
            </div>
          ))}
        </div>
      </Section>

      {/* Component states */}
      <Section title="06 · Components & States" dark={dark}>
        <CompRow label="Button · primary" dark={dark}>
          <window.FLButton dark={dark} kind="primary">Default</window.FLButton>
          <window.FLButton dark={dark} kind="primary" style={{ background: c["accent.brandLo"] }}>Pressed</window.FLButton>
          <window.FLButton dark={dark} kind="primary" style={{ opacity: 0.4, cursor: "not-allowed" }}>Disabled</window.FLButton>
          <window.FLButton dark={dark} kind="primary" style={{ boxShadow: window.FL_TOKENS.shadow[dark ? "dark" : "light"].glow }}>Focus</window.FLButton>
        </CompRow>
        <CompRow label="Button · secondary / ghost / danger" dark={dark}>
          <window.FLButton dark={dark} kind="secondary">Secondary</window.FLButton>
          <window.FLButton dark={dark} kind="ghost">Ghost</window.FLButton>
          <window.FLButton dark={dark} kind="danger">삭제</window.FLButton>
        </CompRow>
        <CompRow label="Slider · 0-100%" dark={dark}>
          <div style={{ width: 320, padding: 16, background: "#0A0908", borderRadius: 16 }}>
            <window.FLSlider value={45} onChange={() => {}} label="투명도"/>
          </div>
        </CompRow>
        <CompRow label="Toast · pill" dark={dark}>
          <window.FLToast dark={dark} icon="check">사진이 저장되었어요</window.FLToast>
          <window.FLToast dark={dark} icon="redo">레퍼런스가 변경되었어요</window.FLToast>
        </CompRow>
      </Section>
    </div>
  );
};

function Section({ title, dark, children }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <div style={{ marginBottom: 56 }}>
      <div style={{ fontSize: 14, fontWeight: 700, letterSpacing: 0.4, color: c["text.muted"], textTransform: "uppercase", fontFamily: "'JetBrains Mono', monospace", marginBottom: 20 }}>{title}</div>
      {children}
    </div>
  );
}

function Swatch({ name, value, dark }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <div style={{ display: "flex", gap: 12, alignItems: "center", padding: 8, background: c["bg.elevated"], borderRadius: 12, border: `1px solid ${c["border.subtle"]}` }}>
      <div style={{ width: 44, height: 44, borderRadius: 8, background: value, border: `1px solid ${c["border.subtle"]}`, flexShrink: 0 }}/>
      <div style={{ minWidth: 0, flex: 1 }}>
        <div style={{ fontSize: 11, fontFamily: "'JetBrains Mono', monospace", fontWeight: 600, color: c["text.primary"], letterSpacing: 0.2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{name}</div>
        <div style={{ fontSize: 10, fontFamily: "'JetBrains Mono', monospace", color: c["text.muted"], marginTop: 2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{value}</div>
      </div>
    </div>
  );
}

function TypeRow({ name, spec, dark }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <div style={{ display: "grid", gridTemplateColumns: "180px 1fr 320px", padding: "14px 0", borderBottom: `1px solid ${c["border.subtle"]}`, alignItems: "baseline" }}>
      <div style={{ fontSize: 12, fontFamily: "'JetBrains Mono', monospace", color: c["text.muted"] }}>{name}</div>
      <div style={{
        fontSize: spec.size, fontWeight: spec.weight,
        lineHeight: spec.line, letterSpacing: `${spec.track}em`,
        fontFamily: spec.family === "mono" ? "'JetBrains Mono', monospace" : "inherit",
        color: c["text.primary"],
      }}>{spec.family === "mono" ? "2026.05.05  09:42" : "오늘의 OOTD"}</div>
      <div style={{ fontSize: 11, fontFamily: "'JetBrains Mono', monospace", color: c["text.muted"], textAlign: "right" }}>
        {spec.size}/{Math.round(spec.line * spec.size * 10) / 10} · {spec.weight} · {spec.track}em
      </div>
    </div>
  );
}

function CompRow({ label, dark, children }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <div style={{ marginBottom: 20 }}>
      <div style={{ fontSize: 11, fontFamily: "'JetBrains Mono', monospace", color: c["text.muted"], marginBottom: 12, letterSpacing: 0.4 }}>{label}</div>
      <div style={{ display: "flex", gap: 12, flexWrap: "wrap", alignItems: "center", padding: 24, background: c["bg.elevated"], borderRadius: 16, border: `1px solid ${c["border.subtle"]}` }}>
        {children}
      </div>
    </div>
  );
}

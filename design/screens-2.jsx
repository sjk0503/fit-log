// Fit-Log screens — Camera (Split, Overlay), Reference picker, Language sheet, Tutorial overlay
const { useState: uS2, useEffect: uE2 } = React;

// Common camera chrome
function CameraTopBar({ mode, onModeChange }) {
  return (
    <div style={{ position: "absolute", top: 44, left: 0, right: 0, padding: "12px 16px", display: "flex", alignItems: "center", justifyContent: "space-between", zIndex: 10 }}>
      <CamCircle><window.Icon name="close" size={20} color="#FAF8F5"/></CamCircle>
      {/* Mode toggle pill */}
      <window.Glass dark style={{ borderRadius: 999, padding: 4, display: "flex", alignItems: "center" }}>
        {[
          { key: "split", label: "분할", icon: "split" },
          { key: "overlay", label: "오버레이", icon: "overlay" },
        ].map(m => {
          const active = mode === m.key;
          return (
            <button key={m.key} onClick={() => onModeChange?.(m.key)} style={{
              height: 36, padding: "0 14px",
              borderRadius: 999,
              background: active ? "#FAF8F5" : "transparent",
              color: active ? "#1A1816" : "#FAF8F5",
              border: "none",
              fontSize: 13, fontWeight: 600,
              display: "inline-flex", alignItems: "center", gap: 6,
              cursor: "pointer", fontFamily: "inherit",
            }}>
              <window.Icon name={m.icon} size={14} color={active ? "#1A1816" : "#FAF8F5"}/>
              {m.label}
            </button>
          );
        })}
      </window.Glass>
      <CamCircle><window.Icon name="settings" size={18} color="#FAF8F5"/></CamCircle>
    </div>
  );
}

function CamCircle({ children, onClick }) {
  return (
    <button onClick={onClick} style={{
      width: 40, height: 40, borderRadius: 999,
      background: "rgba(20,18,16,0.55)",
      backdropFilter: "blur(14px) saturate(150%)",
      WebkitBackdropFilter: "blur(14px) saturate(150%)",
      border: "1px solid rgba(255,255,255,0.10)",
      display: "flex", alignItems: "center", justifyContent: "center",
      cursor: "pointer",
    }}>{children}</button>
  );
}

// Live preview placeholder (dark with vignette)
function LivePreview({ mirror }) {
  return (
    <div style={{
      width: "100%", height: "100%",
      background: "radial-gradient(ellipse at 50% 35%, #2A2620 0%, #15110D 70%, #0A0908 100%)",
      position: "relative", overflow: "hidden",
    }}>
      {/* faint silhouette suggesting live view */}
      <svg viewBox="0 0 100 140" style={{ position: "absolute", left: "50%", top: "55%", transform: `translate(-50%, -50%) ${mirror ? "scaleX(-1)" : ""}`, width: "60%", opacity: 0.35 }}>
        <circle cx="50" cy="38" r="14" fill="rgba(250,248,245,0.18)"/>
        <path d="M22 130 C22 88 30 62 50 62 C70 62 78 88 78 130 Z" fill="rgba(250,248,245,0.18)"/>
      </svg>
      {/* "LIVE" indicator */}
      <div style={{
        position: "absolute", top: 12, left: 12,
        display: "inline-flex", alignItems: "center", gap: 6,
        padding: "4px 10px", borderRadius: 999,
        background: "rgba(0,0,0,0.45)", backdropFilter: "blur(6px)",
        fontFamily: "'JetBrains Mono', monospace", fontSize: 10, color: "#FAF8F5", letterSpacing: 0.6,
      }}>
        <span style={{ width: 6, height: 6, borderRadius: 999, background: "#C2614A" }}/>
        LIVE
      </div>
    </div>
  );
}

// Reference photo (left side of split, or overlay image)
function ReferenceView({ id = 4, label = "REF" }) {
  return (
    <div style={{ width: "100%", height: "100%", position: "relative" }}>
      <window.Photo id={id} showLabel={false}/>
      <div style={{
        position: "absolute", top: 12, left: 12,
        padding: "4px 10px", borderRadius: 999,
        background: "rgba(0,0,0,0.45)", backdropFilter: "blur(6px)",
        fontFamily: "'JetBrains Mono', monospace", fontSize: 10, color: "#FAF8F5", letterSpacing: 0.6,
      }}>{label}</div>
    </div>
  );
}

// Bottom shutter row — shared
function ShutterRow({ children, onSwap }) {
  return (
    <div style={{
      position: "absolute", bottom: 28, left: 0, right: 0,
      display: "flex", alignItems: "center", justifyContent: "space-between",
      padding: "0 32px", zIndex: 10,
    }}>
      <button style={{
        width: 56, height: 56, borderRadius: 18,
        background: "rgba(20,18,16,0.55)",
        backdropFilter: "blur(14px) saturate(150%)",
        WebkitBackdropFilter: "blur(14px) saturate(150%)",
        border: "1px solid rgba(255,255,255,0.10)",
        display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer",
      }}>
        <window.Icon name="image" size={22} color="#FAF8F5"/>
      </button>

      {/* Shutter */}
      <button style={{
        width: 76, height: 76, borderRadius: 999,
        padding: 0, background: "transparent",
        border: "3px solid rgba(255,255,255,0.92)",
        display: "flex", alignItems: "center", justifyContent: "center",
        cursor: "pointer",
        boxShadow: "0 8px 24px rgba(0,0,0,0.4)",
      }}>
        <div style={{ width: 60, height: 60, borderRadius: 999, background: "#FAF8F5" }}/>
      </button>

      <button onClick={onSwap} style={{
        width: 56, height: 56, borderRadius: 18,
        background: "rgba(20,18,16,0.55)",
        backdropFilter: "blur(14px) saturate(150%)",
        WebkitBackdropFilter: "blur(14px) saturate(150%)",
        border: "1px solid rgba(255,255,255,0.10)",
        display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer",
      }}>
        <window.Icon name="flip" size={22} color="#FAF8F5"/>
      </button>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// 2. CAMERA — SPLIT MODE
// ─────────────────────────────────────────────────────────────────
window.Screen_CameraSplit = function Screen_CameraSplit({ refLeft = true, showTutorial = false }) {
  return (
    <div style={{ width: "100%", height: "100%", background: "#0A0908", position: "relative", overflow: "hidden" }}>
      <window.StatusBar tone="light"/>
      <div style={{ position: "absolute", inset: 0, display: "flex" }}>
        <div style={{ width: "50%", height: "100%" }}>
          {refLeft ? <ReferenceView id={4} label="REF · 어제"/> : <LivePreview/>}
        </div>
        <div style={{ width: "50%", height: "100%" }}>
          {refLeft ? <LivePreview/> : <ReferenceView id={4} label="REF · 어제"/>}
        </div>
      </div>

      {/* Center divider — thin warm line */}
      <div style={{
        position: "absolute", left: "50%", top: 0, bottom: 0,
        width: 1, background: "rgba(255,255,255,0.55)",
        boxShadow: "0 0 0 1px rgba(0,0,0,0.15)",
      }}/>
      {/* Center alignment ticks (top/center/bottom) */}
      {[0.18, 0.5, 0.82].map((y, i) => (
        <div key={i} style={{
          position: "absolute", left: "calc(50% - 9px)", top: `${y * 100}%`,
          width: 18, height: 18, borderRadius: 999,
          background: "rgba(255,255,255,0.95)",
          border: "1px solid rgba(0,0,0,0.15)",
          display: "flex", alignItems: "center", justifyContent: "center",
        }}>
          <div style={{ width: 4, height: 4, borderRadius: 999, background: "#1A1816" }}/>
        </div>
      ))}

      <CameraTopBar mode="split"/>

      {/* Mode hint pill */}
      <div style={{ position: "absolute", top: 110, left: "50%", transform: "translateX(-50%)", zIndex: 10 }}>
        <window.Glass dark style={{
          padding: "8px 14px", borderRadius: 999, color: "#FAF8F5",
          fontSize: 12, fontWeight: 500, letterSpacing: -0.1,
          display: "inline-flex", alignItems: "center", gap: 8,
        }}>
          <span style={{ width: 4, height: 4, borderRadius: 999, background: "#FAF8F5", opacity: 0.8 }}/>
          분할선에 어깨를 맞춰보세요
        </window.Glass>
      </div>

      {/* L/R swap button at bottom-center above shutter */}
      <div style={{ position: "absolute", bottom: 124, left: "50%", transform: "translateX(-50%)", zIndex: 10 }}>
        <button style={{
          padding: "8px 14px", borderRadius: 999,
          background: "rgba(20,18,16,0.55)",
          backdropFilter: "blur(14px) saturate(150%)",
          WebkitBackdropFilter: "blur(14px) saturate(150%)",
          border: "1px solid rgba(255,255,255,0.10)",
          color: "#FAF8F5", fontSize: 12, fontWeight: 600,
          display: "inline-flex", alignItems: "center", gap: 6,
          cursor: "pointer", fontFamily: "inherit",
        }}>
          <window.Icon name="flip" size={14} color="#FAF8F5"/>
          좌우 바꾸기
        </button>
      </div>

      <ShutterRow/>

      {showTutorial && <TutorialOverlay
        title="분할 모드"
        body="화면 중앙선을 가이드 삼아 어제와 같은 자세로 서보세요. 양쪽 사진의 어깨·허리 라인이 분할선에서 만나도록 맞추면 됩니다."
        step={1}
      />}
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────
// 3. CAMERA — OVERLAY MODE
// ─────────────────────────────────────────────────────────────────
window.Screen_CameraOverlay = function Screen_CameraOverlay({ opacity: opa = 45 }) {
  const [opacity, setOpacity] = uS2(opa);
  return (
    <div style={{ width: "100%", height: "100%", background: "#0A0908", position: "relative", overflow: "hidden" }}>
      <window.StatusBar tone="light"/>

      <div style={{ position: "absolute", inset: 0 }}>
        <LivePreview/>
        {/* Overlayed reference */}
        <div style={{ position: "absolute", inset: 0, opacity: opacity / 100, mixBlendMode: "normal" }}>
          <window.Photo id={4} showLabel={false}/>
        </div>
      </div>

      <CameraTopBar mode="overlay"/>

      {/* Reference badge */}
      <div style={{ position: "absolute", top: 110, left: 16, zIndex: 10 }}>
        <window.Glass dark style={{
          padding: "6px 6px 6px 12px", borderRadius: 999, color: "#FAF8F5",
          display: "inline-flex", alignItems: "center", gap: 8,
        }}>
          <span style={{ fontSize: 11, fontWeight: 500, opacity: 0.8 }}>레퍼런스</span>
          <div style={{ width: 28, height: 28, borderRadius: 999, overflow: "hidden", border: "1px solid rgba(255,255,255,0.18)" }}>
            <window.Photo id={4} showLabel={false}/>
          </div>
        </window.Glass>
      </div>

      {/* Opacity slider — glass capsule */}
      <div style={{ position: "absolute", left: 16, right: 16, bottom: 124, zIndex: 10 }}>
        <window.Glass dark style={{ padding: "16px 20px", borderRadius: 24 }}>
          <window.FLSlider value={opacity} onChange={setOpacity} label="투명도"/>
        </window.Glass>
      </div>

      <ShutterRow/>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────
// 4. REFERENCE PICKER (bottom sheet over camera)
// ─────────────────────────────────────────────────────────────────
window.Screen_RefPicker = function Screen_RefPicker({ dark }) {
  const photos = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  return (
    <div style={{ width: "100%", height: "100%", background: "#0A0908", position: "relative", overflow: "hidden" }}>
      {/* dimmed camera in back */}
      <div style={{ position: "absolute", inset: 0, opacity: 0.35 }}>
        <LivePreview/>
      </div>
      <div style={{ position: "absolute", inset: 0, background: "rgba(10,9,8,0.55)" }}/>

      <window.StatusBar tone="light"/>

      {/* Sheet */}
      <div style={{
        position: "absolute", bottom: 0, left: 0, right: 0,
        height: 640,
        background: dark ? "rgba(22,20,15,0.92)" : "rgba(250,248,245,0.92)",
        backdropFilter: "blur(28px) saturate(160%)",
        WebkitBackdropFilter: "blur(28px) saturate(160%)",
        borderRadius: "28px 28px 0 0",
        border: dark ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(255,255,255,0.55)",
        borderBottom: "none",
        padding: "10px 0 0",
        color: dark ? "#F4EFE8" : "#1A1816",
      }}>
        {/* grabber */}
        <div style={{ width: 40, height: 4, borderRadius: 999, background: dark ? "rgba(255,255,255,0.18)" : "rgba(26,24,22,0.18)", margin: "0 auto" }}/>

        {/* Header */}
        <div style={{ padding: "16px 22px 14px", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <div>
            <div style={{ fontSize: 11, fontWeight: 600, letterSpacing: 1.2, textTransform: "uppercase", color: dark ? "#7E7770" : "#8A8278" }}>
              REFERENCE
            </div>
            <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4, marginTop: 4 }}>
              레퍼런스 사진 선택
            </div>
          </div>
          <button style={{
            width: 36, height: 36, borderRadius: 999,
            background: dark ? "rgba(255,255,255,0.06)" : "rgba(26,24,22,0.06)",
            border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer",
          }}>
            <window.Icon name="close" size={16} color={dark ? "#F4EFE8" : "#1A1816"}/>
          </button>
        </div>

        {/* Tabs */}
        <div style={{ padding: "0 22px 10px", display: "flex", gap: 6 }}>
          {[
            { k: "lib", label: "내 OOTD", n: 48 },
            { k: "alb", label: "사진첩", n: null },
            { k: "rec", label: "최근", n: 12 },
          ].map((t, i) => (
            <button key={t.k} style={{
              padding: "8px 14px", borderRadius: 999,
              background: i === 0 ? (dark ? "#F4EFE8" : "#1A1816") : "transparent",
              color: i === 0 ? (dark ? "#1A1816" : "#FAF8F5") : (dark ? "#B6AEA3" : "#5C5650"),
              border: i === 0 ? "none" : `1px solid ${dark ? "rgba(255,255,255,0.10)" : "rgba(26,24,22,0.10)"}`,
              fontSize: 13, fontWeight: 600, cursor: "pointer", fontFamily: "inherit",
              display: "inline-flex", alignItems: "center", gap: 6,
            }}>
              {t.label}
              {t.n != null && <span style={{
                fontSize: 11, fontFamily: "'JetBrains Mono', monospace",
                opacity: 0.6, marginLeft: 2,
              }}>{t.n}</span>}
            </button>
          ))}
        </div>

        {/* Grid */}
        <div style={{ padding: "8px 22px 24px", overflow: "auto", maxHeight: 480 }}>
          <div style={{ fontSize: 11, fontFamily: "'JetBrains Mono', monospace", color: dark ? "#7E7770" : "#8A8278", marginBottom: 8, letterSpacing: 0.4 }}>
            2026.05.04 · 어제
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 6 }}>
            {photos.slice(0, 4).map((p, i) => (
              <div key={i} style={{ aspectRatio: "1/1", borderRadius: 10, overflow: "hidden", position: "relative", border: i === 1 ? "2px solid #C2614A" : "none" }}>
                <window.Photo id={p} showLabel={false}/>
                {i === 1 && (
                  <div style={{
                    position: "absolute", top: 4, right: 4,
                    width: 20, height: 20, borderRadius: 999,
                    background: "#C2614A", display: "flex", alignItems: "center", justifyContent: "center",
                  }}>
                    <window.Icon name="check" size={12} color="#FFF" strokeWidth={2.4}/>
                  </div>
                )}
              </div>
            ))}
          </div>

          <div style={{ fontSize: 11, fontFamily: "'JetBrains Mono', monospace", color: dark ? "#7E7770" : "#8A8278", marginTop: 16, marginBottom: 8, letterSpacing: 0.4 }}>
            2026.05.01 — 5.3 · 지난 주
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 6 }}>
            {photos.slice(4, 12).map((p, i) => (
              <div key={i} style={{ aspectRatio: "1/1", borderRadius: 10, overflow: "hidden" }}>
                <window.Photo id={p} showLabel={false}/>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────
// 7. LANGUAGE SHEET
// ─────────────────────────────────────────────────────────────────
window.Screen_Language = function Screen_Language({ dark }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  const langs = [
    { k: "sys", label: "시스템 기본", sub: "System default", code: "AUTO" },
    { k: "ko", label: "한국어", sub: "Korean", code: "KO" },
    { k: "en", label: "English", sub: "영어", code: "EN" },
    { k: "ja", label: "日本語", sub: "일본어", code: "JA" },
    { k: "zh", label: "中文", sub: "중국어", code: "ZH" },
  ];
  return (
    <div style={{ width: "100%", height: "100%", background: c["bg.canvas"], position: "relative", overflow: "hidden" }}>
      {/* Faint settings page beneath */}
      <window.StatusBar tone={dark ? "light" : "dark"}/>
      <div style={{ padding: "8px 22px 14px", opacity: 0.32 }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: c["text.muted"], letterSpacing: 1.2, textTransform: "uppercase" }}>SETTINGS</div>
        <div style={{ fontSize: 28, fontWeight: 700, color: c["text.primary"], letterSpacing: -0.6, marginTop: 4 }}>설정</div>
      </div>
      <div style={{ position: "absolute", inset: 0, background: "rgba(26,24,22,0.42)" }}/>

      {/* Sheet */}
      <div style={{
        position: "absolute", bottom: 0, left: 0, right: 0,
        background: dark ? "rgba(22,20,15,0.94)" : "rgba(250,248,245,0.94)",
        backdropFilter: "blur(28px) saturate(160%)",
        WebkitBackdropFilter: "blur(28px) saturate(160%)",
        borderRadius: "28px 28px 0 0",
        border: dark ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(255,255,255,0.55)",
        borderBottom: "none",
        padding: "10px 0 28px",
        color: c["text.primary"],
      }}>
        <div style={{ width: 40, height: 4, borderRadius: 999, background: dark ? "rgba(255,255,255,0.18)" : "rgba(26,24,22,0.18)", margin: "0 auto 8px" }}/>
        <div style={{ padding: "10px 22px 16px" }}>
          <div style={{ fontSize: 11, fontWeight: 600, letterSpacing: 1.2, textTransform: "uppercase", color: c["text.muted"] }}>LANGUAGE</div>
          <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4, marginTop: 4 }}>언어 선택</div>
        </div>
        <div style={{ padding: "0 14px" }}>
          {langs.map((l, i) => {
            const active = l.k === "ko";
            return (
              <button key={l.k} style={{
                width: "100%", padding: "14px 16px",
                borderRadius: 16, border: "none", marginBottom: 2,
                background: active ? c["accent.brandFill"] : "transparent",
                display: "flex", alignItems: "center", justifyContent: "space-between",
                cursor: "pointer", fontFamily: "inherit",
                color: c["text.primary"],
              }}>
                <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
                  <div style={{
                    width: 32, height: 32, borderRadius: 8,
                    background: active ? c["accent.brand"] : c["bg.muted"],
                    display: "flex", alignItems: "center", justifyContent: "center",
                    fontSize: 10, fontWeight: 700, color: active ? "#FFF" : c["text.secondary"],
                    fontFamily: "'JetBrains Mono', monospace", letterSpacing: 0.4,
                  }}>{l.code}</div>
                  <div style={{ textAlign: "left" }}>
                    <div style={{ fontSize: 15, fontWeight: 600, letterSpacing: -0.2 }}>{l.label}</div>
                    <div style={{ fontSize: 12, fontWeight: 500, color: c["text.muted"], marginTop: 2 }}>{l.sub}</div>
                  </div>
                </div>
                {active && (
                  <div style={{ width: 22, height: 22, borderRadius: 999, background: c["accent.brand"], display: "flex", alignItems: "center", justifyContent: "center" }}>
                    <window.Icon name="check" size={13} color="#FFF" strokeWidth={2.4}/>
                  </div>
                )}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────
// Tutorial overlay (auxiliary component for split mode)
// ─────────────────────────────────────────────────────────────────
function TutorialOverlay({ title, body, step }) {
  return (
    <div style={{ position: "absolute", inset: 0, background: "rgba(10,9,8,0.62)", backdropFilter: "blur(2px)", zIndex: 20, display: "flex", alignItems: "flex-end", padding: "0 16px 40px" }}>
      <window.Glass dark style={{ width: "100%", borderRadius: 24, padding: 24, color: "#FAF8F5" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
          <div style={{ fontSize: 11, fontFamily: "'JetBrains Mono', monospace", letterSpacing: 0.6, opacity: 0.6 }}>STEP {step} / 3</div>
          <button style={{ background: "transparent", border: "none", color: "#FAF8F5", opacity: 0.6, fontSize: 12, fontWeight: 600, cursor: "pointer", fontFamily: "inherit" }}>건너뛰기</button>
        </div>
        <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4 }}>{title}</div>
        <div style={{ fontSize: 14, fontWeight: 500, opacity: 0.78, marginTop: 8, lineHeight: 1.55 }}>{body}</div>
        <div style={{ marginTop: 20, display: "flex", gap: 8 }}>
          {[1, 2, 3].map(i => (
            <div key={i} style={{ flex: 1, height: 3, borderRadius: 999, background: i <= step ? "#FAF8F5" : "rgba(255,255,255,0.18)" }}/>
          ))}
        </div>
        <div style={{ marginTop: 18, display: "flex", justifyContent: "flex-end" }}>
          <button style={{
            padding: "10px 18px", borderRadius: 999, background: "#FAF8F5",
            color: "#1A1816", border: "none", fontSize: 13, fontWeight: 600, cursor: "pointer", fontFamily: "inherit",
          }}>다음 →</button>
        </div>
      </window.Glass>
    </div>
  );
}

// Toast demo (used on home screen as auxiliary)
window.Screen_Toast = function Screen_Toast({ dark }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <div style={{ width: "100%", height: "100%", background: c["bg.canvas"], position: "relative", overflow: "hidden" }}>
      <window.StatusBar tone={dark ? "light" : "dark"}/>
      <div style={{ padding: "8px 22px 14px", opacity: 0.4 }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: c["text.muted"], letterSpacing: 1.2, textTransform: "uppercase" }}>FIT—LOG</div>
        <div style={{ fontSize: 28, fontWeight: 700, color: c["text.primary"], letterSpacing: -0.6, marginTop: 4 }}>라이브러리</div>
      </div>
      {/* faint grid */}
      <div style={{ padding: "0 22px", opacity: 0.4 }}>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 8 }}>
          {[0,1,2,3,4,5].map(i => <div key={i} style={{ aspectRatio: "1/1", borderRadius: 12, overflow: "hidden" }}><window.Photo id={i} showLabel={false}/></div>)}
        </div>
      </div>
      {/* Toast at top */}
      <div style={{ position: "absolute", top: 60, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
        <window.FLToast dark={dark} icon="check">사진이 저장되었어요 · 갤러리에도 추가됨</window.FLToast>
      </div>
      {/* Confirm dialog example */}
      <div style={{ position: "absolute", inset: 0, background: "rgba(26,24,22,0.42)", display: "flex", alignItems: "center", justifyContent: "center", padding: 24 }}>
        <div style={{
          width: "100%", maxWidth: 320,
          background: dark ? "rgba(32,29,23,0.98)" : "rgba(255,255,255,0.98)",
          backdropFilter: "blur(24px) saturate(160%)",
          WebkitBackdropFilter: "blur(24px) saturate(160%)",
          borderRadius: 24, padding: 24,
          border: dark ? "1px solid rgba(255,255,255,0.06)" : "1px solid rgba(26,24,22,0.06)",
          color: c["text.primary"],
          boxShadow: dark ? "0 24px 60px rgba(0,0,0,0.55)" : "0 24px 60px rgba(26,24,22,0.18)",
        }}>
          <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: -0.3 }}>사진을 삭제할까요?</div>
          <div style={{ fontSize: 13, fontWeight: 500, color: c["text.secondary"], marginTop: 8, lineHeight: 1.5 }}>
            선택한 2장의 OOTD 사진이 라이브러리와 시스템 갤러리에서 모두 삭제됩니다. 되돌릴 수 없어요.
          </div>
          <div style={{ display: "flex", gap: 8, marginTop: 22 }}>
            <window.FLButton dark={dark} kind="ghost" fullWidth>취소</window.FLButton>
            <window.FLButton dark={dark} kind="primary" fullWidth style={{ background: c["danger"] }}>삭제</window.FLButton>
          </div>
        </div>
      </div>
    </div>
  );
};

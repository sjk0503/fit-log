// Fit-Log screens — Home (Library), Photo Viewer, Layout Composer, Permissions
const { useState: uS1, useEffect: uE1, useMemo: uM1 } = React;

// ─────────────────────────────────────────────────────────────────
// 1. HOME / LIBRARY
//   states: empty | filled | selecting
// ─────────────────────────────────────────────────────────────────
window.Screen_Home = function Screen_Home({ dark, state = "filled", density = "comfy" }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  const t = window.FL_TOKENS.type;
  // photos by date (filled state)
  const groups = [
    { date: "오늘", sub: "2026.05.05 화", ids: [0, 1, 2] },
    { date: "어제", sub: "2026.05.04 월", ids: [3, 4, 5] },
    { date: "지난 주", sub: "5.1 — 5.3", ids: [6, 7, 8, 9] },
    { date: "4월", sub: "9장", ids: [10, 11, 0, 5, 8, 1, 3, 9, 7] },
  ];
  const gap = density === "tight" ? 4 : 8;
  const r = density === "tight" ? 4 : 12;

  const [selected, setSelected] = uS1(new Set([0, 4]));
  const isSelecting = state === "selecting";

  return (
    <div style={{ width: "100%", height: "100%", background: c["bg.canvas"], display: "flex", flexDirection: "column" }}>
      <window.StatusBar tone={dark ? "light" : "dark"}/>

      {/* Header */}
      <div style={{ padding: "8px 22px 14px", display: "flex", alignItems: "flex-end", justifyContent: "space-between", gap: 12 }}>
        <div style={{ minWidth: 0, flex: 1 }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: c["text.muted"], letterSpacing: 1.2, textTransform: "uppercase", whiteSpace: "nowrap" }}>
            FIT—LOG
          </div>
          <div style={{ fontSize: 28, fontWeight: 700, color: c["text.primary"], letterSpacing: -0.6, marginTop: 4, whiteSpace: "nowrap" }}>
            {isSelecting ? `${selected.size}장 선택됨` : "라이브러리"}
          </div>
        </div>
        {!isSelecting && (
          <div style={{ display: "flex", gap: 6, flexShrink: 0 }}>
            <IconBtn dark={dark} icon="globe"/>
            <IconBtn dark={dark} icon="settings"/>
          </div>
        )}
        {isSelecting && (
          <button onClick={() => {}} style={{
            padding: "8px 14px", borderRadius: 999, background: "transparent",
            border: `1px solid ${c["border.default"]}`,
            color: c["text.primary"], fontSize: 13, fontWeight: 600, cursor: "pointer", fontFamily: "inherit",
          }}>취소</button>
        )}
      </div>

      {/* Stat strip */}
      {!isSelecting && state !== "empty" && (
        <div style={{ padding: "0 22px 8px", display: "flex", gap: 8 }}>
          <StatPill dark={dark} value="48" label="총 OOTD"/>
          <StatPill dark={dark} value="12" label="이번 달"/>
          <StatPill dark={dark} value="4" label="연속 일자"/>
        </div>
      )}

      {/* Content */}
      <div style={{ flex: 1, overflow: "hidden", padding: "8px 22px 0" }}>
        {state === "empty" && <EmptyState dark={dark}/>}
        {state !== "empty" && (
          <div style={{ display: "flex", flexDirection: "column", gap: 18 }}>
            {groups.slice(0, isSelecting ? 2 : 4).map((g, gi) => (
              <div key={gi}>
                <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", marginBottom: 10, gap: 12 }}>
                  <div style={{ fontSize: 16, fontWeight: 600, color: c["text.primary"], letterSpacing: -0.2, whiteSpace: "nowrap", flexShrink: 0 }}>
                    {g.date}
                  </div>
                  <div style={{ fontSize: 11, fontWeight: 500, color: c["text.muted"], fontFamily: "'JetBrains Mono', monospace", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", minWidth: 0 }}>
                    {g.sub}
                  </div>
                </div>
                <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap }}>
                  {g.ids.map((pid, pi) => {
                    const idx = gi * 100 + pi;
                    const sel = selected.has(idx);
                    return (
                      <div key={pi} style={{ aspectRatio: "1 / 1", borderRadius: r, overflow: "hidden", position: "relative", cursor: "pointer" }}
                        onClick={() => {
                          if (!isSelecting) return;
                          const s = new Set(selected); s.has(idx) ? s.delete(idx) : s.add(idx); setSelected(s);
                        }}>
                        <window.Photo id={pid} mode="tile" showLabel={false}/>
                        {isSelecting && (
                          <div style={{ position: "absolute", inset: 0, background: sel ? "rgba(194,97,74,0.22)" : "rgba(0,0,0,0.05)" }}>
                            <div style={{
                              position: "absolute", top: 8, right: 8,
                              width: 24, height: 24, borderRadius: 999,
                              background: sel ? c["accent.brand"] : "rgba(255,255,255,0.55)",
                              border: sel ? "none" : `1.5px solid rgba(255,255,255,0.9)`,
                              backdropFilter: "blur(8px)",
                              display: "flex", alignItems: "center", justifyContent: "center",
                            }}>
                              {sel && <window.Icon name="check" size={14} color="#FFF" strokeWidth={2.4}/>}
                            </div>
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Floating shoot button (filled) or selection actions (selecting) */}
      {!isSelecting && state !== "empty" && (
        <div style={{ position: "absolute", left: 0, right: 0, bottom: 22, display: "flex", justifyContent: "center" }}>
          <window.Glass dark={dark} style={{ borderRadius: 999, padding: 6, display: "flex", alignItems: "center", gap: 4, boxShadow: dark ? "0 18px 40px -8px rgba(0,0,0,0.55)" : "0 18px 40px -8px rgba(26,24,22,0.16)" }}>
            <ShootBtn dark={dark}/>
            <button style={{
              padding: "12px 16px", borderRadius: 999, background: "transparent", border: "none",
              fontSize: 13, fontWeight: 600, color: c["text.secondary"], cursor: "pointer", fontFamily: "inherit",
              display: "inline-flex", alignItems: "center", gap: 6,
            }}>
              <window.Icon name="layers" size={16} color={c["text.secondary"]}/> 합성
            </button>
            <button style={{
              padding: "12px 16px", borderRadius: 999, background: "transparent", border: "none",
              fontSize: 13, fontWeight: 600, color: c["text.secondary"], cursor: "pointer", fontFamily: "inherit",
            }}>선택</button>
          </window.Glass>
        </div>
      )}

      {isSelecting && (
        <div style={{ position: "absolute", left: 16, right: 16, bottom: 22, display: "flex", gap: 8 }}>
          <window.FLButton dark={dark} kind="secondary" icon={<window.Icon name="trash" size={16}/>} fullWidth>삭제</window.FLButton>
          <window.FLButton dark={dark} kind="primary" icon={<window.Icon name="layers" size={16} color="#FFF"/>} fullWidth>레이아웃 합성</window.FLButton>
        </div>
      )}
    </div>
  );
};

function IconBtn({ dark, icon, onClick }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <button onClick={onClick} style={{
      width: 40, height: 40, borderRadius: 999,
      background: c["bg.muted"], border: `1px solid ${c["border.subtle"]}`,
      display: "flex", alignItems: "center", justifyContent: "center",
      cursor: "pointer",
    }}>
      <window.Icon name={icon} size={18} color={c["text.primary"]}/>
    </button>
  );
}

function StatPill({ dark, value, label }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <div style={{
      flex: 1, minWidth: 0, padding: "10px 14px",
      background: c["bg.elevated"],
      border: `1px solid ${c["border.subtle"]}`,
      borderRadius: 14,
      display: "flex", flexDirection: "column", gap: 2,
    }}>
      <div style={{ fontSize: 20, fontWeight: 700, color: c["text.primary"], letterSpacing: -0.4, fontFamily: "'JetBrains Mono', monospace", lineHeight: 1.1 }}>{value}</div>
      <div style={{ fontSize: 11, fontWeight: 500, color: c["text.muted"], whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{label}</div>
    </div>
  );
}

function ShootBtn({ dark }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <button style={{
      height: 48, padding: "0 22px 0 16px",
      borderRadius: 999, background: c["accent.brand"], color: "#FFF",
      border: "none", display: "inline-flex", alignItems: "center", gap: 8,
      fontSize: 14, fontWeight: 600, cursor: "pointer", fontFamily: "inherit",
    }}>
      <window.Icon name="camera" size={18} color="#FFF"/>
      오늘 OOTD 찍기
    </button>
  );
}

function EmptyState({ dark }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", textAlign: "center", padding: "0 32px", height: 600 }}>
      <div style={{
        width: 128, height: 128, borderRadius: 28,
        background: c["bg.elevated"],
        border: `1px solid ${c["border.subtle"]}`,
        display: "grid", gridTemplateColumns: "1fr 1fr", gap: 4, padding: 4,
        marginBottom: 24,
        boxShadow: dark ? "0 18px 40px -8px rgba(0,0,0,0.5)" : "0 18px 40px -8px rgba(26,24,22,0.10)",
      }}>
        {[0, 1, 2, 3].map(i => (
          <div key={i} style={{ borderRadius: 10, background: c["bg.muted"], opacity: 0.5 + i * 0.15 }}/>
        ))}
      </div>
      <div style={{ fontSize: 22, fontWeight: 700, color: c["text.primary"], letterSpacing: -0.4 }}>
        첫 OOTD를 남겨보세요
      </div>
      <div style={{ fontSize: 14, fontWeight: 500, color: c["text.secondary"], marginTop: 10, lineHeight: 1.5, maxWidth: 260 }}>
        매일 같은 포즈로 기록하면<br/>옷차림의 변화가 한눈에 보여요
      </div>
      <div style={{ marginTop: 28 }}>
        <window.FLButton dark={dark} kind="primary" size="lg" icon={<window.Icon name="camera" size={18} color="#FFF"/>}>
          첫 사진 찍기
        </window.FLButton>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// 5. PHOTO VIEWER (full-screen)
// ─────────────────────────────────────────────────────────────────
window.Screen_Viewer = function Screen_Viewer({ dark, photoId = 4 }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  return (
    <div style={{ width: "100%", height: "100%", background: "#0A0908", position: "relative", display: "flex", flexDirection: "column" }}>
      <window.StatusBar tone="light"/>
      {/* Top bar */}
      <div style={{ position: "absolute", top: 44, left: 0, right: 0, padding: "12px 16px", display: "flex", alignItems: "center", justifyContent: "space-between", zIndex: 5 }}>
        <CircleGlass><window.Icon name="back" size={20} color="#FAF8F5"/></CircleGlass>
        <window.Glass dark style={{ padding: "8px 16px", borderRadius: 999, color: "#FAF8F5" }}>
          <div style={{ fontSize: 13, fontWeight: 600, letterSpacing: -0.2 }}>2026.05.04 월</div>
        </window.Glass>
        <CircleGlass><window.Icon name="more" size={20} color="#FAF8F5"/></CircleGlass>
      </div>

      {/* Photo */}
      <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", padding: "0 0 100px" }}>
        <div style={{ width: 360, aspectRatio: "3 / 4", borderRadius: 4, overflow: "hidden" }}>
          <window.Photo id={photoId} showLabel={false}/>
        </div>
      </div>

      {/* Metadata strip */}
      <div style={{ position: "absolute", bottom: 110, left: 16, right: 16 }}>
        <window.Glass dark style={{ borderRadius: 16, padding: "12px 16px", display: "flex", justifyContent: "space-around", color: "#FAF8F5" }}>
          <Meta label="시간" value="09:42"/>
          <MetaDivider/>
          <Meta label="모드" value="분할"/>
          <MetaDivider/>
          <Meta label="해상도" value="3024×4032"/>
        </window.Glass>
      </div>

      {/* Bottom actions */}
      <div style={{ position: "absolute", bottom: 22, left: 16, right: 16, display: "flex", gap: 8 }}>
        <button style={glassActionStyle()}>
          <window.Icon name="trash" size={18} color="#FAF8F5"/>
          <span>삭제</span>
        </button>
        <button style={{ ...glassActionStyle(), background: "#C2614A", border: "1px solid transparent" }}>
          <window.Icon name="redo" size={18} color="#FFF"/>
          <span>이 포즈로 다시 찍기</span>
        </button>
      </div>
    </div>
  );
};

function CircleGlass({ children }) {
  return (
    <div style={{
      width: 40, height: 40, borderRadius: 999,
      background: "rgba(20,18,16,0.55)",
      backdropFilter: "blur(14px) saturate(150%)",
      WebkitBackdropFilter: "blur(14px) saturate(150%)",
      border: "1px solid rgba(255,255,255,0.10)",
      display: "flex", alignItems: "center", justifyContent: "center",
    }}>{children}</div>
  );
}
function Meta({ label, value }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 2, alignItems: "center" }}>
      <div style={{ fontSize: 10, fontWeight: 600, letterSpacing: 0.6, opacity: 0.6, textTransform: "uppercase" }}>{label}</div>
      <div style={{ fontSize: 13, fontWeight: 600, fontFamily: "'JetBrains Mono', monospace" }}>{value}</div>
    </div>
  );
}
function MetaDivider() {
  return <div style={{ width: 1, background: "rgba(255,255,255,0.12)" }}/>;
}
function glassActionStyle() {
  return {
    flex: 1, height: 52, borderRadius: 999,
    background: "rgba(20,18,16,0.55)",
    backdropFilter: "blur(14px) saturate(150%)",
    WebkitBackdropFilter: "blur(14px) saturate(150%)",
    border: "1px solid rgba(255,255,255,0.10)",
    color: "#FAF8F5", fontSize: 14, fontWeight: 600,
    display: "inline-flex", alignItems: "center", justifyContent: "center", gap: 8,
    cursor: "pointer", fontFamily: "inherit",
  };
}

// ─────────────────────────────────────────────────────────────────
// 6. LAYOUT COMPOSER
// ─────────────────────────────────────────────────────────────────
window.Screen_Layout = function Screen_Layout({ dark, layout = "2x2" }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  const layouts = ["2x2", "3x3", "3x2", "4x2"];
  const [sel, setSel] = uS1(layout);
  const [r, cn] = sel.split("x").map(Number);
  const cells = r * cn;
  const photos = [0, 4, 7, 2, 9, 5, 1, 8, 3];

  return (
    <div style={{ width: "100%", height: "100%", background: c["bg.canvas"], display: "flex", flexDirection: "column" }}>
      <window.StatusBar tone={dark ? "light" : "dark"}/>

      {/* Header */}
      <div style={{ padding: "8px 22px 18px", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <button style={{
          width: 40, height: 40, borderRadius: 999, background: "transparent",
          border: `1px solid ${c["border.default"]}`,
          display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer",
        }}>
          <window.Icon name="close" size={18} color={c["text.primary"]}/>
        </button>
        <div style={{ fontSize: 16, fontWeight: 600, color: c["text.primary"], letterSpacing: -0.2 }}>레이아웃 합성</div>
        <button style={{
          padding: "8px 16px", borderRadius: 999, background: c["accent.brand"], border: "none",
          color: "#FFF", fontSize: 13, fontWeight: 600, cursor: "pointer", fontFamily: "inherit",
        }}>저장</button>
      </div>

      {/* Preview */}
      <div style={{ flex: 1, padding: "0 22px", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div style={{
          width: cn >= r ? 320 : 260,
          aspectRatio: `${cn} / ${r}`,
          background: dark ? "#0F0E0D" : "#FAF8F5",
          padding: 8, borderRadius: 6,
          boxShadow: dark ? "0 18px 40px -10px rgba(0,0,0,0.55)" : "0 18px 40px -10px rgba(26,24,22,0.18)",
          display: "grid",
          gridTemplateColumns: `repeat(${cn}, 1fr)`,
          gridTemplateRows: `repeat(${r}, 1fr)`,
          gap: 4,
        }}>
          {Array.from({ length: cells }).map((_, i) => (
            <div key={i} style={{ overflow: "hidden", borderRadius: 2 }}>
              {photos[i] != null ? <window.Photo id={photos[i]} showLabel={false}/> : (
                <div style={{ width: "100%", height: "100%", background: c["bg.muted"] }}/>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Layout chooser */}
      <div style={{ padding: "20px 22px 12px" }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: c["text.muted"], letterSpacing: 1.2, textTransform: "uppercase", marginBottom: 10 }}>레이아웃</div>
        <div style={{ display: "flex", gap: 8 }}>
          {layouts.map(L => {
            const active = sel === L;
            const [lr, lc] = L.split("x").map(Number);
            return (
              <button key={L} onClick={() => setSel(L)} style={{
                flex: 1, padding: "10px 6px",
                borderRadius: 14,
                background: active ? c["accent.brandFill"] : c["bg.elevated"],
                border: `1px solid ${active ? c["accent.brand"] : c["border.subtle"]}`,
                color: c["text.primary"], cursor: "pointer", fontFamily: "inherit",
                display: "flex", flexDirection: "column", alignItems: "center", gap: 6,
              }}>
                {/* mini grid icon */}
                <div style={{
                  width: 28, height: 28 * (lr / lc) * (lc / lr),
                  display: "grid",
                  gridTemplateColumns: `repeat(${lc}, 1fr)`,
                  gridTemplateRows: `repeat(${lr}, 1fr)`,
                  gap: 1.5,
                }}>
                  {Array.from({ length: lr * lc }).map((_, i) => (
                    <div key={i} style={{ background: active ? c["accent.brand"] : c["text.muted"], borderRadius: 1, opacity: active ? 1 : 0.55 }}/>
                  ))}
                </div>
                <span style={{ fontSize: 12, fontWeight: 600 }}>{L}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Counter */}
      <div style={{ padding: "8px 22px 22px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <div style={{ fontSize: 13, fontWeight: 500, color: c["text.secondary"] }}>
          선택된 사진 <span style={{ fontFamily: "'JetBrains Mono', monospace", color: c["text.primary"], fontWeight: 700 }}>{Math.min(photos.length, cells)}</span> / {cells}
        </div>
        <button style={{
          padding: "8px 14px", borderRadius: 999,
          background: "transparent", border: `1px solid ${c["border.default"]}`,
          color: c["text.primary"], fontSize: 13, fontWeight: 600, cursor: "pointer", fontFamily: "inherit",
        }}>사진 변경</button>
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────────
// 8. PERMISSION DENIED
// ─────────────────────────────────────────────────────────────────
window.Screen_Permission = function Screen_Permission({ dark, kind = "camera" }) {
  const c = window.FL_TOKENS[dark ? "dark" : "light"];
  const isCam = kind === "camera";
  return (
    <div style={{ width: "100%", height: "100%", background: c["bg.canvas"], display: "flex", flexDirection: "column" }}>
      <window.StatusBar tone={dark ? "light" : "dark"}/>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 36px", textAlign: "center" }}>
        <div style={{
          width: 96, height: 96, borderRadius: 28,
          background: c["bg.elevated"],
          border: `1px solid ${c["border.subtle"]}`,
          display: "flex", alignItems: "center", justifyContent: "center",
          boxShadow: dark ? "0 18px 40px -8px rgba(0,0,0,0.5)" : "0 18px 40px -8px rgba(26,24,22,0.10)",
          position: "relative",
        }}>
          <window.Icon name={isCam ? "camera" : "image"} size={36} color={c["text.primary"]}/>
          <div style={{
            position: "absolute", bottom: -6, right: -6,
            width: 32, height: 32, borderRadius: 999,
            background: c["bg.canvas"],
            display: "flex", alignItems: "center", justifyContent: "center",
            border: `2px solid ${c["bg.canvas"]}`,
          }}>
            <div style={{ width: 28, height: 28, borderRadius: 999, background: c["danger"], display: "flex", alignItems: "center", justifyContent: "center" }}>
              <window.Icon name="lock" size={14} color="#FFF" strokeWidth={2.2}/>
            </div>
          </div>
        </div>
        <div style={{ fontSize: 22, fontWeight: 700, color: c["text.primary"], letterSpacing: -0.4, marginTop: 32 }}>
          {isCam ? "카메라 권한이 필요해요" : "사진 접근 권한이 필요해요"}
        </div>
        <div style={{ fontSize: 14, fontWeight: 500, color: c["text.secondary"], marginTop: 10, lineHeight: 1.55, maxWidth: 280 }}>
          {isCam
            ? "OOTD 사진을 촬영하려면 카메라 접근을 허용해 주세요. 설정에서 언제든 변경할 수 있어요."
            : "이전 사진을 불러오려면 사진 라이브러리 접근을 허용해 주세요. 사진은 기기 안에서만 사용돼요."}
        </div>
        <div style={{ marginTop: 32, width: "100%" }}>
          <window.FLButton dark={dark} kind="primary" size="lg" fullWidth>설정 열기</window.FLButton>
          <div style={{ height: 8 }}/>
          <window.FLButton dark={dark} kind="ghost" size="md" fullWidth>나중에 하기</window.FLButton>
        </div>
      </div>
    </div>
  );
};

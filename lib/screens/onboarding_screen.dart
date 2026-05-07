import 'package:flutter/widgets.dart';

import '../design/design.dart';
import '../services/tutorial_service.dart';
import '../utils/permissions.dart';

/// Three-step walkthrough shown on first launch.
///
/// Step 1 — what fit-log does (the daily-pose idea)
/// Step 2 — the two camera modes (split vs overlay)
/// Step 3 — gentle camera/photo permission request
///
/// On finish, sets the onboarding flag and pops with `true` so the caller can
/// route into the home or camera screen.
class OnboardingScreen extends StatefulWidget {
  /// If set, called when the user finishes (or skips) onboarding instead of
  /// popping the route. Lets the bootstrap router swap to home without a
  /// transition flash.
  final VoidCallback? onDone;

  const OnboardingScreen({super.key, this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  final TutorialService _tutorial = TutorialService();
  int _index = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 2) {
      _pc.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await _tutorial.completeOnboarding();
    if (!mounted) return;
    if (widget.onDone != null) {
      widget.onDone!();
    } else {
      Navigator.of(context).maybePop(true);
    }
  }

  Future<void> _requestPermissionsAndFinish() async {
    await PermissionUtils.requestCameraPermission();
    await PermissionUtils.requestStoragePermission();
    if (!mounted) return;
    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    final mq = MediaQuery.of(context);
    return ColoredBox(
      color: t.c.bgCanvas,
      child: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 12,
              right: 22,
              child: GestureDetector(
                onTap: _finish,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Text(
                    '건너뛰기',
                    style: FLType.bodySm.copyWith(color: t.c.textMuted),
                  ),
                ),
              ),
            ),
            // Pages
            PageView(
              controller: _pc,
              onPageChanged: (i) => setState(() => _index = i),
              children: const [
                _OnboardingPage1(),
                _OnboardingPage2(),
                _OnboardingPage3(),
              ],
            ),
            // Bottom — page dots + CTA
            Positioned(
              left: 0,
              right: 0,
              bottom: mq.padding.bottom + 24,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? t.c.accentBrand
                                : t.c.borderStrong,
                            borderRadius:
                                BorderRadius.circular(FLRadii.full),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    if (_index < 2)
                      FLButton(
                        label: '다음',
                        size: FLButtonSize.lg,
                        fullWidth: true,
                        onPressed: _next,
                      )
                    else
                      FLButton(
                        label: '카메라 권한 허용하고 시작',
                        size: FLButtonSize.lg,
                        fullWidth: true,
                        leadingIcon: FLIcon.camera,
                        onPressed: _requestPermissionsAndFinish,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page bodies ────────────────────────────────────────────────────────

class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 56, 28, 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow('FIT—LOG'),
          const SizedBox(height: 12),
          Text(
            '같은 포즈로,\n매일 한 컷.',
            style: FLType.displayLg.copyWith(
              color: t.c.textPrimary,
              letterSpacing: -0.7,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '오늘 옷차림을 어제와 같은 자리에서 같은 포즈로 남기면 며칠만 지나도 변화가 한눈에 보여요. 카메라 앱이 그 비교를 도와줍니다.',
            style: FLType.bodyLg.copyWith(
              color: t.c.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: t.c.bgElevated,
              border: Border.all(color: t.c.borderSubtle, width: 1),
              borderRadius: BorderRadius.circular(FLRadii.xl),
              boxShadow:
                  t.isDark ? FLShadows.darkLg : FLShadows.lightLg,
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: _SilhouettePanel(label: '어제', dim: true)),
                const SizedBox(width: 4),
                Expanded(child: _SilhouettePanel(label: '오늘', dim: false)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 56, 28, 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow('TWO MODES'),
          const SizedBox(height: 12),
          Text(
            '분할 또는\n오버레이.',
            style: FLType.displayLg.copyWith(
              color: t.c.textPrimary,
              letterSpacing: -0.7,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '두 가지 방법으로 같은 포즈를 잡을 수 있어요. 마음에 드는 쪽으로 선택하면 됩니다.',
            style: FLType.bodyLg.copyWith(
              color: t.c.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _ModeCard(
            icon: FLIcon.split,
            title: '분할 모드',
            body: '화면을 50:50으로 나눠 한쪽엔 어제 사진, 한쪽엔 카메라. 분할선에 어깨를 맞춰요.',
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: FLIcon.overlay,
            title: '오버레이 모드',
            body: '어제 사진을 카메라 위에 반투명으로 겹쳐 봅니다. 투명도는 슬라이더로 조절.',
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 56, 28, 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow('PRIVACY FIRST'),
          const SizedBox(height: 12),
          Text(
            '사진은 기기\n안에만 둡니다.',
            style: FLType.displayLg.copyWith(
              color: t.c.textPrimary,
              letterSpacing: -0.7,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '촬영한 OOTD는 앱 안과 휴대전화 갤러리에만 저장돼요. 외부 서버로 보내지 않고 광고 추적도 하지 않아요.\n\n시작하려면 카메라와 사진 권한이 필요합니다.',
            style: FLType.bodyLg.copyWith(
              color: t.c.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          _PrivacyBullet(
            icon: FLIcon.camera,
            title: '카메라',
            body: 'OOTD 사진을 촬영합니다.',
          ),
          const SizedBox(height: 8),
          _PrivacyBullet(
            icon: FLIcon.image,
            title: '사진 라이브러리',
            body: '레퍼런스로 쓸 사진을 불러오고 저장합니다.',
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow(this.text);

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Text(
      text,
      style: TextStyle(
        fontFamily: FLFonts.sans,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: t.c.textMuted,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final FLIcon icon;
  final String title;
  final String body;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.c.bgElevated,
        border: Border.all(color: t.c.borderSubtle, width: 1),
        borderRadius: BorderRadius.circular(FLRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.c.accentBrandFill,
              borderRadius: BorderRadius.circular(FLRadii.md),
            ),
            child: FLIconView(icon, size: 20, color: t.c.accentBrand),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FLType.titleSm.copyWith(
                    color: t.c.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: FLType.bodySm.copyWith(
                    color: t.c.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyBullet extends StatelessWidget {
  final FLIcon icon;
  final String title;
  final String body;

  const _PrivacyBullet({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: t.c.bgMuted,
            borderRadius: BorderRadius.circular(FLRadii.sm),
          ),
          child: FLIconView(icon, size: 14, color: t.c.textPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: FLType.bodySm.copyWith(
                  color: t.c.textSecondary, height: 1.5),
              children: [
                TextSpan(
                  text: '$title  ',
                  style: TextStyle(
                    color: t.c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: body),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SilhouettePanel extends StatelessWidget {
  final String label;
  final bool dim;
  const _SilhouettePanel({required this.label, required this.dim});

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.c.bgMuted,
        borderRadius: BorderRadius.circular(FLRadii.md),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: dim ? 0.55 : 1.0,
              child: CustomPaint(
                painter: _SilhouettePainter(
                  color: t.c.textMuted.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: t.c.bgElevated.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(FLRadii.full),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: FLFonts.mono,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: t.c.textPrimary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  final Color color;
  _SilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(cx, size.height * 0.32), size.width * 0.16, paint);
    final body = Path()
      ..moveTo(cx - size.width * 0.28, size.height)
      ..quadraticBezierTo(
        cx - size.width * 0.32,
        size.height * 0.55,
        cx,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        cx + size.width * 0.32,
        size.height * 0.55,
        cx + size.width * 0.28,
        size.height,
      )
      ..close();
    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

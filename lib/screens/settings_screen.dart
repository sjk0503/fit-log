import 'package:flutter/material.dart' show Navigator, MaterialPageRoute;
import 'package:flutter/widgets.dart';

import '../design/design.dart';
import '../services/locale_service.dart';
import '../services/tutorial_service.dart';
import 'about_screen.dart';
import 'help_screen.dart';
import 'onboarding_screen.dart';
import 'privacy_screen.dart';
import 'terms_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TutorialService _tutorial = TutorialService();

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _openLanguage() {
    showFLSheet<void>(
      context,
      heightFraction: 0.55,
      builder: (ctx) => const _LanguageSheetBody(),
    );
  }

  Future<void> _restartOnboarding() async {
    await _tutorial.resetAll();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return ColoredBox(
      color: t.c.bgCanvas,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  FLIconBtn(
                    icon: FLIcon.back,
                    tone: FLIconBtnTone.outline,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SETTINGS',
                    style: FLType.label
                        .copyWith(color: t.c.textMuted, letterSpacing: 1.32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '설정',
                    style: FLType.displayMd.copyWith(
                      color: t.c.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
                children: [
                  _SectionLabel('일반'),
                  _SettingTile(
                    icon: FLIcon.globe,
                    title: '언어',
                    trailing: _LocaleHint(),
                    onTap: _openLanguage,
                  ),
                  // Reserved spot for future ad-banner placeholder is intentionally
                  // left out here — the slot is on the library tab so settings
                  // stays clean.
                  const SizedBox(height: 20),

                  _SectionLabel('도움'),
                  _SettingTile(
                    icon: FLIcon.spark,
                    title: '온보딩 다시 보기',
                    onTap: _restartOnboarding,
                  ),
                  _SettingTile(
                    icon: FLIcon.image,
                    title: '도움말',
                    onTap: () => _push(const HelpScreen()),
                  ),
                  const SizedBox(height: 20),

                  _SectionLabel('개인정보'),
                  _SettingTile(
                    icon: FLIcon.lock,
                    title: '개인정보 처리방침',
                    onTap: () => _push(const PrivacyScreen()),
                  ),
                  _SettingTile(
                    icon: FLIcon.check,
                    title: '이용약관',
                    onTap: () => _push(const TermsScreen()),
                  ),
                  const SizedBox(height: 20),

                  _SectionLabel('정보'),
                  _SettingTile(
                    icon: FLIcon.more,
                    title: '앱 정보',
                    onTap: () => _push(const AboutScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        text.toUpperCase(),
        style: FLType.label.copyWith(
          color: t.c.textMuted,
          letterSpacing: 1.32,
        ),
      ),
    );
  }
}

class _SettingTile extends StatefulWidget {
  final FLIcon icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  State<_SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<_SettingTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _pressed ? t.c.bgInset : t.c.bgElevated,
          border: Border.all(color: t.c.borderSubtle, width: 1),
          borderRadius: BorderRadius.circular(FLRadii.md),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.c.bgMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FLIconView(
                widget.icon,
                size: 16,
                color: t.c.textPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.title,
                style: FLType.bodyLg.copyWith(
                  color: t.c.textPrimary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            if (widget.trailing != null) ...[
              widget.trailing!,
              const SizedBox(width: 8),
            ],
            FLIconView(
              FLIcon.back,
              size: 14,
              color: t.c.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocaleHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    final l = LocaleService().locale;
    final label = l == null
        ? '시스템 기본'
        : switch (l.languageCode) {
            'ko' => '한국어',
            'en' => 'English',
            'ja' => '日本語',
            'zh' => '中文',
            _ => l.languageCode.toUpperCase(),
          };
    return Text(
      label,
      style: FLType.bodySm.copyWith(color: t.c.textMuted),
    );
  }
}

// Language picker sheet (mirrors the home screen language sheet, kept here
// so SettingsScreen owns its own dependencies).
class _LanguageSheetBody extends StatelessWidget {
  const _LanguageSheetBody();

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    final localeService = LocaleService();
    final current = localeService.locale;

    final langs = <_LangOption>[
      const _LangOption(null, '시스템 기본', 'System default', 'AUTO'),
      const _LangOption(Locale('ko'), '한국어', 'Korean', 'KO'),
      const _LangOption(Locale('en'), 'English', '영어', 'EN'),
      const _LangOption(Locale('ja'), '日本語', '일본어', 'JA'),
      const _LangOption(Locale('zh'), '中文', '중국어', 'ZH'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LANGUAGE',
                  style: FLType.label.copyWith(
                    color: t.c.textMuted,
                    letterSpacing: 1.32,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '언어 선택',
                  style: FLType.titleLg.copyWith(
                    color: t.c.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                for (final l in langs)
                  _LangRow(
                    option: l,
                    selected: l.locale?.languageCode ==
                            current?.languageCode &&
                        (l.locale == null) == (current == null),
                    onTap: () {
                      localeService.setLocale(l.locale);
                      Navigator.of(context).maybePop();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LangOption {
  final Locale? locale;
  final String label;
  final String sub;
  final String code;
  const _LangOption(this.locale, this.label, this.sub, this.code);
}

class _LangRow extends StatelessWidget {
  final _LangOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LangRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? t.c.accentBrandFill
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(FLRadii.md),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? t.c.accentBrand : t.c.bgMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                option.code,
                style: TextStyle(
                  fontFamily: FLFonts.mono,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color:
                      selected ? const Color(0xFFFFFFFF) : t.c.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: FLType.bodyLg.copyWith(
                      color: t.c.textPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.sub,
                    style: FLType.bodySm.copyWith(color: t.c.textMuted),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.c.accentBrand,
                  borderRadius: BorderRadius.circular(FLRadii.full),
                ),
                child: FLIconView(
                  FLIcon.check,
                  size: 13,
                  color: const Color(0xFFFFFFFF),
                  strokeWidth: 2.4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

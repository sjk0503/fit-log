import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Navigator, MaterialPageRoute;
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../design/design.dart';
import 'static_page_shell.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = '${info.version} (${info.buildNumber})');
    } catch (_) {
      if (!mounted) return;
      setState(() => _version = '—');
    }
  }

  void _openLicenses() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _LicensesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'ABOUT',
      title: '앱 정보',
      sections: [
        StaticSection(
          heading: 'Fit-Log',
          body: '같은 포즈로, 매일 한 컷.\n\n버전 $_version',
        ),
        const StaticSection(
          heading: '만든 사람',
          body: '개인 개발자가 만든 OOTD 카메라 앱입니다. 의견과 제보는 언제든 환영합니다.',
        ),
        const StaticSection(
          heading: '데이터 처리',
          body:
              '모든 사진과 메타데이터는 사용자의 기기 안에만 저장됩니다. 외부 서버로 전송되거나 광고 추적에 사용되지 않습니다. 자세한 내용은 개인정보 처리방침을 확인해 주세요.',
        ),
      ],
      footer: _LicensesAction(onPressed: _openLicenses),
    );
  }
}

class _LicensesAction extends StatelessWidget {
  final VoidCallback onPressed;
  const _LicensesAction({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FLButton(
        label: '오픈소스 라이선스',
        kind: FLButtonKind.secondary,
        size: FLButtonSize.md,
        fullWidth: true,
        onPressed: onPressed,
      ),
    );
  }
}

class _LicensesScreen extends StatelessWidget {
  const _LicensesScreen();

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return ColoredBox(
      color: t.c.bgCanvas,
      child: SafeArea(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '오픈소스 라이선스',
                      style: FLType.titleSm.copyWith(
                        color: t.c.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: _LicensePageList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicensePageList extends StatefulWidget {
  const _LicensePageList();

  @override
  State<_LicensePageList> createState() => _LicensePageListState();
}

class _LicensePageListState extends State<_LicensePageList> {
  late final Future<List<LicenseEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = LicenseRegistry.licenses.toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return FutureBuilder<List<LicenseEntry>>(
      future: _entries,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(
            child: Text(
              '불러오는 중…',
              style: FLType.bodySm.copyWith(color: t.c.textMuted),
            ),
          );
        }
        final entries = snap.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.packages.join(', '),
                    style: FLType.titleSm.copyWith(
                      color: t.c.textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final p in e.paragraphs)
                    Padding(
                      padding: EdgeInsets.only(
                        left: p.indent.toDouble() * 8,
                        bottom: 6,
                      ),
                      child: Text(
                        p.text,
                        style: FLType.bodySm.copyWith(
                          color: t.c.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/widgets.dart';

import '../design/design.dart';

/// One section of a static page (Privacy / Terms / Help / About).
class StaticSection {
  final String heading;
  final String body;

  const StaticSection({required this.heading, required this.body});
}

/// Shared scaffold for plain-text policy / help pages reachable from Settings.
///
/// Has a back button, a small eyebrow + display title, and renders a list of
/// [StaticSection]s. An optional [footer] widget renders below the last
/// section (used for the "Open source licenses" button on About).
class StaticPageShell extends StatelessWidget {
  final String eyebrow;
  final String title;
  final List<StaticSection> sections;
  final Widget? footer;

  const StaticPageShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.sections,
    this.footer,
  });

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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                children: [
                  Text(
                    eyebrow,
                    style: FLType.label.copyWith(
                      color: t.c.textMuted,
                      letterSpacing: 1.32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: FLType.displayMd.copyWith(
                      color: t.c.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final s in sections)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: _Section(section: s),
                    ),
                  if (footer != null) footer!,
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final StaticSection section;
  const _Section({required this.section});

  @override
  Widget build(BuildContext context) {
    final t = FLTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.heading,
          style: FLType.titleSm.copyWith(
            color: t.c.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          section.body,
          style: FLType.bodyMd.copyWith(
            color: t.c.textSecondary,
            height: 1.65,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'design/design.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/locale_service.dart';
import 'services/tutorial_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await LocaleService().initialize();
  runApp(const FitLogApp());
}

class FitLogApp extends StatelessWidget {
  const FitLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = LocaleService();
    return ListenableBuilder(
      listenable: localeService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Fit-Log',
          debugShowCheckedModeBanner: false,
          locale: localeService.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // The MaterialApp here is purely a routing/localization shell.
          // All visual elements are rendered through FLTheme in the builder.
          builder: (context, child) => FLThemeScope(child: child!),
          home: const _Bootstrap(),
        );
      },
    );
  }
}

/// First widget after the MaterialApp shell. Decides whether to show the
/// onboarding walkthrough (first launch) or jump straight into the home
/// screen, without a transition flash.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  // null  → still checking SharedPreferences
  // true  → show home
  // false → show onboarding
  bool? _ready;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final show = await TutorialService().shouldShowOnboarding();
    if (!mounted) return;
    setState(() => _ready = !show);
  }

  void _onOnboardingDone() {
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready == null) {
      // Splash equivalent — match the canvas color so there is no flash.
      final brightness = MediaQuery.platformBrightnessOf(context);
      final bg = brightness == Brightness.dark
          ? FLColors.dark.bgCanvas
          : FLColors.light.bgCanvas;
      return ColoredBox(color: bg);
    }
    if (_ready!) return const HomeScreen();
    return OnboardingScreen(onDone: _onOnboardingDone);
  }
}

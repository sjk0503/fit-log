import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'design/design.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/locale_service.dart';

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
          home: const HomeScreen(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/app_state.dart';
import 'core/l10n.dart';
import 'core/theme.dart';
import 'screens/auth/phone_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/splash_screen.dart';

class ArindiApp extends StatelessWidget {
  const ArindiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return MaterialApp(
      title: 'Arindi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: state.themeMode,
      locale: state.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: state.loading
          ? const SplashScreen()
          : (state.isLoggedIn ? const MainShell() : const PhoneScreen()),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/mali_theme.dart';
import 'splash_screen.dart';

class MaliApp extends StatelessWidget {
  const MaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مالي',
      debugShowCheckedModeBanner: false,
      theme: MaliTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumeno/app/router/app_router.dart';

import 'theme/lumeno_theme.dart';

class LumenoApp extends StatelessWidget {
  const LumenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumeno',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: LumenoTheme.light,
      darkTheme: LumenoTheme.dark,

      //themeMode: ThemeMode.system,
      //themeMode: ThemeMode.dark,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}

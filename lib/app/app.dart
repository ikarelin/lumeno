import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'theme/lumeno_theme.dart';

class LumenoApp extends StatelessWidget {
  const LumenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumeno',

      locale: context.locale,

      supportedLocales: context.supportedLocales,

      localizationsDelegates: context.localizationDelegates,

      theme: LumenoTheme.light,

      darkTheme: LumenoTheme.dark,

      themeMode: ThemeMode.system,

      home: Scaffold(body: Center(child: const Text('app.name').tr())),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumeno/app/router/app_router.dart';
import 'package:lumeno/app/theme/theme_mode_controller.dart';

import 'theme/lumeno_theme.dart';

class LumenoApp extends ConsumerWidget {
  const LumenoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Lumeno',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: LumenoTheme.light,
      darkTheme: LumenoTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}

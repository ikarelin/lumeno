import 'package:flutter/material.dart';

import 'theme/lumeno_theme.dart';

class LumenoApp extends StatelessWidget {
  const LumenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumeno',

      debugShowCheckedModeBanner: false,

      theme: LumenoTheme.light,

      darkTheme: LumenoTheme.dark,

      themeMode: ThemeMode.system,

      home: const Scaffold(
        body: Center(
          child: Text(
            'Lumeno',
          ),
        ),
      ),
    );
  }
}
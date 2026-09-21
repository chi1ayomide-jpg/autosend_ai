import 'package:flutter/material.dart';
import 'theme/glass_theme.dart';
import 'screens/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AutoSendApp());
}

class AutoSendApp extends StatelessWidget {
  const AutoSendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoSend AI',
      debugShowCheckedModeBanner: false,
      theme: GlassTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}

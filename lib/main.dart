import 'package:flutter/material.dart';
import 'theme/glass_theme.dart';
import 'screens/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OmniFlowApp());
}

class OmniFlowApp extends StatelessWidget {
  const OmniFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniFlow AI',
      debugShowCheckedModeBanner: false,
      theme: GlassTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}

// Alias for test backward-compatibility
typedef AutoSendApp = OmniFlowApp;

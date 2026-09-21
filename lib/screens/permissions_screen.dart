import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/permission_card.dart';
import '../services/native_channel.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  Map<String, bool> _permissions = {
    'accessibility': false,
    'notification': false,
    'battery': false,
    'exactAlarm': false,
  };

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await NativeChannel.checkPermissions();
    setState(() {
      _permissions = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enable Automation"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Complete these steps to activate Auto-Pilot.",
              style: TextStyle(
                color: GlassTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: 14,
              child: Row(
                children: [
                  const Icon(Icons.play_circle_fill, color: GlassTheme.primaryNeon),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Need help enabling these steps?",
                      style: TextStyle(color: GlassTheme.textPrimary, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Watch Tutorial", style: TextStyle(color: GlassTheme.primaryNeon)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PermissionCard(
              icon: Icons.accessibility_new,
              title: "Accessibility Service",
              subtitle: "Allows app to type text and tap 'Send'",
              isGranted: _permissions['accessibility'] ?? false,
              onEnable: () async {
                await NativeChannel.openAccessibilitySettings();
                _checkPermissions();
              },
            ),
            PermissionCard(
              icon: Icons.notifications_active,
              title: "Background Overlay / Listener",
              subtitle: "Auto-reply needs notification access to read chats",
              isGranted: _permissions['notification'] ?? false,
              onEnable: () async {
                await NativeChannel.openNotificationSettings();
                _checkPermissions();
              },
            ),
            PermissionCard(
              icon: Icons.alarm,
              title: "Exact Alarms",
              subtitle: "Precise scheduling for time-critical messages",
              isGranted: _permissions['exactAlarm'] ?? false,
              onEnable: () async {
                await NativeChannel.openExactAlarmSettings();
                _checkPermissions();
              },
            ),
            PermissionCard(
              icon: Icons.battery_charging_full,
              title: "Performance Optimization",
              subtitle: "Ensures messages send on time bypassing Doze mode",
              isGranted: _permissions['battery'] ?? false,
              onEnable: () async {
                await NativeChannel.requestBatteryOptimization();
                _checkPermissions();
              },
            ),
            const SizedBox(height: 24),
            GlassContainer(
              color: Colors.black.withOpacity(0.3),
              borderRadius: 14,
              child: const Row(
                children: [
                  Icon(Icons.lock, color: GlassTheme.textMuted, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "We do not collect personal data. These permissions are strictly required for on-device automation workflow.",
                      style: TextStyle(color: GlassTheme.textMuted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

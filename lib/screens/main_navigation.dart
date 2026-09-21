import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'auto_reply_screen.dart';
import 'voice_automation_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigateTab: (index) => setState(() => _currentIndex = index)),
      const TasksScreen(),
      const AutoReplyScreen(),
      const VoiceAutomationScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          color: GlassTheme.backgroundSecondary.withOpacity(0.9),
          borderColor: GlassTheme.glassBorder,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, "Home"),
              _buildNavItem(1, Icons.task_alt, "Tasks"),
              _buildNavItem(2, Icons.reply, "Auto Reply"),
              _buildNavItem(3, Icons.graphic_eq, "Voice"),
              _buildNavItem(4, Icons.bar_chart, "Analytics"),
              _buildNavItem(5, Icons.settings, "Settings"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? GlassTheme.primaryEmerald.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isSelected ? GlassTheme.primaryNeon : GlassTheme.textMuted,
          size: 22,
        ),
      ),
    );
  }
}

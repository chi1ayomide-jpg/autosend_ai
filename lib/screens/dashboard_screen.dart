import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/countdown_timer.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/native_channel.dart';
import 'permissions_screen.dart';
import 'pro_modal_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ScheduledTask? _nextTask;
  bool _needsPermissions = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final tasks = await StorageService.loadTasks();
    final pending = tasks.where((t) => t.status == TaskStatus.pending).toList();

    pending.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    final perms = await NativeChannel.checkPermissions();
    final allGranted = perms.values.every((isGranted) => isGranted);

    setState(() {
      _nextTask = pending.isNotEmpty ? pending.first : null;
      _needsPermissions = !allGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: GlassTheme.primaryEmerald.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, color: GlassTheme.primaryNeon, size: 20),
            ),
            const SizedBox(width: 10),
            const Text("AutoSend AI"),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProModalScreen()),
              );
            },
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              borderRadius: 20,
              color: GlassTheme.primaryNeon.withOpacity(0.15),
              borderColor: GlassTheme.primaryNeon,
              margin: const EdgeInsets.only(right: 16),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: GlassTheme.primaryNeon, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "Free: 1/10",
                    style: TextStyle(
                      color: GlassTheme.primaryNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Setup Required Alert Banner
            if (_needsPermissions)
              GlassContainer(
                margin: const EdgeInsets.only(bottom: 20),
                color: GlassTheme.warningOrange.withOpacity(0.15),
                borderColor: GlassTheme.warningOrange,
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: GlassTheme.warningOrange, size: 30),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Setup Required",
                            style: TextStyle(
                              color: GlassTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "AutoSend needs permissions to run background automation.",
                            style: TextStyle(color: GlassTheme.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PermissionsScreen()),
                        );
                        _loadDashboardData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlassTheme.warningOrange,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("FIX NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
              ),

            // 2. Voice Automation Banner
            GlassContainer(
              margin: const EdgeInsets.only(bottom: 20),
              color: GlassTheme.accentBlue.withOpacity(0.2),
              borderColor: GlassTheme.accentBlue.withOpacity(0.5),
              onTap: () => widget.onNavigateTab(3), // Navigate to Voice Tab
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GlassTheme.accentBlue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Voice Automation",
                              style: TextStyle(
                                color: GlassTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: GlassTheme.primaryNeon,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "NEW",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Speak to schedule tasks instantly",
                          style: TextStyle(color: GlassTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: GlassTheme.textSecondary, size: 16),
                ],
              ),
            ),

            // 3. Up Next Live Counter Card
            GlassContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              borderRadius: 22,
              margin: const EdgeInsets.only(bottom: 20),
              child: _nextTask == null
                  ? const Column(
                      children: [
                        Icon(Icons.event_available, color: GlassTheme.primaryEmerald, size: 48),
                        SizedBox(height: 10),
                        Text(
                          "No Scheduled Tasks Up Next",
                          style: TextStyle(color: GlassTheme.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tap 'New Task' below to queue an automated WhatsApp message.",
                          style: TextStyle(color: GlassTheme.textSecondary, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        CountdownTimerWidget(targetTime: _nextTask!.scheduledTime),
                        const SizedBox(height: 16),
                        const Divider(color: GlassTheme.glassBorderLight),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: GlassTheme.primaryEmerald.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chat_bubble_outline, color: GlassTheme.primaryNeon, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nextTask!.recipientName,
                                    style: const TextStyle(
                                      color: GlassTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _nextTask!.message,
                                    style: const TextStyle(color: GlassTheme.textSecondary, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: GlassTheme.textSecondary, size: 18),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: GlassTheme.errorRed, size: 18),
                              onPressed: () async {
                                final tasks = await StorageService.loadTasks();
                                tasks.removeWhere((t) => t.id == _nextTask!.id);
                                await StorageService.saveTasks(tasks);
                                _loadDashboardData();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            // 4. Quick Action Grid Buttons
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    height: 120,
                    color: GlassTheme.accentBlue.withOpacity(0.25),
                    borderColor: GlassTheme.accentBlue,
                    onTap: () => widget.onNavigateTab(1), // Tasks screen
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle, color: GlassTheme.accentBlue, size: 36),
                        SizedBox(height: 8),
                        Text(
                          "New Task",
                          style: TextStyle(
                            color: GlassTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GlassContainer(
                    height: 120,
                    onTap: () {},
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt, color: GlassTheme.warningOrange, size: 32),
                        SizedBox(height: 8),
                        Text(
                          "Browse Ideas",
                          style: TextStyle(color: GlassTheme.textSecondary, fontSize: 11),
                        ),
                        Text(
                          "Templates",
                          style: TextStyle(
                            color: GlassTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GlassContainer(
                    height: 120,
                    onTap: () {},
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.help_outline, color: GlassTheme.textSecondary, size: 32),
                        SizedBox(height: 8),
                        Text(
                          "Guide & support",
                          style: TextStyle(color: GlassTheme.textSecondary, fontSize: 11),
                        ),
                        Text(
                          "Help",
                          style: TextStyle(
                            color: GlassTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

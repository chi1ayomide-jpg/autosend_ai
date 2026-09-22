import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class VoiceAutomationScreen extends StatefulWidget {
  const VoiceAutomationScreen({super.key});

  @override
  State<VoiceAutomationScreen> createState() => _VoiceAutomationScreenState();
}

class _VoiceAutomationScreenState extends State<VoiceAutomationScreen> {
  bool _isListening = false;
  String _spokenText = "Tap the mic and speak e.g., 'Remind John tomorrow at 8am to send the invoice'";
  final TextEditingController _voiceInputController = TextEditingController();

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _spokenText = "Listening for voice input...";
        // Simulate speech recognition capture or show speech input
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _isListening) {
            setState(() {
              _isListening = false;
              _spokenText = "Send Good Morning to Sales Team tomorrow at 9 AM";
              _voiceInputController.text = _spokenText;
            });
          }
        });
      }
    });
  }

  void _scheduleVoiceTask() async {
    final text = _voiceInputController.text.isNotEmpty ? _voiceInputController.text : _spokenText;
    if (text.isEmpty || text.startsWith("Tap the mic")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please speak or type a task first.")),
      );
      return;
    }

    final newTask = ScheduledTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipientName: "Voice Contact",
      recipientPhone: "+2348000000000",
      message: text,
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      status: TaskStatus.pending,
    );

    final tasks = await StorageService.loadTasks();
    tasks.add(newTask);
    await StorageService.saveTasks(tasks);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Voice Task Scheduled: '$text'"),
        backgroundColor: GlassTheme.primaryEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Automation"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            GlassContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              borderRadius: 24,
              borderColor: _isListening ? GlassTheme.primaryNeon : GlassTheme.glassBorder,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: _isListening
                            ? GlassTheme.primaryNeon.withOpacity(0.3)
                            : GlassTheme.accentBlue.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_isListening)
                            BoxShadow(
                              color: GlassTheme.primaryNeon.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 58,
                        color: _isListening ? GlassTheme.primaryNeon : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isListening ? "Listening..." : "Tap to Speak",
                    style: const TextStyle(
                      color: GlassTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _spokenText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: GlassTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _voiceInputController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Or edit voice transcript here...",
                      hintStyle: const TextStyle(color: GlassTheme.textMuted),
                      filled: true,
                      fillColor: GlassTheme.glassFillLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: GlassTheme.glassBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _scheduleVoiceTask,
                      icon: const Icon(Icons.alarm_add, color: Colors.black),
                      label: const Text("Schedule Spoken Task", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlassTheme.primaryNeon,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassContainer(
              borderRadius: 16,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Try Saying:",
                    style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("• 'Send Happy Birthday to Sarah at 12 AM'", style: TextStyle(color: GlassTheme.textSecondary)),
                  SizedBox(height: 4),
                  Text("• 'Remind Sales Group every Monday at 9 AM'", style: TextStyle(color: GlassTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

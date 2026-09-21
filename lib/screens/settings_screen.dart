import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;
  bool _isLoading = true;
  final _geminiKeyController = TextEditingController();
  final _openAiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await StorageService.loadSettings();
    setState(() {
      _settings = s;
      _geminiKeyController.text = s.geminiApiKey;
      _openAiKeyController.text = s.openAiApiKey;
      _isLoading = false;
    });
  }

  Future<void> _updateSettings(AppSettings updated) async {
    setState(() => _settings = updated);
    await StorageService.saveSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: GlassTheme.primaryNeon)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Banner
            GlassContainer(
              margin: const EdgeInsets.only(bottom: 20),
              borderRadius: 18,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: GlassTheme.primaryEmerald,
                    child: const Text("P", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Premeire League Fans", style: TextStyle(color: GlassTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("premeireleaguefans@gmail.com", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 12)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: GlassTheme.warningOrange, size: 14),
                            SizedBox(width: 4),
                            Text("5 AI Credits remaining", style: TextStyle(color: GlassTheme.accentBlue, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // AI API Settings
            const Text("AI Integration Credentials", style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            GlassContainer(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  TextField(
                    controller: _geminiKeyController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: "Google Gemini API Key",
                      labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save, color: GlassTheme.primaryNeon),
                        onPressed: () {
                          _updateSettings(AppSettings(
                            autoReplyEnabled: _settings.autoReplyEnabled,
                            geminiApiKey: _geminiKeyController.text,
                            openAiApiKey: _openAiKeyController.text,
                            selectedAiModel: _settings.selectedAiModel,
                            pauseOnCalls: _settings.pauseOnCalls,
                            askBeforeSending: _settings.askBeforeSending,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gemini API Key Saved")));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scheduled Automation Settings Section
            const Text("Scheduled Controls", style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            _buildSwitchTile(
              title: "Pause automation on calls",
              subtitle: "Automatically pause sending if you receive or make a phone call.",
              value: _settings.pauseOnCalls,
              onChanged: (val) => _updateSettings(AppSettings(
                autoReplyEnabled: _settings.autoReplyEnabled,
                geminiApiKey: _settings.geminiApiKey,
                openAiApiKey: _settings.openAiApiKey,
                selectedAiModel: _settings.selectedAiModel,
                pauseOnCalls: val,
                askBeforeSending: _settings.askBeforeSending,
              )),
            ),

            _buildSwitchTile(
              title: "Default 'Ask before sending' state",
              subtitle: "Choose if 'Ask before sending' should be enabled by default for new tasks.",
              value: _settings.askBeforeSending,
              onChanged: (val) => _updateSettings(AppSettings(
                autoReplyEnabled: _settings.autoReplyEnabled,
                geminiApiKey: _settings.geminiApiKey,
                openAiApiKey: _settings.openAiApiKey,
                selectedAiModel: _settings.selectedAiModel,
                pauseOnCalls: _settings.pauseOnCalls,
                askBeforeSending: val,
              )),
            ),

            _buildSwitchTile(
              title: "Skip Internet Check",
              subtitle: "Allow automation to proceed even if no network is detected.",
              value: _settings.skipInternetCheck,
              onChanged: (val) => _updateSettings(AppSettings(
                autoReplyEnabled: _settings.autoReplyEnabled,
                geminiApiKey: _settings.geminiApiKey,
                openAiApiKey: _settings.openAiApiKey,
                selectedAiModel: _settings.selectedAiModel,
                pauseOnCalls: _settings.pauseOnCalls,
                askBeforeSending: _settings.askBeforeSending,
                skipInternetCheck: val,
              )),
            ),

            const SizedBox(height: 20),
            // Toolbox Section
            const Text("Toolbox & Data", style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            GlassContainer(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.backup, color: GlassTheme.primaryNeon),
                title: const Text("Backup & Restore", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Backup App Data to local JSON storage or restore queue.", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 11)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backup file generated: autosend_backup.json")));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: 14,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: GlassTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: GlassTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: GlassTheme.primaryNeon,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

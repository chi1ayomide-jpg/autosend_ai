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
  AppSettings _settings = AppSettings();
  final _geminiKeyController = TextEditingController();
  final _openAiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await StorageService.loadSettings();
    if (mounted) {
      setState(() {
        _settings = s;
        _geminiKeyController.text = s.geminiApiKey;
        _openAiKeyController.text = s.openAiApiKey;
      });
    }
  }

  Future<void> _updateSettings(AppSettings updated) async {
    setState(() => _settings = updated);
    await StorageService.saveSettings(updated);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("OmniFlow Settings"),
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
                    child: const Text("O", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("OmniFlow Enterprise", style: TextStyle(color: GlassTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Active Profile • Nigeria (+234)", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 12)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.verified, color: GlassTheme.primaryNeon, size: 14),
                            SizedBox(width: 4),
                            Text("Unlimited Automations & Bulk Engine", style: TextStyle(color: GlassTheme.accentBlue, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // WhatsApp Engine Section
            const Text("WhatsApp Engine Routing", style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            GlassContainer(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Default WhatsApp Client", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _settings.defaultWhatsAppApp,
                    dropdownColor: GlassTheme.backgroundSecondary,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: "com.whatsapp", child: Text("WhatsApp Standard (com.whatsapp)")),
                      DropdownMenuItem(value: "com.whatsapp.w4b", child: Text("WhatsApp Business (com.whatsapp.w4b)")),
                      DropdownMenuItem(value: "com.gbwhatsapp", child: Text("GB WhatsApp (com.gbwhatsapp)")),
                      DropdownMenuItem(value: "auto_rotate", child: Text("Rotate Across All Installed Apps")),
                    ],
                    onChanged: (val) {
                      if (val != null) _updateSettings(_settings.copyWith(defaultWhatsAppApp: val));
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Sending Delay Interval", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 13)),
                      Text("${_settings.defaultDelaySeconds}s delay", style: const TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _settings.defaultDelaySeconds.toDouble(),
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    activeColor: GlassTheme.primaryNeon,
                    onChanged: (val) => _updateSettings(_settings.copyWith(defaultDelaySeconds: val.toInt())),
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
                          _updateSettings(_settings.copyWith(geminiApiKey: _geminiKeyController.text));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gemini API Key Saved")));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _openAiKeyController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: "OpenAI API Key (Optional)",
                      labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save, color: GlassTheme.primaryNeon),
                        onPressed: () {
                          _updateSettings(_settings.copyWith(openAiApiKey: _openAiKeyController.text));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OpenAI API Key Saved")));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scheduled Automation Settings Section
            const Text("Automation Guardrails & Approvals", style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),

            _buildSwitchTile(
              title: "Require Approval Before Sending",
              subtitle: "Never sends any automated or bulk message without explicit user review & confirmation.",
              value: _settings.askBeforeSending,
              onChanged: (val) => _updateSettings(_settings.copyWith(askBeforeSending: val)),
            ),

            _buildSwitchTile(
              title: "Ignore Accents in Trigger Matching",
              subtitle: "Matches accented words like 'crème' or 'café' transparently.",
              value: _settings.ignoreAccents,
              onChanged: (val) => _updateSettings(_settings.copyWith(ignoreAccents: val)),
            ),

            _buildSwitchTile(
              title: "Pause automation on calls",
              subtitle: "Automatically pause sending if you receive or make a phone call.",
              value: _settings.pauseOnCalls,
              onChanged: (val) => _updateSettings(_settings.copyWith(pauseOnCalls: val)),
            ),

            _buildSwitchTile(
              title: "Skip Internet Check",
              subtitle: "Allow automation to proceed even if no network is detected.",
              value: _settings.skipInternetCheck,
              onChanged: (val) => _updateSettings(_settings.copyWith(skipInternetCheck: val)),
            ),

            _buildSwitchTile(
              title: "Notification Alerts on Sent",
              subtitle: "Post a status notification whenever an auto-reply or bulk message finishes.",
              value: _settings.notifyOnSent,
              onChanged: (val) => _updateSettings(_settings.copyWith(notifyOnSent: val)),
            ),

            const SizedBox(height: 20),
            // Toolbox Section
            const Text("Data & Storage", style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            GlassContainer(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.backup, color: GlassTheme.primaryNeon),
                title: const Text("Export & Backup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Export rules, templates and campaigns to local storage.", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 11)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backup generated: omniflow_backup.json")));
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

import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';
import '../models/auto_reply_rule.dart';
import '../services/storage_service.dart';
import 'permissions_screen.dart';

class AutoReplyScreen extends StatefulWidget {
  const AutoReplyScreen({super.key});

  @override
  State<AutoReplyScreen> createState() => _AutoReplyScreenState();
}

class _AutoReplyScreenState extends State<AutoReplyScreen> {
  List<AutoReplyRule> _rules = [];
  bool _autoReplyEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final rules = await StorageService.loadRules();
    final settings = await StorageService.loadSettings();
    setState(() {
      _rules = rules;
      _autoReplyEnabled = settings.autoReplyEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auto Reply"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Need Help?", style: TextStyle(color: GlassTheme.textSecondary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Notification Access Alert
          GlassContainer(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            color: GlassTheme.accentBlue.withOpacity(0.2),
            borderColor: GlassTheme.accentBlue,
            borderRadius: 14,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Notification access enabled. Auto-reply reads incoming notifications to reply instantly with AI.",
                    style: TextStyle(color: GlassTheme.textPrimary, fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PermissionsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlassTheme.accentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Check", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _rules.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mark_chat_read_outlined, color: GlassTheme.textMuted, size: 48),
                        SizedBox(height: 12),
                        Text(
                          "No auto-reply rules found.\nTap + to create one.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: GlassTheme.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _rules.length,
                    itemBuilder: (context, index) {
                      final rule = _rules[index];
                      return GlassContainer(
                        margin: const EdgeInsets.only(bottom: 12),
                        borderRadius: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: GlassTheme.primaryEmerald.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.psychology, color: GlassTheme.primaryNeon, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rule.name,
                                    style: const TextStyle(
                                      color: GlassTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Trigger: ${rule.triggerPattern} • ${rule.matchType.name}",
                                    style: const TextStyle(color: GlassTheme.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: rule.isEnabled,
                              activeColor: GlassTheme.primaryNeon,
                              onChanged: (val) async {
                                final updated = AutoReplyRule(
                                  id: rule.id,
                                  name: rule.name,
                                  triggerPattern: rule.triggerPattern,
                                  matchType: rule.matchType,
                                  responseMessage: rule.responseMessage,
                                  isEnabled: val,
                                );
                                _rules[index] = updated;
                                await StorageService.saveRules(_rules);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GlassTheme.primaryNeon,
        foregroundColor: Colors.black,
        onPressed: () => _showAddRuleDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRuleDialog() {
    final nameController = TextEditingController();
    final triggerController = TextEditingController();
    final responseController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GlassTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Auto-Reply Rule",
                style: TextStyle(
                  color: GlassTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Rule Name",
                  labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                  filled: true,
                  fillColor: GlassTheme.glassFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: triggerController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Incoming Keyword Trigger (e.g. * or 'price')",
                  labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                  filled: true,
                  fillColor: GlassTheme.glassFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: responseController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "AI Response Override / Preset Text",
                  labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                  filled: true,
                  fillColor: GlassTheme.glassFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    final newRule = AutoReplyRule(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      triggerPattern: triggerController.text.isNotEmpty ? triggerController.text : "*",
                      matchType: MatchType.aiAgent,
                      responseMessage: responseController.text,
                      isEnabled: true,
                    );

                    _rules.add(newRule);
                    await StorageService.saveRules(_rules);

                    Navigator.pop(context);
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlassTheme.primaryNeon,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save Rule", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

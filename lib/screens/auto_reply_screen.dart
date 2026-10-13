import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/variable_chips_bar.dart';
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
        title: const Text("Auto Reply Engine"),
        actions: [
          Row(
            children: [
              Text(
                _autoReplyEnabled ? "ACTIVE" : "PAUSED",
                style: TextStyle(
                  color: _autoReplyEnabled ? GlassTheme.primaryNeon : GlassTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _autoReplyEnabled,
                activeColor: GlassTheme.primaryNeon,
                onChanged: (val) async {
                  setState(() => _autoReplyEnabled = val);
                  final settings = await StorageService.loadSettings();
                  await StorageService.saveSettings(settings.copyWith(autoReplyEnabled: val));
                },
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          // Banner Notification Access Alert
          GlassContainer(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            color: GlassTheme.accentBlue.withOpacity(0.15),
            borderColor: GlassTheme.accentBlue,
            borderRadius: 14,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Reads notifications via NotificationListenerService & replies inline via RemoteInput without opening WhatsApp.",
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
                  child: const Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                          "No auto-reply rules configured.\nTap + to create a smart response rule.",
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
                      final hasVariations = rule.responseMessage.contains("///");

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
                                  Row(
                                    children: [
                                      Text(
                                        rule.name,
                                        style: const TextStyle(
                                          color: GlassTheme.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (hasVariations) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: GlassTheme.warningOrange.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text("Multi-Reply", style: TextStyle(color: GlassTheme.warningOrange, fontSize: 10)),
                                        ),
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Trigger: '${rule.triggerPattern}' • ${rule.matchType.name}",
                                    style: const TextStyle(color: GlassTheme.textSecondary, fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    rule.responseMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: GlassTheme.primaryNeon, fontSize: 11),
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
                                  ignoreAccents: rule.ignoreAccents,
                                  subRuleOf: rule.subRuleOf,
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
    MatchType selectedMatchType = MatchType.contains;
    bool ignoreAccents = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GlassTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
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
                        labelText: "Rule Name (e.g. Price Inquiry)",
                        labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                        filled: true,
                        fillColor: GlassTheme.glassFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<MatchType>(
                            value: selectedMatchType,
                            dropdownColor: GlassTheme.backgroundSecondary,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: "Match Type",
                              labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                              filled: true,
                              fillColor: GlassTheme.glassFill,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: MatchType.values.map((m) {
                              return DropdownMenuItem(value: m, child: Text(m.name.toUpperCase()));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedMatchType = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Text("Ignore Accents", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 11)),
                            Switch(
                              value: ignoreAccents,
                              activeColor: GlassTheme.primaryNeon,
                              onChanged: (val) => setModalState(() => ignoreAccents = val),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: triggerController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Incoming Trigger Keyword (or * for all)",
                        labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                        filled: true,
                        fillColor: GlassTheme.glassFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Insert Dynamic Tags:",
                      style: TextStyle(color: GlassTheme.textMuted, fontSize: 12),
                    ),
                    VariableChipsBar(controller: responseController),
                    TextField(
                      controller: responseController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Auto-Reply Text (Separate with /// for rotation)",
                        labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                        filled: true,
                        fillColor: GlassTheme.glassFill,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tip: Use '///' to separate rotating replies, e.g. Hello {name}! /// Good day {name}!",
                      style: TextStyle(color: GlassTheme.accentBlue, fontSize: 11),
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
                            matchType: selectedMatchType,
                            responseMessage: responseController.text.isNotEmpty ? responseController.text : "Thank you for contacting us, {name}!",
                            isEnabled: true,
                            ignoreAccents: ignoreAccents,
                          );

                          _rules.add(newRule);
                          await StorageService.saveRules(_rules);

                          if (context.mounted) {
                            Navigator.pop(context);
                            _loadData();
                          }
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
              ),
            );
          },
        );
      },
    );
  }
}

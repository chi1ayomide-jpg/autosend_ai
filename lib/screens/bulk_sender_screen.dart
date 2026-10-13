import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/variable_chips_bar.dart';
import '../services/variable_service.dart';
import '../services/native_channel.dart';

class BulkRecipient {
  final String name;
  final String phone;
  final String source; // 'contact', 'manual', 'log', 'group'
  bool isSelected;

  BulkRecipient({
    required this.name,
    required this.phone,
    this.source = 'contact',
    this.isSelected = true,
  });
}

class BulkSenderScreen extends StatefulWidget {
  const BulkSenderScreen({super.key});

  @override
  State<BulkSenderScreen> createState() => _BulkSenderScreenState();
}

class _BulkSenderScreenState extends State<BulkSenderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Selected WhatsApp variant
  String _selectedPackage = "com.whatsapp";
  double _sendDelaySeconds = 2.0;

  // Message template
  final TextEditingController _messageController = TextEditingController(
    text: "Hello {name}, wishing you a productive {date}! Let's connect at {time}.",
  );

  // Manual entry fields
  String _selectedCountryCode = "+234"; // Default Nigeria
  final TextEditingController _manualPhoneController = TextEditingController();
  final TextEditingController _manualNameController = TextEditingController();

  // Search filter
  String _contactSearch = "";

  // Target Recipients
  final List<BulkRecipient> _recipients = [
    BulkRecipient(name: "Pastor Emmanuel", phone: "+2348031234567", source: "contact", isSelected: true),
    BulkRecipient(name: "Ayo Marketing Lead", phone: "+2348029876543", source: "contact", isSelected: true),
    BulkRecipient(name: "Chidinma VIP", phone: "+2348145556677", source: "contact", isSelected: true),
    BulkRecipient(name: "David Tech", phone: "+2349012348899", source: "contact", isSelected: false),
    BulkRecipient(name: "Engr. Tunde", phone: "+2348055551212", source: "contact", isSelected: false),
  ];

  // Call Logs / Recent
  final List<BulkRecipient> _recentLogs = [
    BulkRecipient(name: "Blessing Ade", phone: "+2348099887766", source: "log", isSelected: false),
    BulkRecipient(name: "Dr. Kalu", phone: "+2348133221100", source: "log", isSelected: false),
    BulkRecipient(name: "Grace Sunday", phone: "+2347066554433", source: "log", isSelected: false),
  ];

  // Preset templates
  final List<Map<String, String>> _templates = [
    {
      "title": "Friendly Check-in",
      "text": "Hi {first_name}, hope you are doing well today! Just checking in with you.",
    },
    {
      "title": "Meeting Reminder",
      "text": "Good day {name}, this is a gentle reminder of our session scheduled for {time}.",
    },
    {
      "title": "VIP Broadcast",
      "text": "Dear {name}, here is your exclusive update for {date}. Have a great week ahead!",
    },
  ];

  bool _isSending = false;
  int _sentProgress = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _manualPhoneController.dispose();
    _manualNameController.dispose();
    super.dispose();
  }

  int get _selectedCount => _recipients.where((r) => r.isSelected).length;

  void _addManualRecipient() {
    final rawNumber = _manualPhoneController.text.trim();
    if (rawNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid phone number")),
      );
      return;
    }

    final fullNumber = rawNumber.startsWith('+') ? rawNumber : "$_selectedCountryCode$rawNumber";
    final name = _manualNameController.text.trim().isEmpty ? "Contact ${_recipients.length + 1}" : _manualNameController.text.trim();

    // Check duplicate
    final exists = _recipients.any((r) => r.phone.replaceAll(RegExp(r'\D'), '') == fullNumber.replaceAll(RegExp(r'\D'), ''));
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Number already exists in send queue")),
      );
      return;
    }

    setState(() {
      _recipients.insert(
        0,
        BulkRecipient(name: name, phone: fullNumber, source: "manual", isSelected: true),
      );
      _manualPhoneController.clear();
      _manualNameController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Added $name ($fullNumber) to queue")),
    );
  }

  Future<void> _startCampaign() async {
    final active = _recipients.where((r) => r.isSelected).toList();
    if (active.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No recipients selected! Select at least 1.")),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _sentProgress = 0;
    });

    for (int i = 0; i < active.length; i++) {
      if (!_isSending) break;
      final target = active[i];
      final personalized = VariableService.resolve(
        _messageController.text,
        name: target.name,
        phone: target.phone,
      );

      // Trigger native WhatsApp automation channel
      await NativeChannel.triggerAutomation(
        phoneNumber: target.phone,
        message: personalized,
      );

      setState(() => _sentProgress = i + 1);
      await Future.delayed(Duration(seconds: _sendDelaySeconds.toInt()));
    }

    setState(() => _isSending = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Campaign completed! Sent $_sentProgress messages.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.send_rounded, color: GlassTheme.primaryNeon, size: 20),
            SizedBox(width: 8),
            Text("Bulk Sender & Campaigns"),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: GlassTheme.primaryEmerald.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GlassTheme.primaryNeon),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_alt, color: GlassTheme.primaryNeon, size: 14),
                const SizedBox(width: 4),
                Text(
                  "$_selectedCount In Queue",
                  style: const TextStyle(
                    color: GlassTheme.primaryNeon,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: GlassTheme.primaryNeon,
          labelColor: GlassTheme.primaryNeon,
          unselectedLabelColor: GlassTheme.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: "Dashboard"),
            Tab(icon: Icon(Icons.contacts_rounded), text: "Contacts"),
            Tab(icon: Icon(Icons.dialpad_rounded), text: "Enter Number"),
            Tab(icon: Icon(Icons.history_rounded), text: "Recent Logs"),
            Tab(icon: Icon(Icons.star_rounded), text: "Favourites"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildContactsTab(),
          _buildEnterNumberTab(),
          _buildRecentLogsTab(),
          _buildFavouritesTab(),
        ],
      ),
    );
  }

  // TAB 1: Campaign Dashboard
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target WhatsApp Variant Selector
          GlassContainer(
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "WhatsApp Sender Engine",
                  style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPackage,
                  dropdownColor: GlassTheme.backgroundSecondary,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: "com.whatsapp", child: Text("WhatsApp Standard")),
                    DropdownMenuItem(value: "com.whatsapp.w4b", child: Text("WhatsApp Business")),
                    DropdownMenuItem(value: "com.gbwhatsapp", child: Text("GB WhatsApp")),
                    DropdownMenuItem(value: "auto_rotate", child: Text("Rotate Across All Installed")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPackage = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Sending Delay Interval", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 13)),
                    Text("${_sendDelaySeconds.toInt()}s per contact", style: const TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _sendDelaySeconds,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  activeColor: GlassTheme.primaryNeon,
                  onChanged: (val) => setState(() => _sendDelaySeconds = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Message Template Composer with Variables
          GlassContainer(
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Campaign Message Template", style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text("Dynamic Tags", style: TextStyle(color: GlassTheme.textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                VariableChipsBar(controller: _messageController),
                const SizedBox(height: 6),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "Type template using {name}, {time}, {date}...",
                    hintStyle: TextStyle(color: GlassTheme.textMuted),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                // Live preview banner
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GlassTheme.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Live Preview (Sample Contact):", style: TextStyle(color: GlassTheme.accentBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        VariableService.resolve(
                          _messageController.text,
                          name: _recipients.isNotEmpty ? _recipients.first.name : "Tunde Ade",
                          phone: _recipients.isNotEmpty ? _recipients.first.phone : "+23480...",
                        ),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Action Launch Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: Icon(_isSending ? Icons.pause_circle : Icons.rocket_launch, color: Colors.black),
              label: Text(
                _isSending ? "Pause Campaign ($_sentProgress / $_selectedCount)" : "Send to $_selectedCount Selected Contacts",
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GlassTheme.primaryNeon,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isSending ? () => setState(() => _isSending = false) : _startCampaign,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Contacts
  Widget _buildContactsTab() {
    final filtered = _recipients.where((r) => r.name.toLowerCase().contains(_contactSearch.toLowerCase()) || r.phone.contains(_contactSearch)).toList();
    final allSelected = filtered.isNotEmpty && filtered.every((r) => r.isSelected);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: GlassTheme.textMuted, size: 20),
                    hintText: "Search phone contacts...",
                    hintStyle: const TextStyle(color: GlassTheme.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => setState(() => _contactSearch = val),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: Icon(
                  allSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: GlassTheme.primaryNeon,
                  size: 20,
                ),
                label: Text(allSelected ? "Deselect" : "Select All", style: const TextStyle(color: GlassTheme.primaryNeon, fontSize: 12)),
                onPressed: () {
                  setState(() {
                    final newState = !allSelected;
                    for (var r in filtered) {
                      r.isSelected = newState;
                    }
                  });
                },
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: GlassTheme.primaryEmerald.withOpacity(0.3),
                  child: Text(item.name[0], style: const TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold)),
                ),
                title: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(item.phone, style: const TextStyle(color: GlassTheme.textMuted, fontSize: 12)),
                trailing: Checkbox(
                  value: item.isSelected,
                  activeColor: GlassTheme.primaryNeon,
                  checkColor: Colors.black,
                  onChanged: (val) => setState(() => item.isSelected = val ?? false),
                ),
                onTap: () => setState(() => item.isSelected = !item.isSelected),
              );
            },
          ),
        ),
      ],
    );
  }

  // TAB 3: Enter Number Direct (with Country Code)
  Widget _buildEnterNumberTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Add Recipient Direct", style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                TextField(
                  controller: _manualNameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: "Contact Name (Optional)",
                    labelStyle: TextStyle(color: GlassTheme.textSecondary),
                    prefixIcon: Icon(Icons.person, color: GlassTheme.textMuted, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: GlassTheme.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GlassTheme.glassBorder),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        dropdownColor: GlassTheme.backgroundSecondary,
                        underline: const SizedBox(),
                        style: const TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold),
                        items: const [
                          DropdownMenuItem(value: "+234", child: Text("🇳🇬 +234 (NG)")),
                          DropdownMenuItem(value: "+1", child: Text("🇺🇸 +1 (US)")),
                          DropdownMenuItem(value: "+44", child: Text("🇬🇧 +44 (UK)")),
                          DropdownMenuItem(value: "+91", child: Text("🇮🇳 +91 (IN)")),
                          DropdownMenuItem(value: "+233", child: Text("🇬🇭 +233 (GH)")),
                          DropdownMenuItem(value: "+254", child: Text("🇰🇪 +254 (KE)")),
                          DropdownMenuItem(value: "+27", child: Text("🇿🇦 +27 (ZA)")),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCountryCode = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _manualPhoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "803 123 4567",
                          hintStyle: TextStyle(color: GlassTheme.textMuted),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text("Add To Send Queue", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: GlassTheme.primaryNeon),
                    onPressed: _addManualRecipient,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text("Manually Added Queue Items", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._recipients.where((r) => r.source == "manual").map((item) => GlassContainer(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: 12,
                child: Row(
                  children: [
                    const Icon(Icons.person_pin, color: GlassTheme.primaryNeon, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text("${item.name} (${item.phone})", style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                      onPressed: () => setState(() => _recipients.remove(item)),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // TAB 4: Recent Logs
  Widget _buildRecentLogsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _recentLogs.length,
      itemBuilder: (context, index) {
        final log = _recentLogs[index];
        final inQueue = _recipients.any((r) => r.phone == log.phone);
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          borderRadius: 14,
          child: Row(
            children: [
              const Icon(Icons.phone_callback, color: GlassTheme.accentBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(log.phone, style: const TextStyle(color: GlassTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: inQueue ? Colors.grey[800] : GlassTheme.primaryEmerald,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: inQueue
                    ? null
                    : () {
                        setState(() {
                          _recipients.add(BulkRecipient(name: log.name, phone: log.phone, source: "log", isSelected: true));
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added ${log.name} to campaign")));
                      },
                child: Text(inQueue ? "Added" : "+ Add", style: TextStyle(color: inQueue ? Colors.white54 : GlassTheme.primaryNeon, fontSize: 12)),
              )
            ],
          ),
        );
      },
    );
  }

  // TAB 5: Favourites & Templates
  Widget _buildFavouritesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Saved Message Templates", style: TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ..._templates.map((tpl) => GlassContainer(
                margin: const EdgeInsets.only(bottom: 10),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tpl["title"]!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        TextButton(
                          onPressed: () {
                            setState(() => _messageController.text = tpl["text"]!);
                            _tabController.animateTo(0);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Template loaded into Campaign Dashboard!")));
                          },
                          child: const Text("Use Template", style: TextStyle(color: GlassTheme.primaryNeon, fontSize: 12)),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(tpl["text"]!, style: const TextStyle(color: GlassTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

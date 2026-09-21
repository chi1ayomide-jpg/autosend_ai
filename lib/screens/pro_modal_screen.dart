import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';

class ProModalScreen extends StatefulWidget {
  const ProModalScreen({super.key});

  @override
  State<ProModalScreen> createState() => _ProModalScreenState();
}

class _ProModalScreenState extends State<ProModalScreen> {
  int _selectedPlan = 2; // 0: 1 Month, 1: 12 Months, 2: Lifetime

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Unlock Pro Automation",
              style: TextStyle(
                color: GlassTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Supercharge your productivity with unlimited workflows and instant execution.",
              textAlign: TextAlign.center,
              style: TextStyle(color: GlassTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Features Comparison Table Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Features", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    const Text("Free  ", style: TextStyle(color: GlassTheme.textMuted, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: GlassTheme.accentBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("PRO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: GlassTheme.glassBorderLight),

            _buildFeatureRow("Advanced Attachments", "Photo", "Video & Docs"),
            _buildFeatureRow("Usage Dashboard", "❌", "Lifetime"),
            _buildFeatureRow("Heatmap Trends", "❌", "✔️"),
            _buildFeatureRow("Task Tagging", "❌", "✔️"),
            _buildFeatureRow("Filter & Search", "❌", "✔️"),
            _buildFeatureRow("Import CSV/Excel", "❌", "✔️"),
            _buildFeatureRow("Recipient Lists", "❌", "✔️"),
            _buildFeatureRow("Cloud Backup", "❌", "✔️"),
            _buildFeatureRow("Pause during Calls", "❌", "✔️"),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: GlassTheme.warningOrange, size: 18),
                const SizedBox(width: 6),
                const Text("Trusted by 20,000+ power users", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),

            // Pricing Plans Grid
            Row(
              children: [
                _buildPlanCard(0, "1", "MONTH", "₦4,370.00"),
                const SizedBox(width: 10),
                _buildPlanCard(1, "12", "MONTHS", "₦19,000.00", badge: "SAVE 40%"),
                const SizedBox(width: 10),
                _buildPlanCard(2, "∞", "LIFETIME", "₦29,500.00"),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pro Automation Unlocked!")));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlassTheme.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("CONTINUE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, String freeText, String proText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(feature, style: const TextStyle(color: GlassTheme.textPrimary, fontSize: 13)),
          Row(
            children: [
              SizedBox(width: 60, child: Text(freeText, textAlign: TextAlign.center, style: const TextStyle(color: GlassTheme.textMuted, fontSize: 12))),
              SizedBox(width: 80, child: Text(proText, textAlign: TextAlign.center, style: const TextStyle(color: GlassTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int index, String duration, String label, String price, {String? badge}) {
    final isSelected = _selectedPlan == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPlan = index),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GlassContainer(
              height: 120,
              padding: const EdgeInsets.all(10),
              color: isSelected ? GlassTheme.accentBlue.withOpacity(0.3) : GlassTheme.glassFill,
              borderColor: isSelected ? GlassTheme.accentBlue : GlassTheme.glassBorder,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(duration, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(label, style: const TextStyle(color: GlassTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(price, style: const TextStyle(color: GlassTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: -10,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: GlassTheme.accentBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics & Insights"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    height: 110,
                    color: GlassTheme.primaryEmerald.withOpacity(0.15),
                    borderColor: GlassTheme.primaryEmerald,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TOTAL SENT", style: TextStyle(color: GlassTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text("1,428", style: TextStyle(color: GlassTheme.primaryNeon, fontSize: 26, fontWeight: FontWeight.bold)),
                        Text("+18% this week", style: TextStyle(color: GlassTheme.primaryEmerald, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GlassContainer(
                    height: 110,
                    color: GlassTheme.accentBlue.withOpacity(0.15),
                    borderColor: GlassTheme.accentBlue,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("DELIVERY RATE", style: TextStyle(color: GlassTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text("99.4%", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        Text("High precision", style: TextStyle(color: GlassTheme.accentBlue, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GlassContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Heatmap Trends", style: TextStyle(color: GlassTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text("Peak message dispatch hours", style: TextStyle(color: GlassTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (i) {
                      final heights = [40.0, 70.0, 55.0, 90.0, 110.0, 85.0, 60.0];
                      final days = ["M", "T", "W", "T", "F", "S", "S"];
                      return Column(
                        children: [
                          Container(
                            height: heights[i],
                            width: 24,
                            decoration: BoxDecoration(
                              color: i == 4 ? GlassTheme.primaryNeon : GlassTheme.primaryEmerald.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(days[i], style: const TextStyle(color: GlassTheme.textMuted, fontSize: 12)),
                        ],
                      );
                    }),
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

import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import 'glass_container.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime targetTime;

  const CountdownTimerWidget({super.key, required this.targetTime});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final diff = widget.targetTime.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      children: [
        const Text(
          "UP NEXT",
          style: TextStyle(
            color: GlassTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeBox(hours, "HRS"),
            _buildColon(),
            _buildTimeBox(minutes, "MIN"),
            _buildColon(),
            _buildTimeBox(seconds, "SEC"),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBox(String digits, String label) {
    return Column(
      children: [
        GlassContainer(
          borderRadius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: GlassTheme.glassFillLight,
          borderColor: GlassTheme.primaryNeon.withOpacity(0.4),
          child: Text(
            digits,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: GlassTheme.primaryNeon,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: GlassTheme.primaryNeon,
                  blurRadius: 12,
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: GlassTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildColon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        ":",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: GlassTheme.primaryEmerald,
        ),
      ),
    );
  }
}

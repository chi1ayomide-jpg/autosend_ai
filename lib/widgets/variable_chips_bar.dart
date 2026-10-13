import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';
import '../services/variable_service.dart';

/// One-tap variable insert bar
class VariableChipsBar extends StatelessWidget {
  final TextEditingController controller;

  const VariableChipsBar({super.key, required this.controller});

  void _insertTag(String tag) {
    final text = controller.text;
    final selection = controller.selection;

    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, tag);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + tag.length),
      );
    } else {
      controller.text = text + tag;
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: VariableService.availableVariables.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final tag = VariableService.availableVariables[index];
          return ActionChip(
            label: Text(
              "+ $tag",
              style: const TextStyle(
                color: GlassTheme.primaryNeon,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: GlassTheme.primaryEmerald.withOpacity(0.2),
            side: BorderSide(color: GlassTheme.primaryNeon.withOpacity(0.4)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
            onPressed: () => _insertTag(tag),
          );
        },
      ),
    );
  }
}

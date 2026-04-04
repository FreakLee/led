import 'package:flutter/material.dart';
import '../../models/models.dart';

// ── ColorGrid ────────────────────────────────────────────
class ColorGrid extends StatelessWidget {
  final String? selectedId;
  final void Function(String) onSelect;

  const ColorGrid({super.key, this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ColorTheme.all.map((theme) {
          final active = theme.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(theme.id),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                // Bug 1 修复：LinearGradient 要求 >= 2 个颜色
                // 单色主题用 color，多色才用 gradient
                color: theme.isGradient ? null : theme.singleColor,
                gradient: theme.isGradient ? theme.gradient : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? Colors.white : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── EffectChips ──────────────────────────────────────────
class EffectChips extends StatelessWidget {
  final String? selectedId;
  final void Function(String) onSelect;

  const EffectChips({super.key, this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: LEDEffect.all.map((effect) {
          final active = effect.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(effect.id),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF1E1040)
                    : const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFF222222),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(effect.icon,
                      size: 12,
                      color: active
                          ? const Color(0xFFC4B5FD)
                          : Colors.grey),
                  const SizedBox(width: 4),
                  Text(effect.name,
                      style: TextStyle(
                          fontSize: 12,
                          color: active
                              ? const Color(0xFFC4B5FD)
                              : Colors.grey)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';

import '../../../../core/extensions/context_theme.dart';

class ThemeModeTile extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const ThemeModeTile({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.themeMode,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.themeModeDescription,
                  style: text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          _ThemeSwitch(isDarkMode: isDarkMode, onToggle: onToggle),
        ],
      ),
    );
  }
}

class _ThemeSwitch extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const _ThemeSwitch({required this.isDarkMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? [
                      colors.onSurface.withAlpha(229),
                      colors.onSurface.withAlpha(178),
                    ]
                    : [colors.primary, colors.primary.withAlpha(217)],
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              left: isDarkMode ? 26 : 2,
              top: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(38),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 14,
                  color: isDarkMode ? colors.onSurface : colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

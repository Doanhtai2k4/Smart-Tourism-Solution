import 'package:flutter/material.dart';

class StepTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const StepTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.primary.withAlpha(31),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: cs.primary),
        ),
        const SizedBox(height: 16),
        Text(title, style: textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: textTheme.bodyMedium),
      ],
    );
  }
}

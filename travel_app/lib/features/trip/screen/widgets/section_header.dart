import 'package:flutter/material.dart';
import 'package:travel_app/core/extensions/context_theme.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.colors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.primary.withAlpha(26),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: context.colors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_l10n.dart';
import '../../../../core/extensions/context_theme.dart';

class MarkVisitedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isVisited;

  const MarkVisitedButton({
    super.key,
    required this.onPressed,
    required this.isVisited,
  });

  @override
  Widget build(BuildContext context) {
    if (isVisited) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.check_circle_outline),
        label: Text(
          context.l10n.mark_as_visited,
          style: context.text.titleSmall,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

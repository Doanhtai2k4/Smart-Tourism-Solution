import 'package:flutter/material.dart';

import '../extensions/context_theme.dart';

enum SnackType { success, error, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
  }) {
    final cs = context.colors;

    late Color backgroundColor;
    late Color foregroundColor;
    late IconData icon;

    switch (type) {
      case SnackType.success:
        backgroundColor = cs.primary;
        foregroundColor = cs.onPrimary;
        icon = Icons.check_circle_outline;
        break;

      case SnackType.error:
        backgroundColor = cs.error;
        foregroundColor = cs.onError;
        icon = Icons.error_outline;
        break;

      case SnackType.info:
        backgroundColor = cs.surfaceContainerHighest;
        foregroundColor = cs.onSurfaceVariant;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Icon(icon, color: foregroundColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: context.text.bodyMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

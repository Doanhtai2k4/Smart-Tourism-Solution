import 'package:flutter/material.dart';

import '../extensions/context_theme.dart';

class AppDialog {
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(title, style: context.text.titleLarge),
            content: Text(message, style: context.text.bodyMedium),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(
                      dialogContext,
                      rootNavigator: true,
                    ).pop(false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(
                      dialogContext,
                      rootNavigator: true,
                    ).pop(true),
                style:
                    destructive
                        ? TextButton.styleFrom(
                          backgroundColor: context.colors.error.withAlpha(25),
                        )
                        : null,
                child: Text(
                  confirmText,
                  style: TextStyle(
                    color:
                        destructive
                            ? context.colors.error
                            : context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  static Future<bool?> destructive(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.error.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: context.colors.error),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurface.withAlpha(178),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            () => Navigator.of(
                              dialogContext,
                              rootNavigator: true,
                            ).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: context.colors.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: context.text.labelLarge?.copyWith(
                            color: context.colors.onSurface.withAlpha(178),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            () => Navigator.of(
                              dialogContext,
                              rootNavigator: true,
                            ).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: context.colors.error,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: context.text.labelLarge?.copyWith(
                            color: context.colors.onError,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}

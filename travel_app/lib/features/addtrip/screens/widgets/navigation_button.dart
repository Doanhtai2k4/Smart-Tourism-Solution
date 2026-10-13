import 'package:flutter/material.dart';
import '../../../../core/extensions/context_theme.dart';

class NavigationButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSecondary;
  final IconData? icon;
  final bool isLoading;

  const NavigationButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: !isSecondary && !isLoading ? LinearGradient(
          colors: [cs.primary, context.colors.primary.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        boxShadow: !isSecondary && !isLoading ? [
          BoxShadow(
            color: cs.primary.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isSecondary ? context.colors.surfaceContainerHighest : (isLoading ? cs.primary.withAlpha(150) : Colors.transparent),
          foregroundColor: isSecondary ? cs.onSurface : Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading 
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(label, style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSecondary ? cs.onSurface : Colors.white,
                    )),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 20),
                ],
              ],
            ),
      ),
    );
  }
}

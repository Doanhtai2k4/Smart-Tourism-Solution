import 'package:flutter/material.dart';
import 'package:travel_app/core/extensions/context_theme.dart';

class SelectionCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? description;

  const SelectionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.description,
  });

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final theme = context.theme;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isSelected ? cs.primary.withAlpha(25) : cs.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected ? cs.primary : cs.outlineVariant.withAlpha(40),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected 
                    ? cs.primary.withAlpha(40) 
                    : cs.shadow.withAlpha(10),
                blurRadius: widget.isSelected ? 16 : 8,
                offset: widget.isSelected ? const Offset(0, 6) : const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isSelected ? cs.primary : cs.surfaceContainerHigh,
                  shape: BoxShape.circle,
                  boxShadow: widget.isSelected ? [
                    BoxShadow(
                      color: cs.primary.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ] : null,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected ? Colors.white : cs.onSurfaceVariant,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w600,
                  color: widget.isSelected ? cs.primary : cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.description!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_theme.dart';

class StepperHeader extends StatelessWidget {
  final double progress;
  final String stepText;
  final String stepTitle;

  const StepperHeader({
    super.key,
    required this.progress,
    required this.stepText,
    required this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      color: cs.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepIcon(context, 0, Icons.location_on_outlined),
              _buildConnector(context, 0),
              _buildStepIcon(context, 1, Icons.calendar_today_outlined),
              _buildConnector(context, 1),
              _buildStepIcon(context, 2, Icons.favorite_outline),
              _buildConnector(context, 2),
              _buildStepIcon(context, 3, Icons.tune_outlined),
              _buildConnector(context, 3),
              _buildStepIcon(context, 4, Icons.assignment_turned_in_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stepText,
                  style: context.text.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                stepTitle,
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(BuildContext context, int index, IconData icon) {
    final cs = context.colors;
    // progress is 1/5, 2/5, etc.
    final currentIdx = (progress * 5).round() - 1;
    final isActive = currentIdx == index;
    final isCompleted = currentIdx > index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive 
          ? cs.primary 
          : (isCompleted ? cs.primary.withAlpha(50) : cs.surfaceContainerHighest),
        shape: BoxShape.circle,
        boxShadow: isActive ? [
          BoxShadow(
            color: cs.primary.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
        border: Border.all(
          color: isActive ? cs.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Icon(
        isCompleted ? Icons.check : icon,
        size: 18,
        color: isActive ? Colors.white : (isCompleted ? cs.primary : cs.onSurfaceVariant),
      ),
    );
  }

  Widget _buildConnector(BuildContext context, int index) {
    final cs = context.colors;
    final currentIdx = (progress * 5).round() - 1;
    final isCompleted = currentIdx > index;

    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isCompleted ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

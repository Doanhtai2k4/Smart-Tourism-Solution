import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/features/addtrip/screens/trip_creation_data.dart';
import 'package:travel_app/features/addtrip/screens/widgets/step_title.dart';
import 'package:travel_app/core/enums/trip_type.dart';
import 'package:travel_app/core/enums/budget_type.dart';
import 'package:travel_app/core/enums/currency.dart';

class SummaryStep extends StatelessWidget {
  final TripCreationData data;

  const SummaryStep({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(
            icon: Icons.assignment_turned_in_outlined,
            title: l10n.tripsSummary,
            subtitle: l10n.creatingPerfectTrip,
          ),
          const SizedBox(height: 32),

          _buildSummaryCard(
            context,
            icon: Icons.place_outlined,
            title: l10n.destination,
            content: '${data.destination.text}\n${l10n.from}: ${data.currentLocation.text}',
            tag: data.tripType?.label(context) ?? '',
          ),
          const SizedBox(height: 16),

          _buildSummaryCard(
            context,
            icon: Icons.calendar_month_outlined,
            title: l10n.travelDates,
            content: data.startDate != null && data.endDate != null
                ? '${DateFormat.yMMMd().format(data.startDate!)} - ${DateFormat.yMMMd().format(data.endDate!)}'
                : '',
            tag: data.startDate != null && data.endDate != null
                ? '${data.endDate!.difference(data.startDate!).inDays + 1} ${l10n.days}'
                : '',
          ),
          const SizedBox(height: 16),

          _buildSummaryCard(
            context,
            icon: Icons.attach_money_outlined,
            title: l10n.budget,
            content: '${data.budget.text} ${data.currency.label}',
            tag: data.budgetType.label(context),
          ),
          const SizedBox(height: 24),

          Text(
            l10n.preferences,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPreferenceChip(context, Icons.people_outline, data.companion),
              _buildPreferenceChip(context, Icons.hotel_outlined, data.accommodation),
              _buildPreferenceChip(context, Icons.speed_outlined, data.pace),
              _buildPreferenceChip(context, Icons.restaurant_outlined, data.food),
              ...data.interests.map((interest) => 
                _buildPreferenceChip(context, Icons.star_outline, interest)),
            ],
          ),
          const SizedBox(height: 80), // Space for navigation buttons
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required String tag,
  }) {
    final cs = context.colors;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: context.text.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (tag.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: context.text.labelSmall?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceChip(BuildContext context, IconData icon, String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

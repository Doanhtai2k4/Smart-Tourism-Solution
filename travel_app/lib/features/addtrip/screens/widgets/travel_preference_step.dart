import 'package:flutter/material.dart';
import 'package:travel_app/features/addtrip/screens/widgets/step_title.dart';

import '../../../../core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';

class TravelPreferencesStep extends StatelessWidget {
  final String accommodation;
  final ValueChanged<String> onAccommodationChanged;
  final String transport;
  final ValueChanged<String> onTransportChanged;
  final String pace;
  final ValueChanged<String> onPaceChanged;
  final String food;
  final ValueChanged<String> onFoodChanged;

  const TravelPreferencesStep({
    super.key,
    required this.accommodation,
    required this.onAccommodationChanged,
    required this.transport,
    required this.onTransportChanged,
    required this.pace,
    required this.onPaceChanged,
    required this.food,
    required this.onFoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(
            icon: Icons.tune_outlined,
            title: l10n.travel_preferences_title,
            subtitle: l10n.travel_preferences_subtitle,
          ),
          const SizedBox(height: 32),

          _buildSegmentedSelection(
            context,
            label: l10n.accommodation,
            icon: Icons.hotel_outlined,
            value: accommodation,
            options: [
              l10n.accommodation_hotel,
              l10n.accommodation_hostel,
              l10n.accommodation_airbnb,
              l10n.accommodation_resort,
              l10n.accommodation_camping,
            ],
            onChanged: onAccommodationChanged,
          ),
          const SizedBox(height: 24),

          _buildSegmentedSelection(
            context,
            label: l10n.transportation,
            icon: Icons.directions_car_outlined,
            value: transport,
            options: [
              l10n.transport_public,
              l10n.transport_rental,
              l10n.transport_taxi,
              l10n.transport_walking,
              l10n.transport_bicycle,
            ],
            onChanged: onTransportChanged,
          ),
          const SizedBox(height: 24),

          _buildSegmentedSelection(
            context,
            label: l10n.trip_pace,
            icon: Icons.speed_outlined,
            value: pace,
            options: [l10n.pace_relaxed, l10n.pace_moderate, l10n.pace_fast],
            onChanged: onPaceChanged,
          ),
          const SizedBox(height: 24),

          _buildSegmentedSelection(
            context,
            label: l10n.food_preference,
            icon: Icons.restaurant_menu_outlined,
            value: food,
            options: [
              l10n.food_local,
              l10n.food_vegetarian,
              l10n.food_vegan,
              l10n.food_fast_food,
              l10n.food_fine_dining,
            ],
            onChanged: onFoodChanged,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSegmentedSelection(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    final cs = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = value == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onChanged(option),
              selectedColor: cs.primary.withAlpha(40),
              labelStyle: context.text.labelMedium?.copyWith(
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              showCheckmark: false,
              side: BorderSide(
                color: isSelected ? cs.primary : cs.outlineVariant.withAlpha(50),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

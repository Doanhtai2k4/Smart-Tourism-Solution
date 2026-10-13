import 'package:flutter/material.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/features/trip/screen/widgets/section_header.dart';
import 'package:travel_app/shared/models/travel_db_model.dart';

class UserPreferencesSection extends StatelessWidget {
  final TravelDbModel trip;

  const UserPreferencesSection({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    // Collect all valid preferences
    final prefs = <_PreferenceItem>[];

    if (trip.companions?.isNotEmpty ?? false) {
      prefs.add(_PreferenceItem(
        icon: Icons.people_outline,
        label: context.l10n.traveling_with,
        value: trip.companions!,
      ));
    }

    if (trip.pace?.isNotEmpty ?? false) {
      prefs.add(_PreferenceItem(
        icon: Icons.speed_outlined,
        label: context.l10n.trip_pace,
        value: trip.pace!,
      ));
    }

    if (trip.foodPreference?.isNotEmpty ?? false) {
      prefs.add(_PreferenceItem(
        icon: Icons.restaurant_outlined,
        label: context.l10n.food_preference,
        value: trip.foodPreference!,
      ));
    }

    if (trip.accommodationType?.isNotEmpty ?? false) {
      prefs.add(_PreferenceItem(
        icon: Icons.hotel_outlined,
        label: context.l10n.accommodation,
        value: trip.accommodationType!,
      ));
    }

    if (trip.transportPreferences?.isNotEmpty ?? false) {
      prefs.add(_PreferenceItem(
        icon: Icons.directions_car_outlined,
        label: context.l10n.transportation,
        value: trip.transportPreferences!,
      ));
    }

    if (prefs.isEmpty && trip.interests.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SectionHeader(
            icon: Icons.auto_awesome_outlined,
            title: context.l10n.tripsSummary,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ...prefs.map((p) => _PreferenceCard(item: p)),
            ],
          ),
        ),
        if (trip.interests.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trip.interests.map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withAlpha(51),
                    ),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

class _PreferenceItem {
  final IconData icon;
  final String label;
  final String value;

  _PreferenceItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _PreferenceCard extends StatelessWidget {
  final _PreferenceItem item;

  const _PreferenceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

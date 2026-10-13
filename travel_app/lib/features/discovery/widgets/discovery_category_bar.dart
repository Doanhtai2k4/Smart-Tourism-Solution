import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/features/search/providers/search_filter_provider.dart';
import 'package:travel_app/core/services/tracking_service.dart';


class DiscoveryCategoryBar extends ConsumerWidget {
  const DiscoveryCategoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFilterProvider);
    final selectedCategories = filters.selectedCategories;
    final cs = context.colors;

    final categories = [
      {'id': 'all', 'label': context.l10n.all, 'icon': Icons.explore_rounded},
      {'id': 'Biển', 'label': context.l10n.cat_beach, 'icon': Icons.beach_access_rounded},
      {'id': 'Núi', 'label': context.l10n.cat_mountain, 'icon': Icons.terrain_rounded},
      {'id': 'Thành phố', 'label': context.l10n.cat_city, 'icon': Icons.location_city_rounded},
      {'id': 'Văn hóa', 'label': context.l10n.cat_culture, 'icon': Icons.museum_rounded},
      {'id': 'Nghỉ dưỡng', 'label': context.l10n.cat_resort, 'icon': Icons.spa_rounded},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final id = cat['id'] as String;
          final isSelected = id == 'all' 
              ? selectedCategories.isEmpty 
              : selectedCategories.contains(id);

          return GestureDetector(
            onTap: () {
              if (id == 'all') {
                ref.read(searchFilterProvider.notifier).clearFilters();
              } else {
                ref.read(searchFilterProvider.notifier).toggleCategory(id);
                // Track category selection for ML
                ref.read(trackingServiceProvider).trackFilterCategory(id);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outlineVariant.withAlpha(80),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: cs.primary.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ] : [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                   Icon(
                    cat['icon'] as IconData,
                    size: 18,
                    color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat['label'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

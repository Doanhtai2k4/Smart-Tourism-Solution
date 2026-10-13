import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/features/search/providers/search_filter_provider.dart';

class ActiveFiltersHeader extends ConsumerWidget {
  const ActiveFiltersHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);
    final notifier = ref.read(searchFilterProvider.notifier);
    
    if (!filter.isAnyFilterActive) return const SizedBox.shrink();

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Clear All Action
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => notifier.clearFilters(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withAlpha(50), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 14, color: Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.clear_filters_short,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Mapping ALL active criteria
          ...filter.selectedCategories.map((c) => _buildFilterChip(_getLocalizedLabel(context, c), () => notifier.toggleCategory(c))),
          ...filter.selectedBudgets.map((b) => _buildFilterChip(_getLocalizedLabel(context, b), () => notifier.toggleBudget(b))),
          ...filter.selectedSeasons.map((s) => _buildFilterChip(_getLocalizedLabel(context, s), () => notifier.toggleSeason(s))),
          ...filter.selectedSuitableFor.map((f) => _buildFilterChip(_getLocalizedLabel(context, f), () => notifier.toggleSuitableFor(f))),
          
          if (filter.maxDuration < 14)
            _buildFilterChip(
              context.l10n.days_count(filter.maxDuration), 
              () => notifier.setMaxDuration(14)
            ),
        ],
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, String value) {
    final l10n = context.l10n;
    switch (value) {
      case 'Biển': return l10n.cat_beach;
      case 'Núi': return l10n.cat_mountain;
      case 'Thành phố': return l10n.cat_city;
      case 'Văn hóa': return l10n.cat_culture;
      case 'Giá rẻ': return l10n.budget_cheap;
      case 'Trung bình': return l10n.budget_medium;
      case 'Cao cấp': return l10n.budget_luxury;
      case 'Gia đình': return l10n.family;
      case 'Cặp đôi': return l10n.couple;
      case 'Nhóm bạn': return l10n.friends;
      case 'Solo': return l10n.solo;
      case 'Xuân': return l10n.spring;
      case 'Hạ': return l10n.summer;
      case 'Thu': return l10n.autumn;
      case 'Đông': return l10n.winter;
      default: return value;
    }
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text(label, style: GoogleFonts.beVietnamPro(fontSize: 12)),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 14),
        backgroundColor: Colors.blue.withAlpha(20),
        labelStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        side: const BorderSide(color: Colors.blue, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/features/search/providers/search_filter_provider.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider);
    final notifier = ref.read(searchFilterProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ).createShader(bounds),
                child: Text(
                  context.l10n.advanced_filters,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  _buildSectionHeader(context, context.l10n.place_categories),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Biển', 'Núi', 'Thành phố', 'Văn hóa'].map((c) {
                      final isSelected = filter.selectedCategories.contains(c);
                      return _buildFilterChip(
                        label: _getLocalizedLabel(context, c),
                        selected: isSelected,
                        onSelected: (_) => notifier.toggleCategory(c),
                        context: context,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Budget Level
                  _buildSectionHeader(context, context.l10n.budget_level_title),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Giá rẻ', 'Trung bình', 'Cao cấp'].map((b) {
                      final isSelected = filter.selectedBudgets.contains(b);
                      return _buildFilterChip(
                        label: _getLocalizedLabel(context, b),
                        selected: isSelected,
                        onSelected: (_) => notifier.toggleBudget(b),
                        context: context,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Suitable For
                  _buildSectionHeader(context, context.l10n.suitable_for_title),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Gia đình', 'Cặp đôi', 'Nhóm bạn', 'Solo'].map((f) {
                      final isSelected = filter.selectedSuitableFor.contains(f);
                      return _buildFilterChip(
                        label: _getLocalizedLabel(context, f),
                        selected: isSelected,
                        onSelected: (_) => notifier.toggleSuitableFor(f),
                        context: context,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Seasons
                  _buildSectionHeader(context, context.l10n.travel_season_title),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ['Xuân', 'Hạ', 'Thu', 'Đông'].map((s) {
                      final isSelected = filter.selectedSeasons.contains(s);
                      return _buildFilterChip(
                        label: _getLocalizedLabel(context, s),
                        selected: isSelected,
                        onSelected: (_) => notifier.toggleSeason(s),
                        context: context,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Duration Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader(context, context.l10n.max_stay),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          context.l10n.days_count(filter.maxDuration),
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.blue.withAlpha(25),
                      thumbColor: Colors.blue,
                      overlayColor: Colors.blue.withAlpha(50),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: filter.maxDuration.toDouble(),
                      min: 1,
                      max: 14,
                      divisions: 13,
                      onChanged: (val) => notifier.setMaxDuration(val.toInt()),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => notifier.clearFilters(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: context.colors.outlineVariant),
                    ),
                    child: Text(
                      context.l10n.reset,
                      style: GoogleFonts.beVietnamPro(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withAlpha(76),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        context.l10n.apply,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.beVietnamPro(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: context.colors.onSurface,
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, String value) {
    final l10n = context.l10n;
    switch (value) {
      case 'Biển':
        return l10n.cat_beach;
      case 'Núi':
        return l10n.cat_mountain;
      case 'Thành phố':
        return l10n.cat_city;
      case 'Văn hóa':
        return l10n.cat_culture;
      case 'Giá rẻ':
        return l10n.budget_cheap;
      case 'Trung bình':
        return l10n.budget_medium;
      case 'Cao cấp':
        return l10n.budget_luxury;
      case 'Gia đình':
        return l10n.family;
      case 'Cặp đôi':
        return l10n.couple;
      case 'Nhóm bạn':
        return l10n.friends;
      case 'Solo':
        return l10n.solo;
      case 'Xuân':
        return l10n.spring;
      case 'Hạ':
        return l10n.summer;
      case 'Thu':
        return l10n.autumn;
      case 'Đông':
        return l10n.winter;
      default:
        return value;
    }
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
    required BuildContext context,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.beVietnamPro(
          color: selected ? Colors.white : context.colors.onSurface,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: context.colors.surfaceContainerHighest,
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      showCheckmark: true,
      elevation: selected ? 4 : 0,
    );
  }
}

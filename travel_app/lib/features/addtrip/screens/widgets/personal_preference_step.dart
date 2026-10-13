import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/features/addtrip/screens/widgets/selectable_chip.dart';
import 'package:travel_app/features/addtrip/screens/widgets/selection_card.dart';
import 'package:travel_app/features/addtrip/screens/widgets/step_title.dart';
import 'package:travel_app/features/discovery/repositories/recommendation_repository.dart';
import '../../../../shared/models/destination_model.dart';
import 'input_label.dart';

class PersonalPreferencesStep extends ConsumerWidget {
  final List<String> selectedInterests;
  final ValueChanged<List<String>> onInterestsChanged;
  final String selectedCompanion;
  final ValueChanged<String> onCompanionChanged;
  final TextEditingController specialRequirementsController;
  final List<String> mustVisitPlaceIds;
  final ValueChanged<List<String>> onMustVisitPlaceIdsChanged;
  final String selectedDestination;

  const PersonalPreferencesStep({
    super.key,
    required this.selectedInterests,
    required this.onInterestsChanged,
    required this.selectedCompanion,
    required this.onCompanionChanged,
    required this.specialRequirementsController,
    required this.mustVisitPlaceIds,
    required this.onMustVisitPlaceIdsChanged,
    required this.selectedDestination,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final interestsOptions = [
      (l10n.interest_nature, Icons.forest_outlined),
      (l10n.interest_history, Icons.museum_outlined),
      (l10n.interest_adventure, Icons.hiking_outlined),
      (l10n.interest_shopping, Icons.shopping_bag_outlined),
      (l10n.interest_food, Icons.restaurant_outlined),
      (l10n.interest_art, Icons.palette_outlined),
    ];

    final companionOptions = [
      (l10n.companion_solo, Icons.person_outline),
      (l10n.companion_partner, Icons.favorite_outline),
      (l10n.companion_family, Icons.family_restroom_outlined),
      (l10n.companion_friends, Icons.groups_outlined),
    ];

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(
            icon: Icons.favorite_outline,
            title: l10n.personal_preferences_title,
            subtitle: l10n.personal_preferences_subtitle,
          ),
          const SizedBox(height: 32),

          InputLabel(text: l10n.traveling_with),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: companionOptions.map((option) {
              final label = option.$1;
              final icon = option.$2;
              final isSelected = selectedCompanion == label;

              return SelectionCard(
                label: label,
                icon: icon,
                isSelected: isSelected,
                onTap: () => onCompanionChanged(label),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          InputLabel(text: l10n.interests),
          const SizedBox(height: 4),
          Text(l10n.select_all_that_apply, style: theme.textTheme.labelSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                interestsOptions.map((option) {
                  final label = option.$1;
                  final icon = option.$2;
                  final isSelected = selectedInterests.contains(label);

                    return SelectableChip(
                    label: label,
                    icon: icon,
                    isSelected: isSelected,
                    onTap: () {
                      final updated = List<String>.from(selectedInterests);
                      isSelected ? updated.remove(label) : updated.add(label);
                      onInterestsChanged(updated);
                    },
                  );
                }).toList(),
          ),

          const SizedBox(height: 32),

          InputLabel(text: l10n.special_requirements_label),
          const SizedBox(height: 12),
          TextFormField(
            controller: specialRequirementsController,
            maxLines: 3,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: l10n.special_requirements_hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor.withAlpha(120),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
              contentPadding: const EdgeInsets.all(20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (mustVisitPlaceIds.isNotEmpty)
                        BoxShadow(
                          color: theme.primaryColor.withAlpha(50),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (selectedDestination.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.error_select_destination_first,
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      _showMustVisitPicker(context, ref);
                    },
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: Text(
                      mustVisitPlaceIds.isEmpty
                          ? l10n.add_must_visit_label
                          : l10n.places_selected(mustVisitPlaceIds.length),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color:
                            mustVisitPlaceIds.isEmpty
                                ? theme.primaryColor.withAlpha(80)
                                : theme.primaryColor,
                        width: mustVisitPlaceIds.isEmpty ? 1.5 : 2.5,
                      ),
                      backgroundColor:
                          mustVisitPlaceIds.isNotEmpty
                              ? theme.primaryColor.withAlpha(15)
                              : Colors.transparent,
                    ),
                  ),
                ),
              ),
              if (mustVisitPlaceIds.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => onMustVisitPlaceIdsChanged([]),
                  icon: const Icon(Icons.close),
                  tooltip: l10n.clear_all_selection,
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(56, 56),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showMustVisitPicker(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // BƯỚC 1: Khởi tạo mảng tạm thời bên ngoài StatefulBuilder
    final tempSelectedIds = Set<String>.from(mustVisitPlaceIds);

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.select_must_visit_title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              l10n.at_destination_context(selectedDestination),
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: FutureBuilder<List<DestinationModel>>(
                    future: ref
                        .read(recommendationRepositoryProvider)
                        .getCatalogDestinations(limit: 500),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("${l10n.error}: ${snapshot.error}"));
                      }

                      final allPlaces = snapshot.data ?? [];
                      final filteredPlaces =
                          allPlaces.where((p) {
                            final prov = p.province?.toLowerCase() ?? '';
                            final dest = selectedDestination.toLowerCase();
                            return prov.contains(dest) || dest.contains(prov);
                          }).toList();

                      if (filteredPlaces.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 64,
                                color: theme.disabledColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Chưa có địa điểm nào được cập nhật\ntại $selectedDestination", // Should ideally be localized too if possible, but keep for now or add key
                                textAlign: TextAlign.center,
                                style: TextStyle(color: theme.disabledColor),
                              ),
                            ],
                          ),
                        );
                      }

                      // BƯỚC 2: Sử dụng StatefulBuilder với setModalState
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredPlaces.length,
                                  itemBuilder: (context, index) {
                                    final place = filteredPlaces[index];
                                    final isSelected = tempSelectedIds.contains(
                                      place.id,
                                    );

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color:
                                              isSelected
                                                  ? theme.primaryColor
                                                  : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: CheckboxListTile(
                                        value: isSelected,
                                        onChanged: (val) {
                                          // Cập nhật trạng thái cục bộ của BottomSheet
                                          setModalState(() {
                                            if (val == true) {
                                              tempSelectedIds.add(place.id);
                                            } else {
                                              tempSelectedIds.remove(place.id);
                                            }
                                          });
                                        },
                                        title: Text(
                                          place.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          place.category ?? "Địa điểm",
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        secondary: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                place.images.isNotEmpty
                                                    ? place.images.first
                                                    : 'https://images.unsplash.com/photo-1503220317375-aaad61436b1b',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // BƯỚC 3: Trả về dữ liệu thông qua Navigator.pop
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      tempSelectedIds.toList(),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 56),
                                    backgroundColor: theme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.confirm_with_count(tempSelectedIds.length),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );

    // Cập nhật trạng thái ở Form cha sau khi BottomSheet đóng
    if (result != null) {
      onMustVisitPlaceIdsChanged(result);
    }
  }
}

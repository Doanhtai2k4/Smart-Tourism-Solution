import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:travel_app/features/discovery/providers/discovery_providers.dart';
import 'package:travel_app/shared/models/destination_model.dart';

part 'search_filter_provider.g.dart';

class FilterCriteria extends Equatable {
  final String searchQuery;
  final List<String> selectedCategories;
  final List<String> selectedBudgets;
  final List<String> selectedSeasons;
  final List<String> selectedSuitableFor;
  final int maxDuration;

  const FilterCriteria({
    this.searchQuery = '',
    this.selectedCategories = const [],
    this.selectedBudgets = const [],
    this.selectedSeasons = const [],
    this.selectedSuitableFor = const [],
    this.maxDuration = 14, // Mặc định 14 ngày (không filter gì khi khởi động)
  });

  FilterCriteria copyWith({
    String? searchQuery,
    List<String>? selectedCategories,
    List<String>? selectedBudgets,
    List<String>? selectedSeasons,
    List<String>? selectedSuitableFor,
    int? maxDuration,
  }) {
    return FilterCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedBudgets: selectedBudgets ?? this.selectedBudgets,
      selectedSeasons: selectedSeasons ?? this.selectedSeasons,
      selectedSuitableFor: selectedSuitableFor ?? this.selectedSuitableFor,
      maxDuration: maxDuration ?? this.maxDuration,
    );
  }

  bool get isAnyFilterActive =>
      selectedCategories.isNotEmpty ||
      selectedBudgets.isNotEmpty ||
      selectedSeasons.isNotEmpty ||
      selectedSuitableFor.isNotEmpty ||
      maxDuration < 14;

  bool get isQuerying => searchQuery.isNotEmpty;

  bool get hasActiveSearch => isAnyFilterActive || isQuerying;

  @override
  List<Object?> get props => [
        searchQuery,
        selectedCategories,
        selectedBudgets,
        selectedSeasons,
        selectedSuitableFor,
        maxDuration,
      ];
}

@riverpod
class SearchFilter extends _$SearchFilter {
  @override
  FilterCriteria build() {
    return const FilterCriteria();
  }

  void updateQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleCategory(String category) {
    final categories = List<String>.from(state.selectedCategories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    state = state.copyWith(selectedCategories: categories);
  }

  void toggleBudget(String budget) {
    final budgets = List<String>.from(state.selectedBudgets);
    if (budgets.contains(budget)) {
      budgets.remove(budget);
    } else {
      budgets.add(budget);
    }
    state = state.copyWith(selectedBudgets: budgets);
  }

  void toggleSeason(String season) {
    final seasons = List<String>.from(state.selectedSeasons);
    if (seasons.contains(season)) {
      seasons.remove(season);
    } else {
      seasons.add(season);
    }
    state = state.copyWith(selectedSeasons: seasons);
  }

  void toggleSuitableFor(String suitable) {
    final suitableList = List<String>.from(state.selectedSuitableFor);
    if (suitableList.contains(suitable)) {
      suitableList.remove(suitable);
    } else {
      suitableList.add(suitable);
    }
    state = state.copyWith(selectedSuitableFor: suitableList);
  }

  void setMaxDuration(int duration) {
    state = state.copyWith(maxDuration: duration);
  }

  void clearQuery() {
    state = state.copyWith(searchQuery: '');
  }

  void clearFilters() {
    state = FilterCriteria(
      searchQuery: state.searchQuery,
      maxDuration: 14, // Reset về default
    );
  }

  void resetAll() {
    state = const FilterCriteria();
  }
}

@riverpod
Future<List<DestinationModel>> destinationSearchResults(Ref ref) async {
  final catalog = await ref.watch(catalogDestinationsProvider.future);
  final filters = ref.watch(searchFilterProvider);

  if (catalog.isEmpty) return [];

  return catalog.where((dest) {
    // 1. Text Search Matching (Name, Province, Category, Tags, Keywords)
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      final inName = dest.name.toLowerCase().contains(query);
      final inProvince = (dest.province ?? '').toLowerCase().contains(query);
      final inCategory = (dest.category ?? '').toLowerCase().contains(query);
      final inTags = dest.tags.any((tag) => tag.toLowerCase().contains(query));
      final inKeywords = dest.searchKeywords.any((kw) => kw.toLowerCase().contains(query));
      
      if (!inName && !inProvince && !inCategory && !inTags && !inKeywords) return false;
    }

    // 2. Filter by Category
    if (filters.selectedCategories.isNotEmpty) {
      if (!filters.selectedCategories.contains(dest.category)) return false;
    }

    // 3. Filter by Budget Level
    if (filters.selectedBudgets.isNotEmpty) {
      if (!filters.selectedBudgets.contains(dest.budgetLevel)) return false;
    }

    // 4. Filter by Season (Best Time To Visit)
    if (filters.selectedSeasons.isNotEmpty) {
      final hasMatchingSeason = dest.bestTimeToVisit.any(
        (season) => filters.selectedSeasons.contains(season)
      );
      final isAllYear = dest.bestTimeToVisit.contains('Quanh năm');
      if (!hasMatchingSeason && !isAllYear) return false;
    }

    // 5. Filter by Suitability (intersection check)
    if (filters.selectedSuitableFor.isNotEmpty) {
      final isSuitable = dest.suitableFor.any(
        (suitable) => filters.selectedSuitableFor.contains(suitable)
      );
      if (!isSuitable) return false;
    }

    // 6. Filter by Duration (idealDuration <= filters.maxDuration)
    final duration = dest.idealDuration ?? 0;
    if (duration > filters.maxDuration) return false;

    return true;
  }).toList();
}

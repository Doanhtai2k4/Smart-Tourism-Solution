// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchFilter)
final searchFilterProvider = SearchFilterProvider._();

final class SearchFilterProvider
    extends $NotifierProvider<SearchFilter, FilterCriteria> {
  SearchFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchFilterHash();

  @$internal
  @override
  SearchFilter create() => SearchFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilterCriteria value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilterCriteria>(value),
    );
  }
}

String _$searchFilterHash() => r'fb6802d53516c4a896041eca81f03933056e7f67';

abstract class _$SearchFilter extends $Notifier<FilterCriteria> {
  FilterCriteria build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FilterCriteria, FilterCriteria>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FilterCriteria, FilterCriteria>,
              FilterCriteria,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(destinationSearchResults)
final destinationSearchResultsProvider = DestinationSearchResultsProvider._();

final class DestinationSearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DestinationModel>>,
          List<DestinationModel>,
          FutureOr<List<DestinationModel>>
        >
    with
        $FutureModifier<List<DestinationModel>>,
        $FutureProvider<List<DestinationModel>> {
  DestinationSearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'destinationSearchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$destinationSearchResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<DestinationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DestinationModel>> create(Ref ref) {
    return destinationSearchResults(ref);
  }
}

String _$destinationSearchResultsHash() =>
    r'ce89ae819177e1f358422d53636f458541f2eeed';

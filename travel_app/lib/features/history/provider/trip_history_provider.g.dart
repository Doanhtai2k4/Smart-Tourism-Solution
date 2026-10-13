// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TripHistoryNotifier)
final tripHistoryProvider = TripHistoryNotifierProvider._();

final class TripHistoryNotifierProvider
    extends $NotifierProvider<TripHistoryNotifier, TripFilter> {
  TripHistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripHistoryNotifierHash();

  @$internal
  @override
  TripHistoryNotifier create() => TripHistoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripFilter>(value),
    );
  }
}

String _$tripHistoryNotifierHash() =>
    r'b82693267ab7112e89f4ec1000b9fc90e511e99e';

abstract class _$TripHistoryNotifier extends $Notifier<TripFilter> {
  TripFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TripFilter, TripFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TripFilter, TripFilter>,
              TripFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(historyTrips)
final historyTripsProvider = HistoryTripsProvider._();

final class HistoryTripsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TravelDbModel>>,
          List<TravelDbModel>,
          Stream<List<TravelDbModel>>
        >
    with
        $FutureModifier<List<TravelDbModel>>,
        $StreamProvider<List<TravelDbModel>> {
  HistoryTripsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyTripsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyTripsHash();

  @$internal
  @override
  $StreamProviderElement<List<TravelDbModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TravelDbModel>> create(Ref ref) {
    return historyTrips(ref);
  }
}

String _$historyTripsHash() => r'e811f87a17e4a0204c5fc17ad2692da9c0632895';

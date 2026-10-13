// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubmitLoading)
final submitLoadingProvider = SubmitLoadingProvider._();

final class SubmitLoadingProvider
    extends $NotifierProvider<SubmitLoading, bool> {
  SubmitLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'submitLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$submitLoadingHash();

  @$internal
  @override
  SubmitLoading create() => SubmitLoading();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$submitLoadingHash() => r'67fca38a8b8813fce3b95a80b78083c51563c22c';

abstract class _$SubmitLoading extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(generateAndStoreTrip)
final generateAndStoreTripProvider = GenerateAndStoreTripFamily._();

final class GenerateAndStoreTripProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  GenerateAndStoreTripProvider._({
    required GenerateAndStoreTripFamily super.from,
    required TripPlanRequest super.argument,
  }) : super(
         retry: null,
         name: r'generateAndStoreTripProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$generateAndStoreTripHash();

  @override
  String toString() {
    return r'generateAndStoreTripProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as TripPlanRequest;
    return generateAndStoreTrip(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GenerateAndStoreTripProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$generateAndStoreTripHash() =>
    r'8be514d4277a4461276cc04a132d9ae0bc26e34c';

final class GenerateAndStoreTripFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, TripPlanRequest> {
  GenerateAndStoreTripFamily._()
    : super(
        retry: null,
        name: r'generateAndStoreTripProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GenerateAndStoreTripProvider call(TripPlanRequest tripPlanRequest) =>
      GenerateAndStoreTripProvider._(argument: tripPlanRequest, from: this);

  @override
  String toString() => r'generateAndStoreTripProvider';
}

@ProviderFor(trendingDestinations)
final trendingDestinationsProvider = TrendingDestinationsProvider._();

final class TrendingDestinationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DestinationModel>>,
          List<DestinationModel>,
          Stream<List<DestinationModel>>
        >
    with
        $FutureModifier<List<DestinationModel>>,
        $StreamProvider<List<DestinationModel>> {
  TrendingDestinationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingDestinationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingDestinationsHash();

  @$internal
  @override
  $StreamProviderElement<List<DestinationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DestinationModel>> create(Ref ref) {
    return trendingDestinations(ref);
  }
}

String _$trendingDestinationsHash() =>
    r'f27ef5ca505b987321064933bea25caaf4859278';

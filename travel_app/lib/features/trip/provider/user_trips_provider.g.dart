// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_trips_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TripStatusNotifier)
final tripStatusProvider = TripStatusNotifierProvider._();

final class TripStatusNotifierProvider
    extends $NotifierProvider<TripStatusNotifier, void> {
  TripStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripStatusNotifierHash();

  @$internal
  @override
  TripStatusNotifier create() => TripStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$tripStatusNotifierHash() =>
    r'b0bc14b9a0b29b2de9831e4e270bd532d95ac9f3';

abstract class _$TripStatusNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(regenerateTripInCurrentLanguage)
final regenerateTripInCurrentLanguageProvider =
    RegenerateTripInCurrentLanguageFamily._();

final class RegenerateTripInCurrentLanguageProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  RegenerateTripInCurrentLanguageProvider._({
    required RegenerateTripInCurrentLanguageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'regenerateTripInCurrentLanguageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$regenerateTripInCurrentLanguageHash();

  @override
  String toString() {
    return r'regenerateTripInCurrentLanguageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return regenerateTripInCurrentLanguage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RegenerateTripInCurrentLanguageProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$regenerateTripInCurrentLanguageHash() =>
    r'4148a6ce7865333667eedb164556d135c29587ae';

final class RegenerateTripInCurrentLanguageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  RegenerateTripInCurrentLanguageFamily._()
    : super(
        retry: null,
        name: r'regenerateTripInCurrentLanguageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RegenerateTripInCurrentLanguageProvider call(String travelId) =>
      RegenerateTripInCurrentLanguageProvider._(argument: travelId, from: this);

  @override
  String toString() => r'regenerateTripInCurrentLanguageProvider';
}

@ProviderFor(userTrips)
final userTripsProvider = UserTripsProvider._();

final class UserTripsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TravelDbModel>>,
          List<TravelDbModel>,
          Stream<List<TravelDbModel>>
        >
    with
        $FutureModifier<List<TravelDbModel>>,
        $StreamProvider<List<TravelDbModel>> {
  UserTripsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userTripsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userTripsHash();

  @$internal
  @override
  $StreamProviderElement<List<TravelDbModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TravelDbModel>> create(Ref ref) {
    return userTrips(ref);
  }
}

String _$userTripsHash() => r'e5d1a69a814b9a0bca173b4d26b795479c24baba';

@ProviderFor(joinedTrips)
final joinedTripsProvider = JoinedTripsProvider._();

final class JoinedTripsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TravelDbModel>>,
          List<TravelDbModel>,
          Stream<List<TravelDbModel>>
        >
    with
        $FutureModifier<List<TravelDbModel>>,
        $StreamProvider<List<TravelDbModel>> {
  JoinedTripsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'joinedTripsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$joinedTripsHash();

  @$internal
  @override
  $StreamProviderElement<List<TravelDbModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TravelDbModel>> create(Ref ref) {
    return joinedTrips(ref);
  }
}

String _$joinedTripsHash() => r'4ae2d7b9e9be46f2a72deaadd01ec32a96dd4bc8';

@ProviderFor(tripById)
final tripByIdProvider = TripByIdFamily._();

final class TripByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<TravelDbModel>,
          TravelDbModel,
          FutureOr<TravelDbModel>
        >
    with $FutureModifier<TravelDbModel>, $FutureProvider<TravelDbModel> {
  TripByIdProvider._({
    required TripByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripByIdHash();

  @override
  String toString() {
    return r'tripByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TravelDbModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TravelDbModel> create(Ref ref) {
    final argument = this.argument as String;
    return tripById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripByIdHash() => r'8ea0316a59b50b2d2c794c7ea0410d5baec5f6a7';

final class TripByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TravelDbModel>, String> {
  TripByIdFamily._()
    : super(
        retry: null,
        name: r'tripByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripByIdProvider call(String travelId) =>
      TripByIdProvider._(argument: travelId, from: this);

  @override
  String toString() => r'tripByIdProvider';
}

@ProviderFor(deleteTrip)
final deleteTripProvider = DeleteTripFamily._();

final class DeleteTripProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  DeleteTripProvider._({
    required DeleteTripFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteTripProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteTripHash();

  @override
  String toString() {
    return r'deleteTripProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return deleteTrip(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteTripProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteTripHash() => r'83d0087b80d8e396ea1bc7acf115892c3d931b09';

final class DeleteTripFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  DeleteTripFamily._()
    : super(
        retry: null,
        name: r'deleteTripProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteTripProvider call(String travelId) =>
      DeleteTripProvider._(argument: travelId, from: this);

  @override
  String toString() => r'deleteTripProvider';
}

@ProviderFor(monthTripCount)
final monthTripCountProvider = MonthTripCountProvider._();

final class MonthTripCountProvider
    extends
        $FunctionalProvider<
          AsyncValue<MonthTripCount>,
          AsyncValue<MonthTripCount>,
          AsyncValue<MonthTripCount>
        >
    with $Provider<AsyncValue<MonthTripCount>> {
  MonthTripCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthTripCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthTripCountHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<MonthTripCount>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<MonthTripCount> create(Ref ref) {
    return monthTripCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<MonthTripCount> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<MonthTripCount>>(value),
    );
  }
}

String _$monthTripCountHash() => r'19712b1917f01c0e14e3a56d284cc2dd6774a7e3';

@ProviderFor(visitedTrips)
final visitedTripsProvider = VisitedTripsProvider._();

final class VisitedTripsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TravelDbModel>>,
          List<TravelDbModel>,
          Stream<List<TravelDbModel>>
        >
    with
        $FutureModifier<List<TravelDbModel>>,
        $StreamProvider<List<TravelDbModel>> {
  VisitedTripsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visitedTripsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visitedTripsHash();

  @$internal
  @override
  $StreamProviderElement<List<TravelDbModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TravelDbModel>> create(Ref ref) {
    return visitedTrips(ref);
  }
}

String _$visitedTripsHash() => r'681c556b0672ca6c01cdf442713b48094f3b27a8';

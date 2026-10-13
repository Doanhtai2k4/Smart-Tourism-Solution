// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tripService)
final tripServiceProvider = TripServiceProvider._();

final class TripServiceProvider
    extends $FunctionalProvider<TripService, TripService, TripService>
    with $Provider<TripService> {
  TripServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripServiceHash();

  @$internal
  @override
  $ProviderElement<TripService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TripService create(Ref ref) {
    return tripService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripService>(value),
    );
  }
}

String _$tripServiceHash() => r'f790889bd5d16f761671bb88c2d58f2bdcb80825';

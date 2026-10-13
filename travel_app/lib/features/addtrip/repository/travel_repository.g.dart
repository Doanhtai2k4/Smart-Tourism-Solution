// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(travelRepository)
final travelRepositoryProvider = TravelRepositoryProvider._();

final class TravelRepositoryProvider
    extends
        $FunctionalProvider<
          TravelRepository,
          TravelRepository,
          TravelRepository
        >
    with $Provider<TravelRepository> {
  TravelRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'travelRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$travelRepositoryHash();

  @$internal
  @override
  $ProviderElement<TravelRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TravelRepository create(Ref ref) {
    return travelRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TravelRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TravelRepository>(value),
    );
  }
}

String _$travelRepositoryHash() => r'c5547487b9a5fe4fdfec11311f4c67cb175aea75';

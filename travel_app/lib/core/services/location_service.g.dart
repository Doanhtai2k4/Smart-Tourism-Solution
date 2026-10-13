// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocationService)
final locationServiceProvider = LocationServiceProvider._();

final class LocationServiceProvider
    extends $AsyncNotifierProvider<LocationService, Position?> {
  LocationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationServiceHash();

  @$internal
  @override
  LocationService create() => LocationService();
}

String _$locationServiceHash() => r'186a690e7cdebf5ed8d79b3487f00f170ff03fcb';

abstract class _$LocationService extends $AsyncNotifier<Position?> {
  FutureOr<Position?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Position?>, Position?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Position?>, Position?>,
              AsyncValue<Position?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

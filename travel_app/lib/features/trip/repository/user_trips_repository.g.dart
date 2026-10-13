// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_trips_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userTripsRepository)
final userTripsRepositoryProvider = UserTripsRepositoryProvider._();

final class UserTripsRepositoryProvider
    extends
        $FunctionalProvider<
          UserTripsRepository,
          UserTripsRepository,
          UserTripsRepository
        >
    with $Provider<UserTripsRepository> {
  UserTripsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userTripsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userTripsRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserTripsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserTripsRepository create(Ref ref) {
    return userTripsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserTripsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserTripsRepository>(value),
    );
  }
}

String _$userTripsRepositoryHash() =>
    r'6ba11047d21f2c629f9aa816493eacdf1396cab3';

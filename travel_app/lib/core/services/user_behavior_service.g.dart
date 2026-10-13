// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_behavior_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service để theo dõi hành vi người dùng

@ProviderFor(userBehaviorService)
final userBehaviorServiceProvider = UserBehaviorServiceProvider._();

/// Service để theo dõi hành vi người dùng

final class UserBehaviorServiceProvider
    extends
        $FunctionalProvider<
          UserBehaviorService,
          UserBehaviorService,
          UserBehaviorService
        >
    with $Provider<UserBehaviorService> {
  /// Service để theo dõi hành vi người dùng
  UserBehaviorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userBehaviorServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userBehaviorServiceHash();

  @$internal
  @override
  $ProviderElement<UserBehaviorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserBehaviorService create(Ref ref) {
    return userBehaviorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserBehaviorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserBehaviorService>(value),
    );
  }
}

String _$userBehaviorServiceHash() =>
    r'8f49320378115985c3aca84d5944527eadfd4d64';

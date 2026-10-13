// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_backend_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiBackendService)
final aiBackendServiceProvider = AiBackendServiceProvider._();

final class AiBackendServiceProvider
    extends
        $FunctionalProvider<
          AiBackendService,
          AiBackendService,
          AiBackendService
        >
    with $Provider<AiBackendService> {
  AiBackendServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiBackendServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiBackendServiceHash();

  @$internal
  @override
  $ProviderElement<AiBackendService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AiBackendService create(Ref ref) {
    return aiBackendService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiBackendService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiBackendService>(value),
    );
  }
}

String _$aiBackendServiceHash() => r'32608ea02ea1f30253b8c1602f112a2a35c95d70';

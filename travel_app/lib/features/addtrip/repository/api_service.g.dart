// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geminiApiService)
final geminiApiServiceProvider = GeminiApiServiceProvider._();

final class GeminiApiServiceProvider
    extends
        $FunctionalProvider<
          GeminiApiService,
          GeminiApiService,
          GeminiApiService
        >
    with $Provider<GeminiApiService> {
  GeminiApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiApiServiceHash();

  @$internal
  @override
  $ProviderElement<GeminiApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeminiApiService create(Ref ref) {
    return geminiApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeminiApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeminiApiService>(value),
    );
  }
}

String _$geminiApiServiceHash() => r'6beaa0194a60858b816d83f714bfc70645b054bc';

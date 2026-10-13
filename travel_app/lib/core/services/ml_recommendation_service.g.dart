// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ml_recommendation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mlService)
final mlServiceProvider = MlServiceProvider._();

final class MlServiceProvider
    extends
        $FunctionalProvider<
          MLRecommendationService,
          MLRecommendationService,
          MLRecommendationService
        >
    with $Provider<MLRecommendationService> {
  MlServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mlServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mlServiceHash();

  @$internal
  @override
  $ProviderElement<MLRecommendationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MLRecommendationService create(Ref ref) {
    return mlService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MLRecommendationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MLRecommendationService>(value),
    );
  }
}

String _$mlServiceHash() => r'72cc6ee54e8e1c42c9625a861cd288240a4cecbd';

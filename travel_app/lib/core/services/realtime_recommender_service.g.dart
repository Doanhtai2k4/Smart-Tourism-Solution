// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_recommender_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Real-time In-Session Recommender Service.
/// It tracks user preferences based on current session interactions.

@ProviderFor(RealtimeRecommender)
final realtimeRecommenderProvider = RealtimeRecommenderProvider._();

/// Real-time In-Session Recommender Service.
/// It tracks user preferences based on current session interactions.
final class RealtimeRecommenderProvider
    extends $NotifierProvider<RealtimeRecommender, Map<String, double>> {
  /// Real-time In-Session Recommender Service.
  /// It tracks user preferences based on current session interactions.
  RealtimeRecommenderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realtimeRecommenderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realtimeRecommenderHash();

  @$internal
  @override
  RealtimeRecommender create() => RealtimeRecommender();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$realtimeRecommenderHash() =>
    r'e474d34dfac03635d50c6cdd32d67e5c6f549190';

/// Real-time In-Session Recommender Service.
/// It tracks user preferences based on current session interactions.

abstract class _$RealtimeRecommender extends $Notifier<Map<String, double>> {
  Map<String, double> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, double>, Map<String, double>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, double>, Map<String, double>>,
              Map<String, double>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

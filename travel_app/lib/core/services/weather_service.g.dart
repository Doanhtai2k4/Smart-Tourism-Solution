// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WeatherService)
final weatherServiceProvider = WeatherServiceProvider._();

final class WeatherServiceProvider
    extends $NotifierProvider<WeatherService, WeatherCondition> {
  WeatherServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherServiceHash();

  @$internal
  @override
  WeatherService create() => WeatherService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherCondition value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherCondition>(value),
    );
  }
}

String _$weatherServiceHash() => r'ba9def48d1e5682549f53158a18b7da661819ce3';

abstract class _$WeatherService extends $Notifier<WeatherCondition> {
  WeatherCondition build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WeatherCondition, WeatherCondition>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WeatherCondition, WeatherCondition>,
              WeatherCondition,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

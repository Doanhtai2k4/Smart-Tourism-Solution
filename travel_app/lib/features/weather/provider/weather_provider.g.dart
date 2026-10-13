// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
final dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'088d5c03610503c2407a8d7429b0e9f3ee76406f';

@ProviderFor(weatherApiService)
final weatherApiServiceProvider = WeatherApiServiceProvider._();

final class WeatherApiServiceProvider
    extends
        $FunctionalProvider<
          WeatherApiService,
          WeatherApiService,
          WeatherApiService
        >
    with $Provider<WeatherApiService> {
  WeatherApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherApiServiceHash();

  @$internal
  @override
  $ProviderElement<WeatherApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WeatherApiService create(Ref ref) {
    return weatherApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherApiService>(value),
    );
  }
}

String _$weatherApiServiceHash() => r'19a6e0916a32ee812b572fa5672e20da1a10cd1d';

@ProviderFor(weatherRepository)
final weatherRepositoryProvider = WeatherRepositoryProvider._();

final class WeatherRepositoryProvider
    extends
        $FunctionalProvider<
          WeatherRepository,
          WeatherRepository,
          WeatherRepository
        >
    with $Provider<WeatherRepository> {
  WeatherRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherRepositoryHash();

  @$internal
  @override
  $ProviderElement<WeatherRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WeatherRepository create(Ref ref) {
    return weatherRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherRepository>(value),
    );
  }
}

String _$weatherRepositoryHash() => r'12569fabccd1c69712e1aabd6ff60304264040c0';

@ProviderFor(weatherForecast)
final weatherForecastProvider = WeatherForecastFamily._();

final class WeatherForecastProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeatherEntity>,
          WeatherEntity,
          FutureOr<WeatherEntity>
        >
    with $FutureModifier<WeatherEntity>, $FutureProvider<WeatherEntity> {
  WeatherForecastProvider._({
    required WeatherForecastFamily super.from,
    required (double, double) super.argument,
  }) : super(
         retry: null,
         name: r'weatherForecastProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weatherForecastHash();

  @override
  String toString() {
    return r'weatherForecastProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<WeatherEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeatherEntity> create(Ref ref) {
    final argument = this.argument as (double, double);
    return weatherForecast(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WeatherForecastProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weatherForecastHash() => r'b34dfbbe4902f73c5b1d734d374fdea2b58509fd';

final class WeatherForecastFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WeatherEntity>, (double, double)> {
  WeatherForecastFamily._()
    : super(
        retry: null,
        name: r'weatherForecastProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WeatherForecastProvider call(double lat, double lon) =>
      WeatherForecastProvider._(argument: (lat, lon), from: this);

  @override
  String toString() => r'weatherForecastProvider';
}

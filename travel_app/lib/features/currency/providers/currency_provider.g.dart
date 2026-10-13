// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currencies)
final currenciesProvider = CurrenciesProvider._();

final class CurrenciesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          FutureOr<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $FutureProvider<Map<String, String>> {
  CurrenciesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currenciesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currenciesHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, String>> create(Ref ref) {
    return currencies(ref);
  }
}

String _$currenciesHash() => r'88072fc81d342372b7c2d32b81fae8c471839614';

@ProviderFor(conversion)
final conversionProvider = ConversionFamily._();

final class ConversionProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  ConversionProvider._({
    required ConversionFamily super.from,
    required ({String from, String to, double amount}) super.argument,
  }) : super(
         retry: null,
         name: r'conversionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversionHash();

  @override
  String toString() {
    return r'conversionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as ({String from, String to, double amount});
    return conversion(
      ref,
      from: argument.from,
      to: argument.to,
      amount: argument.amount,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConversionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversionHash() => r'568d7b52ad3eef60cc008d190a57edc396226a0d';

final class ConversionFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<double>,
          ({String from, String to, double amount})
        > {
  ConversionFamily._()
    : super(
        retry: null,
        name: r'conversionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConversionProvider call({
    required String from,
    required String to,
    required double amount,
  }) => ConversionProvider._(
    argument: (from: from, to: to, amount: amount),
    from: this,
  );

  @override
  String toString() => r'conversionProvider';
}

@ProviderFor(CurrencyStateNotifier)
final currencyStateProvider = CurrencyStateNotifierProvider._();

final class CurrencyStateNotifierProvider
    extends $NotifierProvider<CurrencyStateNotifier, CurrencyState> {
  CurrencyStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currencyStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currencyStateNotifierHash();

  @$internal
  @override
  CurrencyStateNotifier create() => CurrencyStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CurrencyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CurrencyState>(value),
    );
  }
}

String _$currencyStateNotifierHash() =>
    r'645c68776d47a7a840609fd6f1851fe851587ab7';

abstract class _$CurrencyStateNotifier extends $Notifier<CurrencyState> {
  CurrencyState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CurrencyState, CurrencyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CurrencyState, CurrencyState>,
              CurrencyState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

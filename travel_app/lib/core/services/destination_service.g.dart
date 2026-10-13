// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DestinationService)
final destinationServiceProvider = DestinationServiceProvider._();

final class DestinationServiceProvider
    extends $NotifierProvider<DestinationService, void> {
  DestinationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'destinationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$destinationServiceHash();

  @$internal
  @override
  DestinationService create() => DestinationService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$destinationServiceHash() =>
    r'ccb0b362d3a8df1e8827617adcf3769b5db79455';

abstract class _$DestinationService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

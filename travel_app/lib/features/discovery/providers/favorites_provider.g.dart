// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(isFavorite)
final isFavoriteProvider = IsFavoriteFamily._();

final class IsFavoriteProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  IsFavoriteProvider._({
    required IsFavoriteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isFavoriteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFavoriteHash();

  @override
  String toString() {
    return r'isFavoriteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isFavorite(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFavoriteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFavoriteHash() => r'85a66747de92477e5e90bb7601dc0a275449d73f';

final class IsFavoriteFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  IsFavoriteFamily._()
    : super(
        retry: null,
        name: r'isFavoriteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsFavoriteProvider call(String destinationId) =>
      IsFavoriteProvider._(argument: destinationId, from: this);

  @override
  String toString() => r'isFavoriteProvider';
}

@ProviderFor(favoriteDestinations)
final favoriteDestinationsProvider = FavoriteDestinationsProvider._();

final class FavoriteDestinationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DestinationModel>>,
          List<DestinationModel>,
          Stream<List<DestinationModel>>
        >
    with
        $FutureModifier<List<DestinationModel>>,
        $StreamProvider<List<DestinationModel>> {
  FavoriteDestinationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteDestinationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteDestinationsHash();

  @$internal
  @override
  $StreamProviderElement<List<DestinationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DestinationModel>> create(Ref ref) {
    return favoriteDestinations(ref);
  }
}

String _$favoriteDestinationsHash() =>
    r'85e96c1cb78945c26007a90662f7d46605de863a';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchTrip)
final searchTripProvider = SearchTripFamily._();

final class SearchTripProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TravelDbModel>>,
          List<TravelDbModel>,
          FutureOr<List<TravelDbModel>>
        >
    with
        $FutureModifier<List<TravelDbModel>>,
        $FutureProvider<List<TravelDbModel>> {
  SearchTripProvider._({
    required SearchTripFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchTripProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchTripHash();

  @override
  String toString() {
    return r'searchTripProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TravelDbModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TravelDbModel>> create(Ref ref) {
    final argument = this.argument as String;
    return searchTrip(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchTripProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchTripHash() => r'69a8b262a5a952b263469c7da01cc3b531d01cea';

final class SearchTripFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TravelDbModel>>, String> {
  SearchTripFamily._()
    : super(
        retry: null,
        name: r'searchTripProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchTripProvider call(String query) =>
      SearchTripProvider._(argument: query, from: this);

  @override
  String toString() => r'searchTripProvider';
}

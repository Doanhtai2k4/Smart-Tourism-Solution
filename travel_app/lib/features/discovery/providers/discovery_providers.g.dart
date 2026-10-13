// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tier 1: Trending Destinations (Real-time from Firestore)

@ProviderFor(trendingDestinations)
final trendingDestinationsProvider = TrendingDestinationsProvider._();

/// Tier 1: Trending Destinations (Real-time from Firestore)

final class TrendingDestinationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DestinationModel>>,
          List<DestinationModel>,
          Stream<List<DestinationModel>>
        >
    with
        $FutureModifier<List<DestinationModel>>,
        $StreamProvider<List<DestinationModel>> {
  /// Tier 1: Trending Destinations (Real-time from Firestore)
  TrendingDestinationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingDestinationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingDestinationsHash();

  @$internal
  @override
  $StreamProviderElement<List<DestinationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DestinationModel>> create(Ref ref) {
    return trendingDestinations(ref);
  }
}

String _$trendingDestinationsHash() =>
    r'c9927bb83acad0a6ab2d3b3faa647c728011a192';

/// Provider cho danh sách địa điểm (Catalog) từ Firestore
/// Lấy toàn bộ catalog để thuật toán re-ranking có đủ dữ liệu.

@ProviderFor(catalogDestinations)
final catalogDestinationsProvider = CatalogDestinationsProvider._();

/// Provider cho danh sách địa điểm (Catalog) từ Firestore
/// Lấy toàn bộ catalog để thuật toán re-ranking có đủ dữ liệu.

final class CatalogDestinationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DestinationModel>>,
          List<DestinationModel>,
          FutureOr<List<DestinationModel>>
        >
    with
        $FutureModifier<List<DestinationModel>>,
        $FutureProvider<List<DestinationModel>> {
  /// Provider cho danh sách địa điểm (Catalog) từ Firestore
  /// Lấy toàn bộ catalog để thuật toán re-ranking có đủ dữ liệu.
  CatalogDestinationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogDestinationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogDestinationsHash();

  @$internal
  @override
  $FutureProviderElement<List<DestinationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DestinationModel>> create(Ref ref) {
    return catalogDestinations(ref);
  }
}

String _$catalogDestinationsHash() =>
    r'01b9751afd324669c7ebc763e3e4a92c6f3d04ad';

/// Tier 2: Real-time For You (In-session behavior focus + Immediate Context + ML Segment)

@ProviderFor(realtimeDestinations)
final realtimeDestinationsProvider = RealtimeDestinationsProvider._();

/// Tier 2: Real-time For You (In-session behavior focus + Immediate Context + ML Segment)

final class RealtimeDestinationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DestinationModel>>,
          List<DestinationModel>,
          FutureOr<List<DestinationModel>>
        >
    with
        $FutureModifier<List<DestinationModel>>,
        $FutureProvider<List<DestinationModel>> {
  /// Tier 2: Real-time For You (In-session behavior focus + Immediate Context + ML Segment)
  RealtimeDestinationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realtimeDestinationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realtimeDestinationsHash();

  @$internal
  @override
  $FutureProviderElement<List<DestinationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DestinationModel>> create(Ref ref) {
    return realtimeDestinations(ref);
  }
}

String _$realtimeDestinationsHash() =>
    r'78fa31960e7f0d33c5b0d067d6c892e4468d5278';

/// Tier 3: AI Recommendations — Full catalog re-ranked by AI.
///
/// **Progressive Loading Strategy (2-phase):**
///
/// Phase 1 (immediate, ~1-2s): Return full catalog sorted by popularity while
/// the AI server is warming up. User sees data right away.
///
/// Phase 2 (background): Kick off AI request concurrently. When the server
/// responds (could be after cold-start), invalidate this provider to trigger
/// a transparent UI refresh with AI-ranked data at the top.
///
/// This eliminates the "45s blank screen" problem on Render cold-start.

@ProviderFor(aiDestinations)
final aiDestinationsProvider = AiDestinationsProvider._();

/// Tier 3: AI Recommendations — Full catalog re-ranked by AI.
///
/// **Progressive Loading Strategy (2-phase):**
///
/// Phase 1 (immediate, ~1-2s): Return full catalog sorted by popularity while
/// the AI server is warming up. User sees data right away.
///
/// Phase 2 (background): Kick off AI request concurrently. When the server
/// responds (could be after cold-start), invalidate this provider to trigger
/// a transparent UI refresh with AI-ranked data at the top.
///
/// This eliminates the "45s blank screen" problem on Render cold-start.

final class AiDestinationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AiRecommendationResult>,
          AiRecommendationResult,
          FutureOr<AiRecommendationResult>
        >
    with
        $FutureModifier<AiRecommendationResult>,
        $FutureProvider<AiRecommendationResult> {
  /// Tier 3: AI Recommendations — Full catalog re-ranked by AI.
  ///
  /// **Progressive Loading Strategy (2-phase):**
  ///
  /// Phase 1 (immediate, ~1-2s): Return full catalog sorted by popularity while
  /// the AI server is warming up. User sees data right away.
  ///
  /// Phase 2 (background): Kick off AI request concurrently. When the server
  /// responds (could be after cold-start), invalidate this provider to trigger
  /// a transparent UI refresh with AI-ranked data at the top.
  ///
  /// This eliminates the "45s blank screen" problem on Render cold-start.
  AiDestinationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiDestinationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiDestinationsHash();

  @$internal
  @override
  $FutureProviderElement<AiRecommendationResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AiRecommendationResult> create(Ref ref) {
    return aiDestinations(ref);
  }
}

String _$aiDestinationsHash() => r'fe53cc3b664b5f8a8efef431973d07ca99cd19d5';

/// Legacy / Unified — returns AI-ranked destination list for backward compatibility.

@ProviderFor(hybridDiscovery)
final hybridDiscoveryProvider = HybridDiscoveryProvider._();

/// Legacy / Unified — returns AI-ranked destination list for backward compatibility.

final class HybridDiscoveryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DestinationModel>>,
          List<DestinationModel>,
          FutureOr<List<DestinationModel>>
        >
    with
        $FutureModifier<List<DestinationModel>>,
        $FutureProvider<List<DestinationModel>> {
  /// Legacy / Unified — returns AI-ranked destination list for backward compatibility.
  HybridDiscoveryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hybridDiscoveryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hybridDiscoveryHash();

  @$internal
  @override
  $FutureProviderElement<List<DestinationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DestinationModel>> create(Ref ref) {
    return hybridDiscovery(ref);
  }
}

String _$hybridDiscoveryHash() => r'b76f4feacde13a33005d7c19451b7489992e55bd';

/// Provider cho tìm kiếm destinations

@ProviderFor(searchDestinations)
final searchDestinationsProvider = SearchDestinationsFamily._();

/// Provider cho tìm kiếm destinations

final class SearchDestinationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DestinationModel>>,
          List<DestinationModel>,
          FutureOr<List<DestinationModel>>
        >
    with
        $FutureModifier<List<DestinationModel>>,
        $FutureProvider<List<DestinationModel>> {
  /// Provider cho tìm kiếm destinations
  SearchDestinationsProvider._({
    required SearchDestinationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchDestinationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchDestinationsHash();

  @override
  String toString() {
    return r'searchDestinationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DestinationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DestinationModel>> create(Ref ref) {
    final argument = this.argument as String;
    return searchDestinations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchDestinationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchDestinationsHash() =>
    r'7f9d22015791498927201690d8e36a322981060d';

/// Provider cho tìm kiếm destinations

final class SearchDestinationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DestinationModel>>, String> {
  SearchDestinationsFamily._()
    : super(
        retry: null,
        name: r'searchDestinationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider cho tìm kiếm destinations

  SearchDestinationsProvider call(String query) =>
      SearchDestinationsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchDestinationsProvider';
}

/// Provider cho chi tiết một destination

@ProviderFor(destinationDetails)
final destinationDetailsProvider = DestinationDetailsFamily._();

/// Provider cho chi tiết một destination

final class DestinationDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DestinationModel?>,
          DestinationModel?,
          FutureOr<DestinationModel?>
        >
    with
        $FutureModifier<DestinationModel?>,
        $FutureProvider<DestinationModel?> {
  /// Provider cho chi tiết một destination
  DestinationDetailsProvider._({
    required DestinationDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'destinationDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$destinationDetailsHash();

  @override
  String toString() {
    return r'destinationDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DestinationModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DestinationModel?> create(Ref ref) {
    final argument = this.argument as String;
    return destinationDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DestinationDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$destinationDetailsHash() =>
    r'2db7933cffcd6210887c6847d4b5dc9550c36d5c';

/// Provider cho chi tiết một destination

final class DestinationDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DestinationModel?>, String> {
  DestinationDetailsFamily._()
    : super(
        retry: null,
        name: r'destinationDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider cho chi tiết một destination

  DestinationDetailsProvider call(String destinationId) =>
      DestinationDetailsProvider._(argument: destinationId, from: this);

  @override
  String toString() => r'destinationDetailsProvider';
}

@ProviderFor(destinationStream)
final destinationStreamProvider = DestinationStreamFamily._();

final class DestinationStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<DestinationModel?>,
          DestinationModel?,
          Stream<DestinationModel?>
        >
    with
        $FutureModifier<DestinationModel?>,
        $StreamProvider<DestinationModel?> {
  DestinationStreamProvider._({
    required DestinationStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'destinationStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$destinationStreamHash();

  @override
  String toString() {
    return r'destinationStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DestinationModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DestinationModel?> create(Ref ref) {
    final argument = this.argument as String;
    return destinationStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DestinationStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$destinationStreamHash() => r'4f43268f1ee65f2c0313eda8d68021a5afc745ee';

final class DestinationStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DestinationModel?>, String> {
  DestinationStreamFamily._()
    : super(
        retry: null,
        name: r'destinationStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DestinationStreamProvider call(String destinationId) =>
      DestinationStreamProvider._(argument: destinationId, from: this);

  @override
  String toString() => r'destinationStreamProvider';
}

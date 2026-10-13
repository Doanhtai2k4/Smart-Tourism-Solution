// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReviewController)
final reviewControllerProvider = ReviewControllerFamily._();

final class ReviewControllerProvider
    extends $AsyncNotifierProvider<ReviewController, ReviewFormState> {
  ReviewControllerProvider._({
    required ReviewControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'reviewControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reviewControllerHash();

  @override
  String toString() {
    return r'reviewControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ReviewController create() => ReviewController();

  @override
  bool operator ==(Object other) {
    return other is ReviewControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reviewControllerHash() => r'2c66fc7dd48a858511203a507b643ca67274a0af';

final class ReviewControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ReviewController,
          AsyncValue<ReviewFormState>,
          ReviewFormState,
          FutureOr<ReviewFormState>,
          String
        > {
  ReviewControllerFamily._()
    : super(
        retry: null,
        name: r'reviewControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReviewControllerProvider call(String destinationId) =>
      ReviewControllerProvider._(argument: destinationId, from: this);

  @override
  String toString() => r'reviewControllerProvider';
}

abstract class _$ReviewController extends $AsyncNotifier<ReviewFormState> {
  late final _$args = ref.$arg as String;
  String get destinationId => _$args;

  FutureOr<ReviewFormState> build(String destinationId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ReviewFormState>, ReviewFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReviewFormState>, ReviewFormState>,
              AsyncValue<ReviewFormState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(destinationReviews)
final destinationReviewsProvider = DestinationReviewsFamily._();

final class DestinationReviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          Stream<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  DestinationReviewsProvider._({
    required DestinationReviewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'destinationReviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$destinationReviewsHash();

  @override
  String toString() {
    return r'destinationReviewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as String;
    return destinationReviews(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DestinationReviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$destinationReviewsHash() =>
    r'7f5c496dd79f4fef8a20b6b55720b6fed5587802';

final class DestinationReviewsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Map<String, dynamic>>>, String> {
  DestinationReviewsFamily._()
    : super(
        retry: null,
        name: r'destinationReviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DestinationReviewsProvider call(String destinationId) =>
      DestinationReviewsProvider._(argument: destinationId, from: this);

  @override
  String toString() => r'destinationReviewsProvider';
}

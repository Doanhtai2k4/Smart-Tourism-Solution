import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/core/services/review_service.dart';
import '../../auth/provider/auth_providers.dart';

part 'review_controller.g.dart';

/// State object for the Review Form in DiscoveryDetailPage
class ReviewFormState {
  final double rating;
  final String comment;
  final bool isSubmitting;
  final bool isUpdate;

  const ReviewFormState({
    this.rating = 0.0,
    this.comment = '',
    this.isSubmitting = false,
    this.isUpdate = false,
  });

  ReviewFormState copyWith({
    double? rating,
    String? comment,
    bool? isSubmitting,
    bool? isUpdate,
  }) {
    return ReviewFormState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUpdate: isUpdate ?? this.isUpdate,
    );
  }
}

@riverpod
class ReviewController extends _$ReviewController {
  late final ReviewService _reviewService;

  @override
  FutureOr<ReviewFormState> build(String destinationId) async {
    _reviewService = ReviewService();
    
    try {
      // Fetch existing review for the current user
      final existingReview = await _reviewService.getUserReview(destinationId);
      
      if (existingReview != null) {
        return ReviewFormState(
          rating: (existingReview['rating'] as num?)?.toDouble() ?? 0.0,
          comment: existingReview['comment'] as String? ?? '',
          isUpdate: true,
        );
      }
    } catch (e) {
      // Return empty state if not logged in or other error
      return const ReviewFormState();
    }
    
    return const ReviewFormState();
  }

  /// Updates the rating in the local state
  void updateRating(double rating) {
    state = AsyncData(state.value!.copyWith(rating: rating));
  }

  /// Updates the comment in the local state
  void updateComment(String comment) {
    state = AsyncData(state.value!.copyWith(comment: comment));
  }

  /// Submits or updates the review in Firestore
  Future<void> submitReview({
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    final currentState = state.value!;
    if (currentState.rating == 0) return;

    state = AsyncData(currentState.copyWith(isSubmitting: true));

    try {
      // Fetch current user's profile name/photo from userInfoProvider (Firestore-backed)
      final userProfile = ref.read(userInfoProvider);

      await _reviewService.submitOrUpdateReview(
        destinationId: destinationId, // destinationId is from build parameter
        rating: currentState.rating,
        comment: currentState.comment,
        userName: userProfile?.name,
        userPhoto: userProfile?.profilePic,
      );
      
      state = AsyncData(currentState.copyWith(
        isSubmitting: false,
        isUpdate: true,
      ));
      
      onSuccess(currentState.isUpdate ? 'Đã cập nhật đánh giá!' : 'Đã gửi đánh giá thành công!');
    } catch (e) {
      state = AsyncData(currentState.copyWith(isSubmitting: false));
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }
}

@riverpod
Stream<List<Map<String, dynamic>>> destinationReviews(Ref ref, String destinationId) {
  final reviewService = ReviewService();
  return reviewService.getDestinationReviews(destinationId);
}

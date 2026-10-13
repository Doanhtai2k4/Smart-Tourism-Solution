import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service handled Rating & Review logic for destinations.
/// Ensures each user only has 1 review per destination and aggregates ratings.
class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submits a new review or updates an existing one for a destination.
  /// Path: destinations/{destinationId}/reviews/{userId}
  Future<void> submitOrUpdateReview({
    required String destinationId,
    required double rating,
    required String comment,
    String? userName,
    String? userPhoto,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Vui lòng đăng nhập để thực hiện đánh giá.');
      }

      final String userId = user.uid;
      final String finalName = userName ?? user.displayName ?? 'Người dùng ẩn danh';
      final String finalPhoto = userPhoto ?? user.photoURL ?? '';

      final reviewRef = _firestore
          .collection('destinations')
          .doc(destinationId)
          .collection('reviews')
          .doc(userId);

      // Step 1: Upsert the review data
      await reviewRef.set({
        'userId': userId,
        'userName': finalName,
        'userPhoto': finalPhoto,
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Step 2: Recalculate average rating for the destination
      try {
        await _aggregateRating(destinationId);
      } catch (e) {
        // Aggregation failed (likely due to missing permissions for parent doc)
        // We log it so developers can see it, but we don't break the user experience
        debugPrint('Aggregation failed: ${e.toString()}');
      }
    } catch (e) {
      if (e is FirebaseException) {
        if (e.code == 'permission-denied') {
          throw Exception('Lỗi phân quyền Firebase: Bạn chưa có quyền viết nhận xét. Vui lòng kiểm tra Firestore Security Rules trong Firebase Console.');
        }
        throw Exception('Lỗi hệ thống Firebase: ${e.message}');
      }
      rethrow;
    }
  }

  /// Calculates total reviews and average rating by iterating through the reviews sub-collection.
  /// Updates the parent destination document with new values.
  Future<void> _aggregateRating(String destinationId) async {
    final reviewsSnapshot = await _firestore
        .collection('destinations')
        .doc(destinationId)
        .collection('reviews')
        .get();

    final List<QueryDocumentSnapshot> reviews = reviewsSnapshot.docs;
    final int newReviewCount = reviews.length;

    double newAverageRating = 0.0;
    if (newReviewCount > 0) {
      double totalRating = 0.0;
      for (var doc in reviews) {
        final data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] as num?)?.toDouble() ?? 0.0;
      }
      newAverageRating = totalRating / newReviewCount;
    }

    // Update the parent destination document
    await _firestore.collection('destinations').doc(destinationId).update({
      'averageRating': newAverageRating,
      'ratingCount': newReviewCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Streams all reviews for a destination ordered by most recent.
  Stream<List<Map<String, dynamic>>> getDestinationReviews(String destinationId) {
    return _firestore
        .collection('destinations')
        .doc(destinationId)
        .collection('reviews')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Retrieves the existing review for the current user at a specific destination.
  /// Returns the document data or null if not found.
  Future<Map<String, dynamic>?> getUserReview(String destinationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('destinations')
          .doc(destinationId)
          .collection('reviews')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin đánh giá cũ: ${e.toString()}');
    }
    return null;
  }
}

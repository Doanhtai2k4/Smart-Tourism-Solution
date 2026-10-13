import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/shared/models/destination_model.dart';

part 'destination_service.g.dart';

@riverpod
class DestinationService extends _$DestinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void build() {}

  /// A. Tăng lượt xem (Views)
  /// Sử dụng FieldValue.increment để đảm bảo tính nguyên tử (atomic)
  Future<void> incrementViewCount(String destinationId) async {
    try {
      await _firestore.collection('destinations').doc(destinationId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  /// B. Yêu thích (Favorites)
  /// Thêm/Xóa khỏi mảng favorites của User và tăng/giảm favoriteCount của địa điểm
  Future<void> toggleFavorite({
    required String userId,
    required String destinationId,
    required bool isCurrentlyFavorited,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final destRef = _firestore.collection('destinations').doc(destinationId);

    try {
      final batch = _firestore.batch();

      if (isCurrentlyFavorited) {
        // Bỏ yêu thích
        batch.update(userRef, {
          'favorites': FieldValue.arrayRemove([destinationId]),
        });
        batch.update(destRef, {
          'favoriteCount': FieldValue.increment(-1),
        });
      } else {
        // Thêm yêu thích
        batch.update(userRef, {
          'favorites': FieldValue.arrayUnion([destinationId]),
        });
        batch.update(destRef, {
          'favoriteCount': FieldValue.increment(1),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  /// C. Đánh giá (Ratings)
  /// Sử dụng Transaction để tính toán lại averageRating một cách an toàn
  Future<void> submitReview(String destinationId, double newRating) async {
    final destRef = _firestore.collection('destinations').doc(destinationId);

    try {
      await _firestore.runTransaction((transaction) async {
        final destDoc = await transaction.get(destRef);

        if (!destDoc.exists) {
          throw Exception("Địa điểm không tồn tại!");
        }

        final data = destDoc.data()!;
        final int currentCount = (data['ratingCount'] as num?)?.toInt() ?? 0;
        final double currentAvg = (data['averageRating'] as num?)?.toDouble() ?? 0.0;

        // Tính toán rating mới
        final int newCount = currentCount + 1;
        final double newAvg = ((currentAvg * currentCount) + newRating) / newCount;

        transaction.update(destRef, {
          'ratingCount': newCount,
          'averageRating': newAvg,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error submitting review via transaction: $e');
      rethrow;
    }
  }

  /// 3. LẤY DANH SÁCH TRENDING
  /// Query sắp xếp theo viewCount giảm dần
  Stream<List<DestinationModel>> getTrendingLocations({int limit = 10}) {
    return _firestore
        .collection('destinations')
        .orderBy('viewCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DestinationModel.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }
}

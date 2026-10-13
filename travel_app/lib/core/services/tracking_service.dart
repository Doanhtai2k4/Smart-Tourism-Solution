import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tracking_service.g.dart';

@riverpod
TrackingService trackingService(Ref ref) {
  return TrackingService();
}

class TrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Log interaction to Firestore (Fire and forget)
  void _logInteraction({
    required String destId,
    required String type,
    required double score,
    String? category,
    Map<String, dynamic>? extraData,
  }) async {
    final String userId = _auth.currentUser?.uid ?? 'anonymous_user';

    // Không dùng await để tránh block UI (gọi async không chặn UI)
    try {
      await _firestore.collection('user_interactions').add({
        'userId': userId,
        'destinationId': destId,
        'interactionType': type,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
        'category': category,
        if (extraData != null) ...extraData,
      });
    } catch (e) {
      debugPrint('TrackingService Error: $e');
    }
  }

  /// Track when user views destination detail
  void trackViewDetail(String destId, {String? category}) {
    _logInteraction(destId: destId, type: 'view_detail', score: 1.0, category: category);
  }

  /// Track when user adds to favorite
  void trackAddFavorite(String destId, {String? category}) {
    _logInteraction(destId: destId, type: 'add_favorite', score: 4.0, category: category);
  }

  /// Track when user shares a destination
  void trackShare(String destId, {String? category}) {
    _logInteraction(destId: destId, type: 'share_destination', score: 3.0, category: category);
  }

  /// Track when user starts planning a trip to a destination
  void trackPlanTrip(String destId, {String? category}) {
    _logInteraction(destId: destId, type: 'plan_trip', score: 5.0, category: category);
  }

  /// Track dwell time (stay duration) in seconds
  void trackDwellTime(String destId, int seconds, {String? category}) {
    if (seconds < 10) return; // Chỉ track nếu ở lại lâu hơn 10s
    _logInteraction(
      destId: destId,
      type: 'dwell_time',
      score: 2.0,
      category: category,
      extraData: {'duration_seconds': seconds},
    );
  }

  /// Track when user submits a review
  void trackReview(String destId, double rating, {String? category}) {
    _logInteraction(
      destId: destId,
      type: 'rate_destination',
      score: 5.0,
      category: category,
      extraData: {'rating': rating},
    );
  }

  /// Track when user interacts with the map
  void trackMapInteraction(String destId, {String? category}) {
    _logInteraction(destId: destId, type: 'view_map', score: 1.5, category: category);
  }
  /// Track search queries
  void trackSearch(String query) {
    _logInteraction(
      destId: 'global', // Search không gắn với 1 địa điểm cụ thể
      type: 'search_query',
      score: 0.5,
      extraData: {'query': query},
    );
  }

  /// Track category filtering
  void trackFilterCategory(String category) {
    _logInteraction(
      destId: 'global',
      type: 'filter_category',
      score: 1.0,
      extraData: {'category': category},
    );
  }
}

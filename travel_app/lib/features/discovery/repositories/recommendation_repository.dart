import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/core/services/user_behavior_service.dart';
import 'package:travel_app/shared/models/destination_model.dart';
part 'recommendation_repository.g.dart';

@riverpod
RecommendationRepository recommendationRepository(Ref ref) {
  return RecommendationRepository(
    firestore: FirebaseFirestore.instance,
    behaviorService: ref.watch(userBehaviorServiceProvider),
  );
}

class RecommendationRepository {
  final FirebaseFirestore _firestore;
  final UserBehaviorService _behaviorService;

  RecommendationRepository({
    required FirebaseFirestore firestore,
    required UserBehaviorService behaviorService,
  }) : _firestore = firestore,
       _behaviorService = behaviorService;

  CollectionReference<Map<String, dynamic>> get _destinations =>
      _firestore.collection('destinations');

  /// Lấy danh sách địa điểm (Catalog) từ Firestore
  Future<List<DestinationModel>> getCatalogDestinations({
    int limit = 20,
  }) async {
    try {
      final snapshot = await _destinations
          .orderBy('trendingScore', descending: true) // Stable ordering by popularity
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DestinationModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      // Fallback: no orderBy if index missing
      debugPrint('getCatalogDestinations with sort failed, fallback: $e');
      try {
        final snapshot = await _destinations.limit(limit).get();
        return snapshot.docs
            .map((doc) => DestinationModel.fromFirestore(doc.id, doc.data()))
            .toList();
      } catch (e2) {
        debugPrint('Error getting catalog destinations: $e2');
        rethrow;
      }
    }
  }

  /// Giai đoạn 1: Cold Start - Lấy các địa điểm có rating cao nhất
  Future<List<DestinationModel>> getColdStartRecommendations({
    int limit = 20,
  }) async {
    try {
      final snapshot = await _destinations
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DestinationModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting cold start recommendations: $e');
      rethrow;
    }
  }

  /// Giai đoạn 2: Personalized - Lấy gợi ý dựa trên hành vi người dùng
  Future<List<DestinationModel>> getPersonalizedRecommendations({
    required String userId,
    int daysAgo = 7,
    int topCategories = 3,
    int limit = 20,
  }) async {
    try {
      // Bước 1: Lấy các category mà người dùng tương tác nhiều nhất
      final categoryPreferences = await _behaviorService
          .getUserCategoryPreferences(userId: userId, daysAgo: daysAgo);

      // Nếu không có data, fallback sang cold start
      if (categoryPreferences.isEmpty) {
        return getColdStartRecommendations(limit: limit);
      }

      // Lấy top N categories
      final topCats = categoryPreferences.entries
          .take(topCategories)
          .map((e) => e.key)
          .toList();

      debugPrint('Top categories for user $userId: $topCats');

      // Bước 2: Truy vấn các địa điểm thuộc các category đó
      final results = <DestinationModel>[];
      final seenIds = <String>{};

      for (final category in topCats) {
        final snapshot = await _destinations
            .where('category', isEqualTo: category)
            .orderBy('averageRating', descending: true)
            .limit(limit ~/ topCategories + 1)
            .get();

        for (final doc in snapshot.docs) {
          if (!seenIds.contains(doc.id)) {
            results.add(DestinationModel.fromFirestore(doc.id, doc.data()));
            seenIds.add(doc.id);
          }
        }
      }

      // Nếu vẫn không đủ, bổ sung từ cold start
      if (results.length < limit) {
        final coldStart = await getColdStartRecommendations(limit: limit);
        for (final dest in coldStart) {
          if (!seenIds.contains(dest.id)) {
            results.add(dest);
            if (results.length >= limit) break;
          }
        }
      }

      return results.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting personalized recommendations: $e');
      rethrow;
    }
  }

  /// Lấy trending destinations theo thời gian thực (Dùng viewCount làm tiêu chí trending)
  Stream<List<DestinationModel>> getTrendingDestinations({int limit = 10}) {
    return _destinations
        .orderBy('viewCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => DestinationModel.fromFirestore(doc.id, doc.data()),
              )
              .toList();
        })
        .handleError((error) {
          debugPrint('Stream Error in getTrendingDestinations: $error');
          return <DestinationModel>[];
        });
  }

  /// Tìm kiếm destinations
  Future<List<DestinationModel>> searchDestinations(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final searchKey = query.toLowerCase();
      final snapshot = await _firestore
          .collection('destinations')
          .where('nameLowerCase', isGreaterThanOrEqualTo: searchKey)
          .where('nameLowerCase', isLessThanOrEqualTo: '$searchKey\uf8ff')
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => DestinationModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error searching destinations: $e');
      rethrow;
    }
  }

  /// Lấy chi tiết một destination
  Future<DestinationModel?> getDestinationById(String id) async {
    try {
      final doc = await _destinations.doc(id).get();
      if (!doc.exists) return null;
      return DestinationModel.fromFirestore(doc.id, doc.data()!);
    } catch (e) {
      debugPrint('Error getting destination by id: $e');
      rethrow;
    }
  }

  /// Lấy Stream chi tiết một destination để cập nhật thời gian thực (Real-time)
  Stream<DestinationModel?> getDestinationStream(String id) {
    return _destinations.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DestinationModel.fromFirestore(doc.id, doc.data()!);
    }).handleError((error) {
      debugPrint('Stream Error in getDestinationStream: $error');
      return null;
    });
  }

  /// Lấy destinations theo category
  Future<List<DestinationModel>> getDestinationsByCategory({
    required String category,
    int limit = 10,
  }) async {
    try {
      final snapshot = await _destinations
          .where('category', isEqualTo: category)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DestinationModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting destinations by category: $e');
      rethrow;
    }
  }
}

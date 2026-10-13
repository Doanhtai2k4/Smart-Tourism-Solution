import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_behavior_service.g.dart';

/// Enum cho loại hành vi người dùng
enum UserActivityAction {
  view, // Xem chi tiết
  search, // Tìm kiếm
  click, // Nhấn vào
  favorite, // Yêu thích
  share, // Chia sẻ
  rate, // Đánh giá
  map, // Xem bản đồ
}


/// Model cho bản ghi hoạt động người dùng
class UserActivity {
  final String id;
  final String userId;
  final String destinationId;
  final String? category;
  final UserActivityAction action;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  UserActivity({
    required this.id,
    required this.userId,
    required this.destinationId,
    this.category,
    required this.action,
    required this.timestamp,
    this.metadata,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'destinationId': destinationId,
      'category': category,
      'action': action.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  /// Create from Firestore document
  factory UserActivity.fromFirestore(String id, Map<String, dynamic> data) {
    return UserActivity(
      id: id,
      userId: data['userId'] as String,
      destinationId: data['destinationId'] as String,
      category: data['category'] as String?,
      action: UserActivityAction.values.byName(data['action'] as String),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Service để theo dõi hành vi người dùng
@riverpod
UserBehaviorService userBehaviorService(Ref ref) {
  return UserBehaviorService(firestore: FirebaseFirestore.instance);
}

class UserBehaviorService {
  final FirebaseFirestore _firestore;

  UserBehaviorService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  /// Lưu hành vi người dùng vào Firestore
  Future<void> trackActivity({
    required String userId,
    required String destinationId,
    required UserActivityAction action,
    String? category,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final activity = UserActivity(
        id: '',
        userId: userId,
        destinationId: destinationId,
        category: category,
        action: action,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      await _firestore
          .collection('user_activities')
          .add(activity.toFirestore());

      debugPrint(
        'Activity tracked: $userId - $action - $destinationId - $category',
      );
    } catch (e) {
      debugPrint('Error tracking activity: $e');
      rethrow;
    }
  }

  /// Lấy lịch sử hoạt động trong N ngày qua
  Future<List<UserActivity>> getUserActivities({
    required String userId,
    required int daysAgo,
  }) async {
    try {
      final sinceDate = DateTime.now().subtract(Duration(days: daysAgo));

      final snapshot = await _firestore
          .collection('user_activities')
          .where('userId', isEqualTo: userId)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(sinceDate),
          )
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserActivity.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting user activities: $e');
      rethrow;
    }
  }

  /// Lấy các category mà người dùng tương tác nhiều nhất
  Future<Map<String, int>> getUserCategoryPreferences({
    required String userId,
    required int daysAgo,
  }) async {
    try {
      final activities = await getUserActivities(
        userId: userId,
        daysAgo: daysAgo,
      );

      final categoryMap = <String, int>{};

      for (final activity in activities) {
        if (activity.category != null) {
          categoryMap[activity.category!] =
              (categoryMap[activity.category!] ?? 0) + 1;
        }
      }

      // Sort by count (descending)
      final sortedMap = Map.fromEntries(
        categoryMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );

      return sortedMap;
    } catch (e) {
      debugPrint('Error getting category preferences: $e');
      rethrow;
    }
  }
}

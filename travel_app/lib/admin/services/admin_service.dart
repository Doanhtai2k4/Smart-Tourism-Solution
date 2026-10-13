import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Dashboard Stats ---
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final usersCount = await _firestore.collection('users').count().get();
      final tripsCount = await _firestore.collection('trips').count().get();
      final locationsCount = await _firestore.collection('destinations').count().get();

      return {
        'users': usersCount.count ?? 0,
        'trips': tripsCount.count ?? 0,
        'locations': locationsCount.count ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting stats: $e');
      return {'users': 0, 'trips': 0, 'locations': 0};
    }
  }

  // --- User Management ---
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(500) // Tối ưu: Chỉ lấy 500 người dùng mới nhất
        .snapshots();
  }

  Future<void> deleteUser(String uid) async {
    // Lưu ý: Firebase Auth delete cần Admin SDK ở Backend. 
    // Ở đây ta chỉ xóa dữ liệu trong Firestore hoặc đánh dấu disabled.
    await _firestore.collection('users').doc(uid).update({'status': 'disabled'});
  }

  Future<List<Map<String, dynamic>>> getUserCreatedTrips(String uid) async {
    final snapshot = await _firestore
        .collection('trips')
        .where('userId', isEqualTo: uid)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<List<Map<String, dynamic>>> getUserJoinedTrips(String uid) async {
    final snapshot = await _firestore
        .collection('trips')
        .where('member_ids', arrayContains: uid)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<DocumentSnapshot> getTripById(String tripId) {
    return _firestore.collection('trips').doc(tripId).get();
  }

  // --- Trip Management ---
  Stream<QuerySnapshot> getAllTripsStream() {
    return _firestore
        .collection('trips')
        .orderBy('createdAt', descending: true)
        .limit(500) // Tối ưu: Chỉ lấy 500 chuyến đi mới nhất
        .snapshots();
  }

  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    await _firestore.collection('trips').doc(tripId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> softDeleteTrip(String tripId) async {
    await _firestore.collection('trips').doc(tripId).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Location Management ---
  Stream<QuerySnapshot> getLocationsStream() {
    return _firestore
        .collection('destinations')
        .limit(1000) // Tối ưu: Giới hạn 1000 địa điểm
        .snapshots();
  }

  Future<void> addLocation(Map<String, dynamic> data) async {
    await _firestore.collection('destinations').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLocation(String id, Map<String, dynamic> data) async {
    await _firestore.collection('destinations').doc(id).update(data);
  }

  Future<void> deleteLocation(String id) async {
    await _firestore.collection('destinations').doc(id).delete();
  }

  // --- Reviews Moderation ---
  Future<List<Map<String, dynamic>>> getLocationReviews(String locationId) async {
    final snapshot = await _firestore
        .collection('destinations')
        .doc(locationId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> deleteReview(String locationId, String reviewId) async {
    await _firestore
        .collection('destinations')
        .doc(locationId)
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }

  // --- Recent Activities ---
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final activities = <Map<String, dynamic>>[];
      
      // 1. Lấy 3 chuyến đi mới nhất
      final trips = await _firestore
          .collection('trips')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();
          
      for (var doc in trips.docs) {
        activities.add({
          'type': 'trip_created',
          'title': doc.data()['destination'] ?? 'Chuyến đi mới',
          'time': doc.data()['createdAt'],
          'user': doc.data()['ownerName'] ?? 'Ẩn danh',
        });
      }

      // 2. Lấy 2 người dùng mới nhất
      final users = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      for (var doc in users.docs) {
        activities.add({
          'type': 'user_joined',
          'title': 'Đăng ký tài khoản',
          'time': doc.data()['createdAt'],
          'user': doc.data()['name'] ?? 'Thành viên mới',
        });
      }

      // Sắp xếp lại theo thời gian
      activities.sort((a, b) {
        final timeA = a['time'] as Timestamp?;
        final timeB = b['time'] as Timestamp?;
        if (timeA == null || timeB == null) return 0;
        return timeB.compareTo(timeA);
      });

      return activities;
    } catch (e) {
      debugPrint('Error in getRecentActivities: $e');
      return []; // Trả về danh sách rỗng nếu lỗi để Dashboard không bị treo
    }
  }
}

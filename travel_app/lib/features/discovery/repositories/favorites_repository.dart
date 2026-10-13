import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/shared/models/destination_model.dart';

part 'favorites_repository.g.dart';

@riverpod
FavoritesRepository favoritesRepository(Ref ref) {
  return FavoritesRepository(firestore: FirebaseFirestore.instance);
}

class FavoritesRepository {
  final FirebaseFirestore _firestore;

  FavoritesRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Lấy tham chiếu đến sub-collection favorites của một user
  CollectionReference<Map<String, dynamic>> _userFavorites(String userId) =>
      _firestore.collection('users').doc(userId).collection('favorites');

  /// Toggle trạng thái yêu thích (Sử dụng Batch Write để đồng bộ User và Destination)
  Future<void> toggleFavorite({
    required String userId,
    required DestinationModel destination,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final destRef = _firestore.collection('destinations').doc(destination.id);
    final favDocRef = _userFavorites(userId).doc(destination.id);

    try {
      final doc = await favDocRef.get();
      final isAdding = !doc.exists;

      final batch = _firestore.batch();

      if (isAdding) {
        // 1. Thêm vào sub-collection (để query danh sách yêu thích dễ dàng)
        batch.set(favDocRef, {
          'userId': userId,
          'destinationId': destination.id,
          'destinationData': destination.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        // 2. Thêm vào mảng favorites của User (để check isFavorite nhanh)
        batch.update(userRef, {
          'favorites': FieldValue.arrayUnion([destination.id]),
        });
        // 3. Tăng favoriteCount của Destination
        batch.update(destRef, {
          'favoriteCount': FieldValue.increment(1),
        });
      } else {
        // 1. Xóa khỏi sub-collection
        batch.delete(favDocRef);
        // 2. Xóa khỏi mảng favorites của User
        batch.update(userRef, {
          'favorites': FieldValue.arrayRemove([destination.id]),
        });
        // 3. Giảm favoriteCount của Destination
        batch.update(destRef, {
          'favoriteCount': FieldValue.increment(-1),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  /// Stream kiểm tra một địa điểm có được yêu thích hay không
  /// Truy cập trực tiếp vào document trong sub-collection (Tốc độ O(1))
  Stream<bool> isFavoriteStream({
    required String userId,
    required String destinationId,
  }) {
    return _userFavorites(userId)
        .doc(destinationId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Stream lấy danh sách địa điểm yêu thích của người dùng
  /// Lấy toàn bộ sub-collection (Rất nhanh và không cần global index phức tạp)
  Stream<List<DestinationModel>> getFavoriteDestinationsStream(String userId) {
    return _userFavorites(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final destData = data['destinationData'] as Map<String, dynamic>;
        return DestinationModel.fromFirestore(data['destinationId'], destData);
      }).toList();
    });
  }
}

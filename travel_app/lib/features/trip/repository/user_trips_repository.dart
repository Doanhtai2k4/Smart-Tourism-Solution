import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/features/addtrip/models/trip_plan_request.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';

import 'package:travel_app/core/constants/firebase_constant.dart';
import '../../../core/enums/trip_filter.dart';
import '../../../core/enums/trip_status.dart';
import '../../../core/failure.dart';
import '../../../shared/models/travel_db_model.dart';
import '../../addtrip/repository/ai_backend_service.dart';
import '../../addtrip/repository/image_service.dart';
import '../../addtrip/mapper/travel_model_mapper.dart';
part 'user_trips_repository.g.dart';

@riverpod
UserTripsRepository userTripsRepository(Ref ref) {
  return UserTripsRepository(
    firestore: ref.read(firebaseFirestoreProvider),
    apiService: ref.read(aiBackendServiceProvider),
    imageService: ref.read(imageServiceProvider),
  );
}

class UserTripsRepository {
  final FirebaseFirestore _firestore;
  final AiBackendService _apiService;
  final ImageService _imageService;

  UserTripsRepository({
    required FirebaseFirestore firestore,
    required AiBackendService apiService,
    required ImageService imageService,
  }) : _firestore = firestore,
       _apiService = apiService,
       _imageService = imageService;

  CollectionReference<Map<String, dynamic>> get _trips =>
      _firestore.collection(FirebaseConstant.trips);

  Future<void> replaceAiTripContent({
    required String travelId,
    required TripPlanRequest request,
    required String language,
  }) async {
    // Gọi API của Python Backend thay vì SDK Gemini cũ
    final aiTrip = await _apiService.getTripPlan(request);

    // Map đầy đủ các trường của request mới vào model
    final initialTrip = TravelDbMapper.fromGemini(
      ai: aiTrip,
      userId: request.userId ?? '',
      travelId: travelId,
      language: language,
      request: request,
    );

    final tripData = initialTrip.toMap();
    
    // Remove fields that should NOT be overwritten to protect group members and metadata
    tripData.remove('trip_id');
    tripData.remove('userId');
    tripData.remove('share_code');
    tripData.remove('shareCode');
    tripData.remove('member_ids');
    tripData.remove('memberIds');
    tripData.remove('createdAt');
    
    // Resolve new images from the new destination/keywords
    final initialImages = (aiTrip.images.isNotEmpty)
        ? aiTrip.images
        : [aiTrip.destination, '${aiTrip.destination} landscape', '${aiTrip.destination} travel'];
        
    final imageUrls = await _imageService.fetchImages(initialImages);
    tripData['images'] = imageUrls;

    final updatedTripJson = {
      ...tripData,
      'language': language,
      'generatedByAi': true,
      'updatedAt': Timestamp.now(),
    };

    await _trips.doc(travelId).update(updatedTripJson);
  }


  Future<List<TravelDbModel>> searchDestinations(String query) async {
    try {
      if (query.isEmpty) return [];

      final lowerQuery = query.toLowerCase();

      // Kết hợp tìm kiếm theo destination name (prefix search)
      // Lưu ý: Firestore không hỗ trợ OR giữa các field dễ dàng,
      // nên ta ưu tiên tìm theo tên trước.
      final snapshot = await _trips
          .where('destinationLowerCase', isGreaterThanOrEqualTo: lowerQuery)
          .where('destinationLowerCase', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
          .limit(20)
          .get();

        final results = snapshot.docs
          .map((doc) => _tripFromDocument(doc))
          .toList();

      // Nếu không có kết quả theo tên, thử tìm theo tags (fallback)
      if (results.isEmpty) {
        final tagsSnapshot = await _trips
            .where('tags', arrayContains: lowerQuery)
            .limit(20)
            .get();
        return tagsSnapshot.docs
          .map((doc) => _tripFromDocument(doc))
            .toList();
      }

      return results;
    } catch (e) {
      debugPrint('Error searching destinations: $e');
      rethrow;
    }
  }

  Stream<List<TravelDbModel>> getUserTrips(String userId) {
    return _trips
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final trips = snapshot.docs
          .map(_tripFromDocument)
          .toList();
      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    });
  }

  Stream<List<TravelDbModel>> getJoinedTrips(String userId) {
    return _trips
        .where(
          Filter.or(
            Filter('member_ids', arrayContains: userId),
            Filter('memberIds', arrayContains: userId),
          ),
        )
        .snapshots()
        .map((s) {
      // Lọc bỏ những chuyến đi mà mình là chủ sở hữu (vì Filter.or lấy cả hai)
        final allJoined = s.docs.map(_tripFromDocument).toList();
      return allJoined.where((trip) => trip.userId != userId).toList();
    });
  }

  Future<void> leaveTrip(String travelId, String userId) async {
    await _trips.doc(travelId).update({
      'member_ids': FieldValue.arrayRemove([userId]),
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  Stream<List<TravelDbModel>> getUserTripsByFilter({
    required String userId,
    required TripFilter filter,
  }) {
    Query<Map<String, dynamic>> query = _trips.where(
      'userId',
      isEqualTo: userId,
    );

    final now = DateTime.now();

    switch (filter) {
      case TripFilter.all:
        // Không lọc theo status, hiển thị tất cả trips của user
        break;

      case TripFilter.favorite:
        query = query.where('isFavorite', isEqualTo: true);
        break;

      case TripFilter.thisMonth:
        query = query.where(
          'visitedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(now.year, now.month, 1),
          ),
        );
        break;

      case TripFilter.lastMonth:
        query = query
            .where(
              'visitedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                DateTime(now.year, now.month - 1, 1),
              ),
            )
            .where(
              'visitedAt',
              isLessThanOrEqualTo: Timestamp.fromDate(
                DateTime(now.year, now.month, 0),
              ),
            );
        break;
    }

    return query.orderBy('createdAt', descending: true).snapshots().map(
      (s) => s.docs.map(_tripFromDocument).toList(),
    );
  }

  Future<Either<Failure, TravelDbModel>> getTripById(String travelId) async {
    final doc = await _trips.doc(travelId).get();
    if (!doc.exists) {
      return Left(Failure('Không tìm thấy chuyến đi'));
    }
    return Right(_tripFromDocument(doc));
  }

  TravelDbModel _tripFromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return TravelDbModel.fromJson({
      ...data,
      'travelId': data['travelId'] ?? document.id,
    });
  }

  Future<void> deleteTrip(String travelId) {
    return _trips.doc(travelId).delete();
  }

  Future<void> updateStatus(String travelId, TripStatus status) {
    return _trips.doc(travelId).update({
      'status': status.name,
      if (status == TripStatus.visited) ...{
        'visitedAt': Timestamp.now(),
        'isVisited': true,
      }
    });
  }

  Future<void> toggleFavorite(String travelId, bool isFavorite) {
    return _trips.doc(travelId).update({'isFavorite': isFavorite});
  }

}

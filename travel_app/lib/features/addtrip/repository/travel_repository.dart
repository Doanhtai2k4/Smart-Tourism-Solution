import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/core/constants/firebase_constant.dart';
import 'package:travel_app/core/failure.dart';
import 'package:travel_app/features/addtrip/mapper/travel_model_mapper.dart';
import 'package:travel_app/features/addtrip/repository/ai_backend_service.dart';
import 'image_service.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import 'package:travel_app/shared/models/travel_db_model.dart';
import '../models/trip_plan_request.dart';

part 'travel_repository.g.dart';

@riverpod
TravelRepository travelRepository(Ref ref) {
  return TravelRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    apiService: ref.watch(aiBackendServiceProvider),
    imageService: ref.watch(imageServiceProvider),
  );
}

class TravelRepository {
  final FirebaseFirestore _firestore;
  final AiBackendService _apiService;
  final ImageService _imageService;

  TravelRepository({
    required FirebaseFirestore firestore,
    required AiBackendService apiService,
    required ImageService imageService,
  }) : _firestore = firestore,
       _apiService = apiService,
       _imageService = imageService;

  CollectionReference<Map<String, dynamic>> get _trips =>
      _firestore.collection(FirebaseConstant.trips);

  Future<Either<Failure, TravelDbModel>> generateTripAndStore({
    required String userId,
    required String travelId,
    required String language,
    required TripPlanRequest request,
  }) async {
    try {
      // 1. Gọi trực tiếp AiBackendService với request object
      final aiTrip = await _apiService.getTripPlan(request);

      // 2. Tạo đối tượng TravelDbModel ban đầu chứa danh sách các từ khóa hình ảnh
      final initialTrip = TravelDbMapper.fromGemini(
        ai: aiTrip,
        userId: userId,
        travelId: travelId,
        language: language,
        request: request,
      );

      // 3. Sử dụng ImageService để lấy các URL hình ảnh thực tế từ Unsplash
      final imageUrls = await _imageService.fetchImages(initialTrip.images);

      // 4. Gán danh sách URL hình ảnh thực tế vào model
      final trip = initialTrip.copyWith(images: imageUrls);

      // 5. Lưu thông tin chuyến đi đã có hình ảnh thực tế vào Firestore
      await _trips.doc(trip.travelId).set({
        ...trip.toMap(),
        'travelId': trip.travelId,
        'userId': userId,
        'language': language,
      }, SetOptions(merge: true));

      return Right(trip);
    } on FirebaseException catch (e) {
      return Left(Failure(e.message ?? 'Firestore error'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}


import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/features/addtrip/models/trip_plan_request.dart';
import 'package:travel_app/features/addtrip/repository/travel_repository.dart';
import 'package:travel_app/features/discovery/repositories/recommendation_repository.dart';
import 'package:travel_app/shared/models/destination_model.dart';
import 'package:uuid/uuid.dart';

import '../../auth/provider/auth_providers.dart';
import '../../settings/provider/settings_provider.dart';
part 'travel_provider.g.dart';


@riverpod
class SubmitLoading extends _$SubmitLoading {
  @override
  bool build() => false;

  void setLoading(bool value) => state = value;
}

@riverpod
Future<String> generateAndStoreTrip(
  Ref ref,
  TripPlanRequest tripPlanRequest,
) async {
  final travelRepository = ref.read(travelRepositoryProvider);
  final userInfo = ref.read(userInfoProvider);
  final locale = await ref.read(languageProvider.future);
  final languageCode = locale.languageCode;

  if (userInfo == null) {
    throw Exception('User not logged in.');
  }

  final userId = userInfo.uid;
  final travelId = const Uuid().v4();

  // Việc build prompt giờ do AI Backend (Python) đảm nhận dựa trên tripPlanRequest
  final result = await travelRepository.generateTripAndStore(
    userId: userId,
    travelId: travelId,
    language: languageCode,
    request: tripPlanRequest,
  );

  return result.fold((l) => throw Exception(l.message), (r) => r.travelId);
}


@riverpod
Stream<List<DestinationModel>> trendingDestinations(Ref ref) {
  return ref.watch(recommendationRepositoryProvider).getTrendingDestinations(limit: 10);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/trip_status.dart';
import '../../../shared/models/travel_db_model.dart';
import '../../addtrip/models/trip_plan_request.dart';
import '../../auth/provider/auth_providers.dart';
import '../../settings/provider/settings_provider.dart';
import '../model/month_this_count.dart';
import '../repository/user_trips_repository.dart';

part 'user_trips_provider.g.dart';

@riverpod
class TripStatusNotifier extends _$TripStatusNotifier {
  @override
  void build() {}

  Future<void> markAsVisited(String travelId) async {
    final repo = ref.read(userTripsRepositoryProvider);
    await repo.updateStatus(travelId, TripStatus.visited);
  }

  Future<void> toggleFavorite(String travelId, bool isFavorite) async {
    final repo = ref.read(userTripsRepositoryProvider);
    await repo.toggleFavorite(travelId, isFavorite);
  }

  Future<void> leaveTrip(String travelId) async {
    final user = ref.read(userInfoProvider);
    if (user == null) return;
    final repo = ref.read(userTripsRepositoryProvider);
    await repo.leaveTrip(travelId, user.uid);
  }

}

@riverpod
Future<void> regenerateTripInCurrentLanguage(Ref ref, String travelId) async {
  final repo = ref.watch(userTripsRepositoryProvider);
  final tripResult = await ref.read(tripByIdProvider(travelId).future);

  final locale = await ref.read(languageProvider.future);
  final languageCode = locale.languageCode;

  // Chuyển đổi TravelDbModel sang TripPlanRequest để gửi cho Backend
  final request = TripPlanRequest(
    userId: tripResult.userId,
    currentLocation: tripResult.currentLocation ?? '',
    destination: tripResult.destination,
    startDate: tripResult.startDate,
    endDate: tripResult.endDate,
    tripType: tripResult.tripType.name,
    budget: double.tryParse(tripResult.budget ?? '0') ?? 0.0,
    budgetType: tripResult.budgetType ?? '',
    currency: languageCode == 'vi' ? 'VND' : 'USD',
    interests: tripResult.interests,
    companions: tripResult.companions ?? '',
    accommodationType: tripResult.accommodationType ?? '',
    transportPreferences: tripResult.transportPreferences ?? '',
    pace: tripResult.pace ?? '',
    food: tripResult.foodPreference ?? '',
    specialRequirements: tripResult.overview,
  );

  await repo.replaceAiTripContent(
    travelId: travelId,
    request: request,
    language: languageCode,
  );
}


@riverpod
Stream<List<TravelDbModel>> userTrips(Ref ref) {
  final user = ref.watch(userInfoProvider);
  if (user == null) return const Stream.empty();

  final repo = ref.watch(userTripsRepositoryProvider);
  return repo.getUserTrips(user.uid).map((trips) {
    // Chỉ lấy những chuyến đi chưa hoàn thành (isVisited == false)
    return trips.where((trip) => !trip.isVisited).toList();
  });
}

@riverpod
Stream<List<TravelDbModel>> joinedTrips(Ref ref) {
  final user = ref.watch(userInfoProvider);
  if (user == null) return const Stream.empty();

  final repo = ref.watch(userTripsRepositoryProvider);
  return repo.getJoinedTrips(user.uid).map((trips) {
    return trips.where((trip) => !trip.isVisited).toList();
  });
}

@riverpod
Future<TravelDbModel> tripById(Ref ref, String travelId) async {
  final repo = ref.watch(userTripsRepositoryProvider);
  final result = await repo.getTripById(travelId);

  return result.fold((f) => throw Exception(f.message), (trip) => trip);
}

@riverpod
Future<void> deleteTrip(Ref ref, String travelId) async {
  final repo = ref.watch(userTripsRepositoryProvider);
  await repo.deleteTrip(travelId);
}

@riverpod
AsyncValue<MonthTripCount> monthTripCount(Ref ref) {
  final tripsAsync = ref.watch(userTripsProvider);

  return tripsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (trips) {
      final now = DateTime.now();

      final thisMonthStart = DateTime(now.year, now.month, 1);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 0);

      final thisMonthCount = trips.where((trip) {
        return trip.startDate.isAfter(thisMonthStart) ||
            trip.startDate.isAtSameMomentAs(thisMonthStart);
      }).length;

      final lastMonthCount = trips.where((trip) {
        return trip.startDate.isAfter(lastMonthStart) &&
            trip.startDate.isBefore(lastMonthEnd);
      }).length;

      return AsyncValue.data(
        MonthTripCount(thisMonth: thisMonthCount, lastMonth: lastMonthCount),
      );
    },
  );
}

@riverpod
Stream<List<TravelDbModel>> visitedTrips(Ref ref) {
  final user = ref.watch(userInfoProvider);
  if (user == null) return const Stream.empty();

  final repo = ref.watch(userTripsRepositoryProvider);
  return repo.getUserTrips(user.uid).map((trips) {
    // Chỉ lấy những chuyến đi đã hoàn thành (isVisited == true)
    return trips.where((trip) => trip.isVisited).toList();
  });
}

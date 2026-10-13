import '../../../core/enums/trip_status.dart';
import '../../../core/enums/trip_type.dart';
import '../../../shared/models/travel_db_model.dart';
import '../models/trip_plan_request.dart';
import '../models/travel_gemini_response.dart';

class TravelDbMapper {
  static TravelDbModel fromGemini({
    required TravelGeminiResponse ai,
    required String userId,
    required String travelId,
    required String language,
    required TripPlanRequest request,
  }) {
    return TravelDbModel(
      travelId: ai.tripId ?? travelId,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: null,
      language: language,
      generatedByAi: true,
      destination: ai.destination,
      destinationLowerCase: ai.destination.toLowerCase(),
      currentLocation: ai.currentLocation,

      currentLat: ai.currentLat,
      currentLng: ai.currentLng,
      destinationLat: ai.destinationLat,
      destinationLng: ai.destinationLng,

      startDate: ai.startDate,
      endDate: ai.endDate,
      overview: ai.overview,
      tripType: TripType.fromString(ai.tripType),
      totalDays: ai.totalDays,
      totalPeople: ai.totalPeople,

      // --- CẢI TIẾN HÌNH ẢNH ---
      // Nếu AI trả về danh sách từ khóa, ta lấy tối đa 5 từ.
      // Nếu rỗng, ta lấy chính 'destination' làm từ khóa để Unsplash vẫn tìm được ảnh đẹp.
      images: (ai.images.isNotEmpty)
          ? ai.images // Ví dụ: ['Hanoi', 'Hoan Kiem Lake', 'Old Quarter']
          : [ai.destination, '${ai.destination} landscape', '${ai.destination} travel'],

      dailyPlan: ai.dailyPlan,
      accommodationSuggestions: ai.accommodationSuggestions,
      transportationDetails: ai.transportationDetails,
      foodRecommendations: ai.foodRecommendations,
      additionalTips: ai.additionalTips,
        budget: ai.budget.trim().isNotEmpty
          ? ai.budget
          : '${request.budget.toStringAsFixed(0)} ${request.currency}',
      budgetType: request.budgetType,
      companions: request.companions,
      accommodationType: request.accommodationType,
      transportPreferences: request.transportPreferences,
      pace: request.pace,
      foodPreference: request.food,
      interests: request.interests,
      isFavorite: false,
      status: TripStatus.planned,
      shareCode: ai.shareCode,
      memberIds: ai.memberIds.isNotEmpty ? ai.memberIds : [userId],
    );
  }
}
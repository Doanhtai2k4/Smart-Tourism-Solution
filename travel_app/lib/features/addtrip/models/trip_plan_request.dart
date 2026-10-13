class TripPlanRequest {
  final String? userId;
  final String currentLocation;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String tripType;
  final double budget;
  final String budgetType;
  final String currency;
  final List<String> interests;
  final String companions;
  final String accommodationType;
  final String transportPreferences;
  final String pace;
  final String food;
  final List<String>? mustVisitPlaceIds;
  final String? specialRequirements;
  final String? ownerName;
  final String? ownerPhoto;
  final bool saveToDatabase;

  TripPlanRequest({
    this.userId,
    required this.currentLocation,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.tripType,
    required this.budget,
    required this.budgetType,
    required this.currency,
    required this.interests,
    required this.companions,
    required this.accommodationType,
    required this.transportPreferences,
    required this.pace,
    required this.food,
    this.mustVisitPlaceIds,
    this.specialRequirements,
    this.ownerName,
    this.ownerPhoto,
    this.saveToDatabase = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'currentLocation': currentLocation,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'tripType': tripType,
      'budget': budget,
      'budgetType': budgetType,
      'currency': currency,
      'interests': interests,
      'companions': companions,
      'accommodationType': accommodationType,
      'transportPreferences': transportPreferences,
      'pace': pace,
      'food': food,
      'mustVisitPlaceIds': mustVisitPlaceIds ?? [],
      'specialRequirements': specialRequirements,
      'ownerName': ownerName,
      'ownerPhoto': ownerPhoto,
      'saveToDatabase': saveToDatabase,
    };
  }

  factory TripPlanRequest.fromMap(Map<String, dynamic> map) {
    // Xử lý an toàn cho DateTime từ JSON String hoặc Firestore Timestamp
    DateTime parseDate(dynamic dateData) {
      if (dateData == null) return DateTime.now();
      if (dateData is DateTime) return dateData;
      if (dateData is String) {
        return DateTime.tryParse(dateData) ?? DateTime.now();
      }
      // Nếu dùng Firebase Firestore, mở comment dòng dưới để xử lý Timestamp:
      // if (dateData.runtimeType.toString() == 'Timestamp') return dateData.toDate();
      return DateTime.now();
    }

    return TripPlanRequest(
      userId: map['userId'] as String?,
      currentLocation: map['currentLocation'] as String? ?? '',
      destination: map['destination'] as String? ?? '',
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      tripType: map['tripType'] as String? ?? '',
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      budgetType: map['budgetType'] as String? ?? '',
      currency: map['currency'] as String? ?? 'USD',
      interests: List<String>.from(map['interests'] ?? []),
      companions: map['companions'] as String? ?? '',
      accommodationType: map['accommodationType'] as String? ?? '',
      transportPreferences: map['transportPreferences'] as String? ?? '',
      pace: map['pace'] as String? ?? '',
      food: map['food'] as String? ?? '',
      mustVisitPlaceIds: List<String>.from(map['mustVisitPlaceIds'] ?? []),
      specialRequirements: map['specialRequirements'] as String?,
      ownerName: map['ownerName'] as String?,
      ownerPhoto: map['ownerPhoto'] as String?,
      saveToDatabase: map['saveToDatabase'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'TripPlanRequest{userId: $userId, currentLocation: $currentLocation, destination: $destination, startDate: $startDate, endDate: $endDate, tripType: $tripType, budget: $budget, budgetType: $budgetType, currency: $currency, interests: $interests, companions: $companions, accommodationType: $accommodationType, transportPreferences: $transportPreferences, pace: $pace, food: $food, mustVisitPlaceIds: $mustVisitPlaceIds, specialRequirements: $specialRequirements, ownerName: $ownerName, ownerPhoto: $ownerPhoto}';
  }

  TripPlanRequest copyWith({
    String? userId,
    String? currentLocation,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? tripType,
    double? budget,
    String? budgetType,
    String? currency,
    List<String>? interests,
    String? companions,
    String? accommodationType,
    String? transportPreferences,
    String? pace,
    String? food,
    List<String>? mustVisitPlaceIds,
    String? specialRequirements,
    String? ownerName,
    String? ownerPhoto,
  }) {
    return TripPlanRequest(
      userId: userId ?? this.userId,
      currentLocation: currentLocation ?? this.currentLocation,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tripType: tripType ?? this.tripType,
      budget: budget ?? this.budget,
      budgetType: budgetType ?? this.budgetType,
      currency: currency ?? this.currency,
      interests: interests ?? this.interests,
      companions: companions ?? this.companions,
      accommodationType: accommodationType ?? this.accommodationType,
      transportPreferences: transportPreferences ?? this.transportPreferences,
      pace: pace ?? this.pace,
      food: food ?? this.food,
      mustVisitPlaceIds: mustVisitPlaceIds ?? this.mustVisitPlaceIds,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      ownerName: ownerName ?? this.ownerName,
      ownerPhoto: ownerPhoto ?? this.ownerPhoto,
    );
  }
}

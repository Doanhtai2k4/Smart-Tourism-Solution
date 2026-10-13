// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_gemini_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravelGeminiResponse _$TravelGeminiResponseFromJson(
  Map<String, dynamic> json,
) => TravelGeminiResponse(
  destination: json['destination'] as String,
  currentLocation: json['currentLocation'] as String,
  destinationLat: (json['destinationLat'] as num).toDouble(),
  destinationLng: (json['destinationLng'] as num).toDouble(),
  currentLat: (json['currentLat'] as num).toDouble(),
  currentLng: (json['currentLng'] as num).toDouble(),
  startDate: TravelGeminiResponse._dateTimeFromString(json['startDate']),
  endDate: TravelGeminiResponse._dateTimeFromString(json['endDate']),
  overview: json['overview'] as String,
  tripType: json['tripType'] as String,
  totalDays: (json['totalDays'] as num).toInt(),
  totalPeople: (json['totalPeople'] as num).toInt(),
  dailyPlan:
      (json['dailyPlan'] as List<dynamic>?)
          ?.map((e) => DayPlan.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  accommodationSuggestions:
      (json['accommodationSuggestions'] as List<dynamic>?)
          ?.map(
            (e) => AccommodationSuggestion.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  transportationDetails: TravelGeminiResponse._transportationDetailsFromJson(
    json['transportationDetails'] as Map<String, dynamic>?,
  ),
  foodRecommendations:
      (json['foodRecommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  additionalTips:
      (json['additionalTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  budget: json['budget'] == null
      ? ''
      : TravelGeminiResponse._budgetFromJson(json['budget']),
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  tripId: json['trip_id'] as String?,
  shareCode: json['share_code'] as String?,
  memberIds:
      (json['member_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$TravelGeminiResponseToJson(
  TravelGeminiResponse instance,
) => <String, dynamic>{
  'destination': instance.destination,
  'currentLocation': instance.currentLocation,
  'destinationLat': instance.destinationLat,
  'destinationLng': instance.destinationLng,
  'currentLat': instance.currentLat,
  'currentLng': instance.currentLng,
  'startDate': TravelGeminiResponse._dateTimeToString(instance.startDate),
  'endDate': TravelGeminiResponse._dateTimeToString(instance.endDate),
  'overview': instance.overview,
  'tripType': instance.tripType,
  'totalDays': instance.totalDays,
  'totalPeople': instance.totalPeople,
  'images': instance.images,
  'dailyPlan': instance.dailyPlan.map((e) => e.toJson()).toList(),
  'accommodationSuggestions': instance.accommodationSuggestions
      .map((e) => e.toJson())
      .toList(),
  'transportationDetails': instance.transportationDetails.toJson(),
  'foodRecommendations': instance.foodRecommendations,
  'additionalTips': instance.additionalTips,
  'budget': instance.budget,
  'trip_id': instance.tripId,
  'share_code': instance.shareCode,
  'member_ids': instance.memberIds,
};

DayPlan _$DayPlanFromJson(Map<String, dynamic> json) => DayPlan(
  day: (json['day'] as num).toInt(),
  date: DayPlan._dateTimeFromFirestore(json['date']),
  activities:
      (json['activities'] as List<dynamic>?)
          ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$DayPlanToJson(DayPlan instance) => <String, dynamic>{
  'day': instance.day,
  'date': DayPlan._dateTimeToFirestore(instance.date),
  'activities': instance.activities.map((e) => e.toJson()).toList(),
};

AccommodationSuggestion _$AccommodationSuggestionFromJson(
  Map<String, dynamic> json,
) => AccommodationSuggestion(
  name: json['name'] as String,
  type: json['type'] as String,
  location: json['location'] as String,
  priceRange: json['priceRange'] as String,
);

Map<String, dynamic> _$AccommodationSuggestionToJson(
  AccommodationSuggestion instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'location': instance.location,
  'priceRange': instance.priceRange,
};

TransportationDetails _$TransportationDetailsFromJson(
  Map<String, dynamic> json,
) => TransportationDetails(
  localTransport: json['localTransport'] as String,
  tips: json['tips'] as String,
);

Map<String, dynamic> _$TransportationDetailsToJson(
  TransportationDetails instance,
) => <String, dynamic>{
  'localTransport': instance.localTransport,
  'tips': instance.tips,
};

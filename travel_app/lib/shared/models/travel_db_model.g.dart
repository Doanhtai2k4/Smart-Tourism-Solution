// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_db_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravelDbModel _$TravelDbModelFromJson(
  Map<String, dynamic> json,
) => TravelDbModel(
  travelId: json['travelId'] as String,
  userId: json['userId'] as String,
  createdAt: TravelDbModel._dateTimeFromTimestamp(json['createdAt']),
  destination: json['destination'] as String,
  destinationLowerCase: json['destinationLowerCase'] as String,
  currentLocation: json['currentLocation'] as String?,
  currentLat: (json['currentLat'] as num?)?.toDouble(),
  currentLng: (json['currentLng'] as num?)?.toDouble(),
  destinationLat: (json['destinationLat'] as num?)?.toDouble(),
  destinationLng: (json['destinationLng'] as num?)?.toDouble(),
  startDate: TravelDbModel._dateTimeFromString(json['startDate']),
  endDate: TravelDbModel._dateTimeFromString(json['endDate']),
  overview: json['overview'] as String?,
  tripType: TripType.fromString(json['tripType'] as String?),
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  totalDays: (json['totalDays'] as num).toInt(),
  totalPeople: (json['totalPeople'] as num).toInt(),
  dailyPlan:
      (json['dailyPlan'] as List<dynamic>?)
          ?.map((e) => DayPlan.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  accommodationSuggestions:
      (json['accommodationSuggestions'] as List<dynamic>?)
          ?.map(
            (e) => AccommodationSuggestion.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  transportationDetails: TransportationDetails.fromJson(
    json['transportationDetails'] as Map<String, dynamic>,
  ),
  foodRecommendations:
      (json['foodRecommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  additionalTips:
      (json['additionalTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  budget: json['budget'] as String?,
  budgetType: json['budgetType'] as String?,
  companions: json['companions'] as String?,
  accommodationType: json['accommodationType'] as String?,
  transportPreferences: json['transportPreferences'] as String?,
  pace: json['pace'] as String?,
  foodPreference: json['foodPreference'] as String?,
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isFavorite: json['isFavorite'] as bool? ?? false,
  isVisited: json['isVisited'] as bool? ?? false,
  status: TravelDbModel._tripStatusFromJson(json['status'] as String?),
  visitedAt: TravelDbModel._dateTimeFromTimestampNullable(json['visitedAt']),
  updatedAt: TravelDbModel._dateTimeFromTimestampNullable(json['updatedAt']),
  language: json['language'] as String,
  generatedByAi: json['generatedByAi'] as bool,
  packingList: (json['packing_list'] as List<dynamic>?)
      ?.map((e) => PackingCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
  shareCode: json['share_code'] as String?,
  memberIds:
      (json['member_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  ownerName: json['ownerName'] as String?,
  ownerPhoto: json['ownerPhoto'] as String?,
);

Map<String, dynamic> _$TravelDbModelToJson(
  TravelDbModel instance,
) => <String, dynamic>{
  'travelId': instance.travelId,
  'userId': instance.userId,
  'createdAt': TravelDbModel._dateTimeToTimestamp(instance.createdAt),
  'updatedAt': TravelDbModel._dateTimeToTimestampNullable(instance.updatedAt),
  'destination': instance.destination,
  'destinationLowerCase': instance.destinationLowerCase,
  'currentLocation': instance.currentLocation,
  'currentLat': instance.currentLat,
  'currentLng': instance.currentLng,
  'destinationLat': instance.destinationLat,
  'destinationLng': instance.destinationLng,
  'startDate': TravelDbModel._dateTimeToString(instance.startDate),
  'endDate': TravelDbModel._dateTimeToString(instance.endDate),
  'overview': instance.overview,
  'tripType': TravelDbModel._tripTypeToJson(instance.tripType),
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
  'budgetType': instance.budgetType,
  'companions': instance.companions,
  'accommodationType': instance.accommodationType,
  'transportPreferences': instance.transportPreferences,
  'pace': instance.pace,
  'foodPreference': instance.foodPreference,
  'interests': instance.interests,
  'isFavorite': instance.isFavorite,
  'isVisited': instance.isVisited,
  'language': instance.language,
  'generatedByAi': instance.generatedByAi,
  'packing_list': instance.packingList?.map((e) => e.toJson()).toList(),
  'share_code': instance.shareCode,
  'member_ids': instance.memberIds,
  'status': TravelDbModel._tripStatusToJson(instance.status),
  'visitedAt': TravelDbModel._dateTimeToTimestampNullable(instance.visitedAt),
  'ownerName': instance.ownerName,
  'ownerPhoto': instance.ownerPhoto,
};

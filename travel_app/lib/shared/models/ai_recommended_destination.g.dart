// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_recommended_destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIRecommendedDestination _$AIRecommendedDestinationFromJson(
  Map<String, dynamic> json,
) => AIRecommendedDestination(
  id: json['id'] as String,
  name: json['name'] as String,
  province: json['province'] as String,
  imageQuery: json['imageQuery'] as String,
  weatherCondition: json['weatherCondition'] as String,
  upcomingEvent: json['upcomingEvent'] as String?,
  bestTimeToVisit: json['bestTimeToVisit'] as String,
  matchScore: (json['matchScore'] as num).toInt(),
  aiReason: json['aiReason'] as String,
  topActivities:
      (json['topActivities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  budgetLevel: json['budgetLevel'] as String,
  idealDuration: json['idealDuration'] as String,
);

Map<String, dynamic> _$AIRecommendedDestinationToJson(
  AIRecommendedDestination instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'province': instance.province,
  'imageQuery': instance.imageQuery,
  'weatherCondition': instance.weatherCondition,
  'upcomingEvent': instance.upcomingEvent,
  'bestTimeToVisit': instance.bestTimeToVisit,
  'matchScore': instance.matchScore,
  'aiReason': instance.aiReason,
  'topActivities': instance.topActivities,
  'budgetLevel': instance.budgetLevel,
  'idealDuration': instance.idealDuration,
};

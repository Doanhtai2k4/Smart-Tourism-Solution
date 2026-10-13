// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DestinationModel _$DestinationModelFromJson(Map<String, dynamic> json) =>
    DestinationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      category: json['category'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      country: json['country'] as String? ?? 'Việt Nam',
      province: json['province'] as String?,
      trendingScore: (json['trendingScore'] as num?)?.toInt() ?? 0,
      nameLowerCase: json['nameLowerCase'] as String,
      createdAt: DestinationModel._dateTimeFromTimestamp(
        json['createdAt'] as Timestamp?,
      ),
      updatedAt: DestinationModel._dateTimeFromTimestamp(
        json['updatedAt'] as Timestamp?,
      ),
      suitableFor:
          (json['suitableFor'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
      ticketPrice: (json['ticketPrice'] as num?)?.toInt(),
      address: json['address'] as String?,
      imageQuery: json['imageQuery'] as String?,
      weatherCondition: json['weatherCondition'] as String?,
      upcomingEvent: json['upcomingEvent'] as String?,
      bestTimeToVisit:
          (json['bestTimeToVisit'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['Quanh năm'],
      topActivities:
          (json['topActivities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      budgetLevel: json['budgetLevel'] as String?,
      idealDuration: (json['idealDuration'] as num?)?.toInt(),
      searchKeywords:
          (json['searchKeywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DestinationModelToJson(DestinationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'images': instance.images,
      'tags': instance.tags,
      'averageRating': instance.averageRating,
      'ratingCount': instance.ratingCount,
      'category': instance.category,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'country': instance.country,
      'province': instance.province,
      'trendingScore': instance.trendingScore,
      'nameLowerCase': instance.nameLowerCase,
      'createdAt': DestinationModel._dateTimeToTimestamp(instance.createdAt),
      'updatedAt': DestinationModel._dateTimeToTimestamp(instance.updatedAt),
      'suitableFor': instance.suitableFor,
      'viewCount': instance.viewCount,
      'favoriteCount': instance.favoriteCount,
      'ticketPrice': instance.ticketPrice,
      'address': instance.address,
      'imageQuery': instance.imageQuery,
      'weatherCondition': instance.weatherCondition,
      'upcomingEvent': instance.upcomingEvent,
      'bestTimeToVisit': instance.bestTimeToVisit,
      'topActivities': instance.topActivities,
      'budgetLevel': instance.budgetLevel,
      'idealDuration': instance.idealDuration,
      'searchKeywords': instance.searchKeywords,
    };

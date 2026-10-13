import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:travel_app/features/addtrip/models/travel_gemini_response.dart';
import 'package:travel_app/features/packing/models/packing_model.dart';

import '../../core/enums/trip_status.dart';
import '../../core/enums/trip_type.dart';

part 'travel_db_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TravelDbModel extends Equatable {
  final String travelId;
  final String userId;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;
  @JsonKey(
    fromJson: _dateTimeFromTimestampNullable,
    toJson: _dateTimeToTimestampNullable,
  )
  final DateTime? updatedAt;
  final String destination;
  final String destinationLowerCase;
  final String? currentLocation;
  final double? currentLat;
  final double? currentLng;
  final double? destinationLat;
  final double? destinationLng;
  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime startDate;
  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime endDate;
  final String? overview;
  @JsonKey(fromJson: TripType.fromString, toJson: _tripTypeToJson)
  final TripType tripType;
  final int totalDays;
  final int totalPeople;
  final List<String> images;
  final List<DayPlan> dailyPlan;
  final List<AccommodationSuggestion> accommodationSuggestions;
  final TransportationDetails transportationDetails;
  final List<String> foodRecommendations;
  final List<String> additionalTips;
  final String? budget;
  final String? budgetType;
  final String? companions;
  final String? accommodationType;
  final String? transportPreferences;
  final String? pace;
  final String? foodPreference;
  final List<String> interests;
  final bool isFavorite;
  final bool isVisited;
  final String language;
  final bool generatedByAi;

  @JsonKey(name: 'packing_list')
  final List<PackingCategory>? packingList;

  @JsonKey(name: 'share_code')
  final String? shareCode;
  @JsonKey(name: 'member_ids')
  final List<String> memberIds;

  @JsonKey(fromJson: _tripStatusFromJson, toJson: _tripStatusToJson)
  final TripStatus status;

  @JsonKey(
    fromJson: _dateTimeFromTimestampNullable,
    toJson: _dateTimeToTimestampNullable,
  )
  final DateTime? visitedAt;

  final String? ownerName;
  final String? ownerPhoto;

  const TravelDbModel({
    required this.travelId,
    required this.userId,
    required this.createdAt,
    required this.destination,
    required this.destinationLowerCase,
    this.currentLocation,
    this.currentLat,
    this.currentLng,
    this.destinationLat,
    this.destinationLng,
    required this.startDate,
    required this.endDate,
    this.overview,
    required this.tripType,
    this.images = const [],
    required this.totalDays,
    required this.totalPeople,
    this.dailyPlan = const [],
    this.accommodationSuggestions = const [],
    required this.transportationDetails,
    this.foodRecommendations = const [],
    this.additionalTips = const [],
    this.budget,
    this.budgetType,
    this.companions,
    this.accommodationType,
    this.transportPreferences,
    this.pace,
    this.foodPreference,
    this.interests = const [],
    this.isFavorite = false,
    this.isVisited = false,
    required this.status,
    this.visitedAt,
    this.updatedAt,
    required this.language,
    required this.generatedByAi,
    this.packingList,
    this.shareCode,
    this.memberIds = const [],
    this.ownerName,
    this.ownerPhoto,
  });

  factory TravelDbModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$TravelDbModelFromJson({
        ...json,

        'travelId': json['travelId'] ?? json['trip_id'] ?? '',
        'userId': json['userId'] ?? '',
        'totalDays': json['totalDays'] ?? json['total_days'] ?? 1,
        'totalPeople': json['totalPeople'] ?? json['total_people'] ?? 1,
        'language': json['language'] ?? 'en',
        'destination': json['destination'] ?? '',
        'destinationLowerCase':
            json['destinationLowerCase'] ??
            (json['destination'] as String? ?? '').toLowerCase(),
        'currentLocation': json['currentLocation'] ?? '',
        'overview': json['overview'] ?? '',
        'tripType': json['tripType'] ?? TripType.adventure.name,
        'budget': json['budget'] ?? '',
        'currentLat': (json['currentLat'] as num?)?.toDouble() ?? 0.0,
        'currentLng': (json['currentLng'] as num?)?.toDouble() ?? 0.0,
        'destinationLat': (json['destinationLat'] as num?)?.toDouble() ?? 0.0,
        'destinationLng': (json['destinationLng'] as num?)?.toDouble() ?? 0.0,
        'transportationDetails': json['transportationDetails'] ?? {
          'localTransport': '',
          'tips': ''
        },
        'images':
            (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
        'isFavorite': json['isFavorite'] ?? false,
        'isVisited': json['isVisited'] ?? false,
        'generatedByAi': json['generatedByAi'] ?? false,
        'status': json['status'] ?? TripStatus.planned.name,
        'budgetType': json['budgetType'] ?? '',
        'companions': json['companions'] ?? '',
        'ownerName': json['ownerName'] ?? '',
        'ownerPhoto': json['ownerPhoto'] ?? '',
        'accommodationType': json['accommodationType'] ?? '',
        'transportPreferences': json['transportPreferences'] ?? '',
        'pace': json['pace'] ?? '',
        'foodPreference': json['foodPreference'] ?? '',
        'interests':
            (json['interests'] as List?)?.map((e) => e.toString()).toList() ??
            [],
        'packing_list': json['packing_list'] ?? json['packingList'],
        'share_code': json['share_code'] ?? json['shareCode'],
        'member_ids': json['member_ids'] ?? json['memberIds'] ?? [],
      });
    } catch (e, s) {
      debugPrint('TravelDbModel parse error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  Map<String, dynamic> toMap() => _$TravelDbModelToJson(this);

  @override
  List<Object?> get props => [
    travelId,
    userId,
    createdAt,
    updatedAt,
    destination,
    destinationLowerCase,
    currentLocation,
    currentLat,
    currentLng,
    destinationLat,
    destinationLng,
    startDate,
    endDate,
    overview,
    tripType,
    totalDays,
    totalPeople,
    dailyPlan,
    accommodationSuggestions,
    transportationDetails,
    foodRecommendations,
    additionalTips,
    budget,
    images,
    isFavorite,
    isVisited,
    status,
    visitedAt,
    language,
    generatedByAi,
    budgetType,
    companions,
    accommodationType,
    transportPreferences,
    pace,
    foodPreference,
    interests,
    packingList,
    shareCode,
    memberIds,
    ownerName,
    ownerPhoto,
  ];

  TravelDbModel copyWith({
    String? travelId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? destination,
    String? destinationLowerCase,
    String? currentLocation,
    double? currentLat,
    double? currentLng,
    double? destinationLat,
    double? destinationLng,
    DateTime? startDate,
    DateTime? endDate,
    String? overview,
    TripType? tripType,
    int? totalDays,
    int? totalPeople,
    List<String>? images,
    List<DayPlan>? dailyPlan,
    List<AccommodationSuggestion>? accommodationSuggestions,
    TransportationDetails? transportationDetails,
    List<String>? foodRecommendations,
    List<String>? additionalTips,
    String? budget,
    String? budgetType,
    String? companions,
    String? accommodationType,
    String? transportPreferences,
    String? pace,
    String? foodPreference,
    List<String>? interests,
    bool? isFavorite,
    bool? isVisited,
    TripStatus? status,
    DateTime? visitedAt,
    String? language,
    bool? generatedByAi,
    List<PackingCategory>? packingList,
    String? shareCode,
    List<String>? memberIds,
    String? ownerName,
    String? ownerPhoto,
  }) {
    return TravelDbModel(
      travelId: travelId ?? this.travelId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      destination: destination ?? this.destination,
      destinationLowerCase: destinationLowerCase ?? this.destinationLowerCase,
      currentLocation: currentLocation ?? this.currentLocation,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      overview: overview ?? this.overview,
      tripType: tripType ?? this.tripType,
      totalDays: totalDays ?? this.totalDays,
      totalPeople: totalPeople ?? this.totalPeople,
      images: images ?? this.images,
      dailyPlan: dailyPlan ?? this.dailyPlan,
      accommodationSuggestions: accommodationSuggestions ?? this.accommodationSuggestions,
      transportationDetails: transportationDetails ?? this.transportationDetails,
      foodRecommendations: foodRecommendations ?? this.foodRecommendations,
      additionalTips: additionalTips ?? this.additionalTips,
      budget: budget ?? this.budget,
      budgetType: budgetType ?? this.budgetType,
      companions: companions ?? this.companions,
      accommodationType: accommodationType ?? this.accommodationType,
      transportPreferences: transportPreferences ?? this.transportPreferences,
      pace: pace ?? this.pace,
      foodPreference: foodPreference ?? this.foodPreference,
      interests: interests ?? this.interests,
      isFavorite: isFavorite ?? this.isFavorite,
      isVisited: isVisited ?? this.isVisited,
      status: status ?? this.status,
      visitedAt: visitedAt ?? this.visitedAt,
      language: language ?? this.language,
      generatedByAi: generatedByAi ?? this.generatedByAi,
      packingList: packingList ?? this.packingList,
      shareCode: shareCode ?? this.shareCode,
      memberIds: memberIds ?? this.memberIds,
      ownerName: ownerName ?? this.ownerName,
      ownerPhoto: ownerPhoto ?? this.ownerPhoto,
    );
  }

  static TripStatus _tripStatusFromJson(String? value) =>
      TripStatus.values.byName(value ?? TripStatus.planned.name);

  static String _tripStatusToJson(TripStatus status) => status.name;

  static DateTime _dateTimeFromString(dynamic date) {
    if (date is String && date.isNotEmpty) return DateTime.parse(date);
    if (date is Timestamp) return date.toDate();
    return DateTime.now();
  }

  static String _dateTimeToString(DateTime date) => date.toIso8601String();

  static DateTime _dateTimeFromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.tryParse(timestamp) ?? DateTime.now();
    return DateTime.now();
  }

  static Timestamp _dateTimeToTimestamp(DateTime date) =>
      Timestamp.fromDate(date);

  static DateTime? _dateTimeFromTimestampNullable(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }

  static Timestamp? _dateTimeToTimestampNullable(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;

  static String _tripTypeToJson(TripType value) => value.name;
}

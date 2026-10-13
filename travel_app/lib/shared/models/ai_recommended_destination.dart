import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_recommended_destination.g.dart';

@JsonSerializable(explicitToJson: true)
class AIRecommendedDestination extends Equatable {
  final String id;
  final String name;
  final String province;
  final String imageQuery;

  // Context
  final String weatherCondition;
  final String? upcomingEvent;
  final String bestTimeToVisit;

  // AI Personalized
  final int matchScore;
  final String aiReason;
  final List<String> topActivities;

  // Logistics
  final String budgetLevel;
  final String idealDuration;

  const AIRecommendedDestination({
    required this.id,
    required this.name,
    required this.province,
    required this.imageQuery,
    required this.weatherCondition,
    this.upcomingEvent,
    required this.bestTimeToVisit,
    required this.matchScore,
    required this.aiReason,
    this.topActivities = const [],
    required this.budgetLevel,
    required this.idealDuration,
  });

  factory AIRecommendedDestination.fromJson(Map<String, dynamic> json) {
    try {
      return _$AIRecommendedDestinationFromJson({
        ...json,
        'id': json['id'] ?? '',
        'name': json['name'] ?? '',
        'province': json['province'] ?? '',
        'imageQuery': json['imageQuery'] ?? '',
        'weatherCondition': json['weatherCondition'] ?? '',
        // upcomingEvent can be null, so no fallback needed here unless requested
        'bestTimeToVisit': json['bestTimeToVisit'] ?? '',
        'matchScore': (json['matchScore'] as num?)?.toInt() ?? 0,
        'aiReason': json['aiReason'] ?? '',
        'topActivities': (json['topActivities'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        'budgetLevel': json['budgetLevel'] ?? '',
        'idealDuration': json['idealDuration'] ?? '',
      });
    } catch (e, s) {
      debugPrint('AIRecommendedDestination parse error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  Map<String, dynamic> toMap() => _$AIRecommendedDestinationToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        province,
        imageQuery,
        weatherCondition,
        upcomingEvent,
        bestTimeToVisit,
        matchScore,
        aiReason,
        topActivities,
        budgetLevel,
        idealDuration,
      ];
}

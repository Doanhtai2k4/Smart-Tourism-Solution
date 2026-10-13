import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'travel_gemini_response.g.dart';

@JsonSerializable(explicitToJson: true)
class TravelGeminiResponse extends Equatable {
  final String destination;
  final String currentLocation;
  final double destinationLat;
  final double destinationLng;
  final double currentLat;
  final double currentLng;
  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime startDate;
  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime endDate;
  final String overview;
  final String tripType;
  final int totalDays;
  final int totalPeople;
  @JsonKey(defaultValue: [])
  final List<String> images;
  @JsonKey(defaultValue: [])
  final List<DayPlan> dailyPlan;
  @JsonKey(defaultValue: [])
  final List<AccommodationSuggestion> accommodationSuggestions;
  @JsonKey(fromJson: _transportationDetailsFromJson)
  final TransportationDetails transportationDetails;
  @JsonKey(defaultValue: [])
  final List<String> foodRecommendations;
  @JsonKey(defaultValue: [])
  final List<String> additionalTips;
  @JsonKey(defaultValue: '', fromJson: _budgetFromJson)
  final String budget;
  @JsonKey(name: 'trip_id')
  final String? tripId;
  @JsonKey(name: 'share_code')
  final String? shareCode;
  @JsonKey(name: 'member_ids', defaultValue: [])
  final List<String> memberIds;

  const TravelGeminiResponse({
    required this.destination,
    required this.currentLocation,
    required this.destinationLat,
    required this.destinationLng,
    required this.currentLat,
    required this.currentLng,
    required this.startDate,
    required this.endDate,
    required this.overview,
    required this.tripType,
    required this.totalDays,
    required this.totalPeople,
    required this.dailyPlan,
    required this.accommodationSuggestions,
    required this.transportationDetails,
    required this.foodRecommendations,
    required this.additionalTips,
    required this.budget,
    required this.images,
    this.tripId,
    this.shareCode,
    this.memberIds = const [],
  });

  factory TravelGeminiResponse.fromJson(Map<String, dynamic> json) =>
      _$TravelGeminiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TravelGeminiResponseToJson(this);

  @override
  List<Object?> get props => [destination, overview, dailyPlan, tripId, shareCode, memberIds];

  static DateTime _dateTimeFromString(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  static String _budgetFromJson(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String _dateTimeToString(DateTime date) => date.toIso8601String();

  static TransportationDetails _transportationDetailsFromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return const TransportationDetails(localTransport: '', tips: '');
    }
    return TransportationDetails.fromJson(json);
  }
}

@JsonSerializable(explicitToJson: true)
class DayPlan {
  final int day;
  @JsonKey(fromJson: _dateTimeFromFirestore, toJson: _dateTimeToFirestore)
  final DateTime date;
  @JsonKey(defaultValue: [])
  final List<Activity> activities;

  const DayPlan({required this.day, required this.date, required this.activities});

  factory DayPlan.fromJson(Map<String, dynamic> json) =>
      _$DayPlanFromJson(json);

  Map<String, dynamic> toJson() => _$DayPlanToJson(this);

  static DateTime _dateTimeFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now(); // Fallback
  }

  static Timestamp _dateTimeToFirestore(DateTime date) =>
      Timestamp.fromDate(date);
}

class Activity {
  final String time;
  final String title;
  final String? destinationId;
  final String description;
  final String? type;
  final String? reasoning;

  const Activity({
    required this.time,
    required this.title,
    this.destinationId,
    required this.description,
    this.type,
    this.reasoning,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        time: json['time'] as String? ?? '00:00',
        title: json['title'] as String? ?? 'Hoạt động',
        destinationId: json['destinationId'] as String?,
        description: json['description'] as String? ?? 'Không có mô tả',
        type: json['type'] as String?,
        reasoning: json['reasoning'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'time': time,
        'title': title,
        'destinationId': destinationId,
        'description': description,
        if (type != null) 'type': type,
        if (reasoning != null) 'reasoning': reasoning,
      };
}

@JsonSerializable(explicitToJson: true)
class AccommodationSuggestion {
  final String name;
  final String type;
  final String location;
  final String priceRange;

  const AccommodationSuggestion({
    required this.name,
    required this.type,
    required this.location,
    required this.priceRange,
  });

  factory AccommodationSuggestion.fromJson(Map<String, dynamic> json) =>
      AccommodationSuggestion(
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? 'Chưa cập nhật',
        location: json['location'] as String? ?? 'Chưa cập nhật',
        priceRange: json['priceRange'] ?? json['price_range'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => _$AccommodationSuggestionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TransportationDetails {
  final String localTransport;
  final String tips;

  const TransportationDetails({required this.localTransport, required this.tips});

  factory TransportationDetails.fromJson(Map<String, dynamic> json) =>
      TransportationDetails(
        localTransport: json['localTransport'] as String? ?? json['local_transport'] as String? ?? '',
        tips: json['tips'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => _$TransportationDetailsToJson(this);
}

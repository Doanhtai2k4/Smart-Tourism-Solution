import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'destination_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DestinationModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final List<String> tags; // ví dụ: ['biền', 'văn hóa', 'núi']
  final double averageRating;
  final int ratingCount;
  final String? category; // Primary category (Optional)
  final double? latitude;
  final double? longitude;
  final String country;
  final String? province; // Tỉnh/Thành phố
  final int trendingScore; // Điểm trending theo thời gian thực
  final String nameLowerCase; // Hỗ trợ tìm kiếm prefix

  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime updatedAt;

  // New fields for updated Data Schema
  final List<String> suitableFor; // Phù hợp cho (Cặp đôi, Gia đình,...)
  final int viewCount; // Lượt xem
  final int favoriteCount; // Lượt yêu thích
  final int? ticketPrice; // Giá vé tham khảo
  final String? address; // Địa chỉ chi tiết

  // AI-generated & Contextual fields
  final String? imageQuery; // English keyword for Unsplash
  final String? weatherCondition; // Seasonal weather status
  final String? upcomingEvent; // Specific festival/event
  final List<String> bestTimeToVisit; // Thời điểm nên đi (List<String> cho phép nhiều mùa)
  final List<String> topActivities; // Characteristic activities
  final String? budgetLevel; // Cost level ($, $$, $$$ or description)
  final int? idealDuration; // Ideal stay duration (days)
  final List<String> searchKeywords; // Optimized search terms

  const DestinationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.tags,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.category,
    this.latitude,
    this.longitude,
    this.country = 'Việt Nam',
    this.province,
    this.trendingScore = 0,
    required this.nameLowerCase,
    required this.createdAt,
    required this.updatedAt,
    this.suitableFor = const [],
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.ticketPrice,
    this.address,
    this.imageQuery,
    this.weatherCondition,
    this.upcomingEvent,
    this.bestTimeToVisit = const ['Quanh năm'],
    this.topActivities = const [],
    this.budgetLevel,
    this.idealDuration,
    this.searchKeywords = const [],
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) =>
      _$DestinationModelFromJson(json);

  Map<String, dynamic> toJson() => _$DestinationModelToJson(this);

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final map = toJson();
    map.remove('id'); // Remove id as it's typically the doc ref ID
    return map;
  }

  /// Create from Firestore document (Safe Parsing)
  factory DestinationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return DestinationModel(
      id: id,
      name: data['name'] as String? ?? 'Địa điểm không tên',
      description: data['description'] as String? ?? '',
      images: List<String>.from(data['images'] as List? ?? []),
      tags: List<String>.from(data['tags'] as List? ?? []),
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? (data['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? (data['reviewCount'] as num?)?.toInt() ?? 0,
      category: data['category'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      country: data['country'] as String? ?? 'Việt Nam',
      province: data['province'] as String?,
      trendingScore: (data['trendingScore'] as num?)?.toInt() ?? 0,
      nameLowerCase: data['nameLowerCase'] as String? ?? (data['name'] as String? ?? '').toLowerCase(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // New Schema Fields
      suitableFor: List<String>.from(data['suitableFor'] as List? ?? []),
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      favoriteCount: (data['favoriteCount'] as num?)?.toInt() ?? 0,
      ticketPrice: (data['ticketPrice'] as num?)?.toInt(),
      address: data['address'] as String?,
      // Contextual fields
      imageQuery: data['imageQuery'] as String?,
      weatherCondition: data['weatherCondition'] as String?,
      upcomingEvent: data['upcomingEvent'] as String?,
      bestTimeToVisit: List<String>.from(data['bestTimeToVisit'] as List? ?? ['Quanh năm']),
      topActivities: List<String>.from(data['topActivities'] as List? ?? []),
      budgetLevel: data['budgetLevel'] as String?,
      idealDuration: (data['idealDuration'] as num?)?.toInt(),
      searchKeywords: List<String>.from(data['searchKeywords'] as List? ?? []),
    );
  }

  /// Getter for display location: "Tỉnh, Quốc gia" OR only "Tỉnh" OR only "Quốc gia"
  String get displayLocation {
    final provStr = province?.isNotEmpty == true ? province! : '';
    if (provStr.isEmpty) return country;
    return '$provStr, $country';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        images,
        tags,
        averageRating,
        ratingCount,
        category,
        latitude,
        longitude,
        country,
        province,
        trendingScore,
        nameLowerCase,
        createdAt,
        updatedAt,
        suitableFor,
        viewCount,
        favoriteCount,
        ticketPrice,
        address,
        imageQuery,
        weatherCondition,
        upcomingEvent,
        bestTimeToVisit,
        topActivities,
        budgetLevel,
        idealDuration,
        searchKeywords,
      ];

  static DateTime _dateTimeFromTimestamp(Timestamp? timestamp) =>
      timestamp?.toDate() ?? DateTime.now();

  static Timestamp _dateTimeToTimestamp(DateTime date) =>
      Timestamp.fromDate(date);
}

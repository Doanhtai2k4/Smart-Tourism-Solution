import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travel_app/core/services/ml_recommendation_service.dart';
import 'package:travel_app/core/services/realtime_recommender_service.dart';
import 'package:travel_app/core/services/location_service.dart';
import 'package:travel_app/core/services/weather_service.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import 'package:travel_app/features/discovery/repositories/recommendation_repository.dart';
import 'package:travel_app/shared/models/destination_model.dart';
import 'package:travel_app/shared/models/ai_recommendation_result.dart';

export 'package:travel_app/shared/models/ai_recommendation_result.dart';

part 'discovery_providers.g.dart';

/// Tier 1: Trending Destinations (Real-time from Firestore)
@riverpod
Stream<List<DestinationModel>> trendingDestinations(Ref ref) {
  final repo = ref.watch(recommendationRepositoryProvider);
  return repo.getTrendingDestinations(limit: 10);
}

/// Provider cho danh sách địa điểm (Catalog) từ Firestore
/// Lấy toàn bộ catalog để thuật toán re-ranking có đủ dữ liệu.
@riverpod
Future<List<DestinationModel>> catalogDestinations(Ref ref) async {
  final repo = ref.watch(recommendationRepositoryProvider);
  // Giới hạn 500 — đủ lớn để cover toàn bộ DB hiện tại mà không gây memory issue.
  // SliverList.builder trong UI đảm bảo render lazy (không load tất cả vào widget tree cùng lúc).
  return repo.getCatalogDestinations(limit: 500);
}

/// Tier 2: Real-time For You (In-session behavior focus + Immediate Context + ML Segment)
@riverpod
Future<List<DestinationModel>> realtimeDestinations(Ref ref) async {
  // Watch state (Map<String,double>) directly — rebuilds when preferences change
  final preferences = ref.watch(realtimeRecommenderProvider);
  final userPosition = ref.watch(locationServiceProvider).asData?.value;
  final currentWeather = ref.watch(weatherServiceProvider);
  final user = ref.watch(userInfoProvider);
  
  // Fetch candidate pool
  final List<DestinationModel> pool = await ref.watch(catalogDestinationsProvider.future);
  if (pool.isEmpty) return [];

  // Score primarily on short-term interest, context and K-Means segments
  final List<Map<String, dynamic>> scored = pool.map((dest) {
    double score = 0.0;
    
    // Factor 1: Short-term Interest (SESSION FOCUS) — scores using live preferences map
    double interestScore = 0.0;
    final category = dest.category ?? 'Uncategorized';
    if (preferences.containsKey(category)) {
      interestScore += preferences[category]!;
    }
    for (final tag in dest.tags) {
      if (preferences.containsKey(tag)) {
        interestScore += preferences[tag]!;
      }
    }
    score += interestScore * 2.0; // Double weight for in-session clicks

    // Factor 2: Immediate Context (Weather, Proximity)
    final destLat = dest.latitude;
    final destLng = dest.longitude;
    if (userPosition != null && destLat != null && destLng != null) {
      final double distance = Geolocator.distanceBetween(
        userPosition.latitude, userPosition.longitude, destLat, destLng);
      if (distance < 50000) score += 8.0; // 50km boost
    }

    if (dest.weatherCondition?.toLowerCase().contains(currentWeather.label.toLowerCase()) ?? false) {
      score += 5.0;
    }

    if (dest.upcomingEvent != null && dest.upcomingEvent!.isNotEmpty) {
      score += 10.0;
    }

    // Factor 3: Baseline popularity (so cold-start shows good items)
    score += dest.averageRating * 0.5;

    // Factor 4: ML Segment Personalization Boost (K-Means output from Firestore)
    if (user != null && user.clusterName != null) {
      final segment = user.clusterName;
      final destName = dest.name.toLowerCase();
      
      if (segment == "Luxury Elites") {
        // Boost luxury destinations and high-rating spots
        if (["phu quoc", "nha trang", "ha long bay", "singapore", "tokyo", "paris", "sydney"].contains(destName)) {
          score += 15.0;
        }
        if (dest.averageRating >= 4.5) {
          score += 5.0; // Luxury elites prefer highly rated places
        }
      } else if (segment == "Active Budget Backpackers") {
        // Boost adventure and backpacking destinations
        if (["sa pa", "ha giang", "da lat", "hoi an", "bangkok", "bali", "ninh binh"].contains(destName)) {
          score += 15.0;
        }
        if (dest.category?.toLowerCase() == "adventure") {
          score += 8.0;
        }
      } else if (segment == "Standard Vacationers") {
        // Boost standard/family vacation destinations
        if (["da nang", "ha long bay", "nha trang", "ninh binh"].contains(destName)) {
          score += 12.0;
        }
        if (dest.category?.toLowerCase() == "relaxation") {
          score += 6.0;
        }
      }
    }

    return {'dest': dest, 'score': score};
  }).toList();

  scored.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
  return scored.take(20).map((e) => e['dest'] as DestinationModel).toList();
}

/// Tier 3: AI Recommendations — Full catalog re-ranked by AI.
///
/// **Progressive Loading Strategy (2-phase):**
///
/// Phase 1 (immediate, ~1-2s): Return full catalog sorted by popularity while
/// the AI server is warming up. User sees data right away.
///
/// Phase 2 (background): Kick off AI request concurrently. When the server
/// responds (could be after cold-start), invalidate this provider to trigger
/// a transparent UI refresh with AI-ranked data at the top.
///
/// This eliminates the "45s blank screen" problem on Render cold-start.
@riverpod
Future<AiRecommendationResult> aiDestinations(Ref ref) async {
  final user = ref.watch(userInfoProvider);
  final mlService = ref.watch(mlServiceProvider);

  // 🔥 Phase 1: Warm-up + catalog load run concurrently.
  unawaited(mlService.warmUp());

  final List<DestinationModel> pool =
      await ref.watch(catalogDestinationsProvider.future);

  if (pool.isEmpty) {
    return const AiRecommendationResult(destinations: [], aiPickCount: 0);
  }

  final String userId = user?.uid ?? '';

  // Phase 1 response: popularity sort (instant fallback).
  // We'll try to get AI data within a short deadline. If the server responds
  // in time, great. If not, we schedule a background refresh.
  const Duration quickDeadline = Duration(milliseconds: 2000);

  try {
    // Race: AI request vs. quick deadline timer.
    final result = await mlService
        .getCloudRecommendations(userId, pool)
        .timeout(
          quickDeadline,
          onTimeout: () {
            // AI didn't respond within 8s → return popularity sort now,
            // and schedule a background refresh for when AI wakes up.
            debugPrint(
              'ML_SERVICE: ⏱️ Quick deadline missed (${quickDeadline.inSeconds}s). '
              'Serving popularity sort now; scheduling background AI refresh...',
            );

            // Background task: wait for server to wake up, then refresh UI.
            Future.delayed(const Duration(milliseconds: 500), () async {
              try {
                final bgResult = await mlService.getCloudRecommendations(userId, pool);
                // Only invalidate if we actually got AI recommendations.
                // This prevents infinite refresh loops if the server remains unreachable.
                if (bgResult.aiPickCount > 0) {
                  debugPrint('ML_SERVICE: 🔄 AI is awake! Invaldating for UI refresh.');
                  ref.invalidateSelf();
                } else {
                  debugPrint('ML_SERVICE: ℹ️ Background check finished but no AI picks found (Server still cold or No data).');
                }
              } catch (e) {
                debugPrint('ML_SERVICE: ⚠️ Background refresh failed: $e');
              }
            });

            // Return popularity-sorted result immediately.
            return AiRecommendationResult(
              destinations: List<DestinationModel>.from(pool)
                ..sort((a, b) {
                  final cmp = b.trendingScore.compareTo(a.trendingScore);
                  if (cmp != 0) return cmp;
                  return b.averageRating.compareTo(a.averageRating);
                }),
              aiPickCount: 0,
            );
          },
        );

    return result;
  } catch (e) {
    debugPrint('ML_SERVICE: ❌ Unexpected error in aiDestinations: $e');
    // Ultimate safety net — sorted catalog, never empty screen.
    final sorted = List<DestinationModel>.from(pool)
      ..sort((a, b) {
        final cmp = b.trendingScore.compareTo(a.trendingScore);
        if (cmp != 0) return cmp;
        return b.averageRating.compareTo(a.averageRating);
      });
    return AiRecommendationResult(destinations: sorted, aiPickCount: 0);
  }
}

/// Legacy / Unified — returns AI-ranked destination list for backward compatibility.
@riverpod
Future<List<DestinationModel>> hybridDiscovery(Ref ref) async {
  final result = await ref.watch(aiDestinationsProvider.future);
  return result.destinations;
}

/// Provider cho tìm kiếm destinations
@riverpod
Future<List<DestinationModel>> searchDestinations(Ref ref, String query) async {
  final repo = ref.watch(recommendationRepositoryProvider);
  if (query.isEmpty) return [];
  return repo.searchDestinations(query);
}

/// Provider cho chi tiết một destination
@riverpod
Future<DestinationModel?> destinationDetails(
  Ref ref,
  String destinationId,
) async {
  final repo = ref.watch(recommendationRepositoryProvider);
  return repo.getDestinationById(destinationId);
}
@riverpod
Stream<DestinationModel?> destinationStream(Ref ref, String destinationId) {
  final repo = ref.watch(recommendationRepositoryProvider);
  return repo.getDestinationStream(destinationId);
}

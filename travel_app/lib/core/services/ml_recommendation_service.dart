import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/api_constants.dart';
import '../../shared/models/destination_model.dart';
import '../../shared/models/ai_recommendation_result.dart';

part 'ml_recommendation_service.g.dart';

@Riverpod(keepAlive: true)
MLRecommendationService mlService(Ref ref) {
  return MLRecommendationService();
}

/// Service handling ML Recommendation logic via Local FastAPI Server (triphero_api)
///
/// NOTE: 10.0.2.2 là địa chỉ đặc biệt của Android Emulator trỏ về localhost (127.0.0.1)
///       của máy tính host. Nếu chạy trên thiết bị vật lý thực, hãy thay bằng IP LAN
///       của máy tính (ví dụ: 192.168.1.x).
///
/// Re-ranking strategy:
///   1. Fetch AI-ranked ID list from server.
///   2. Build an O(1) rank-lookup Map from the ID list.
///   3. Sort the ENTIRE catalog using a single comparator:
///       • Both in AI list  → sort by AI rank (ascending = higher priority).
///       • Only A in AI     → A comes first.
///       • Neither in AI    → sort by trendingScore DESC, then rating DESC.
///   Result: ALL destinations shown, AI picks at the top in correct order.
///
/// Resilience:
///   - Local server has no cold-start — timeout is much shorter.
///   - Empty aiIds → pure popularity sort (smooth fallback, aiPickCount = 0).
class MLRecommendationService {
  // ─── Local Server (triphero_api) ─────────────────────────────────────────
  // Android Emulator: 10.0.2.2 maps to host machine's localhost.
  // Physical Device:  Replace with your LAN IP (e.g. http://192.168.1.100:8000)
  static String get _baseUrl =>
      '${ApiConstants.baseDomain}/api/v1/recommend/';
  static String get _healthUrl =>
      '${ApiConstants.baseDomain}/health';

  // Render/FastAPI server responds in seconds, but we need enough time for cold start
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const Duration _warmupTimeout = Duration(seconds: 35);

  bool _isWarmedUp = false;

  // ─── Warm-up ────────────────────────────────────────────────────────────────

  /// Fire a background ping to wake up the Render server.
  /// Call as early as possible; errors are swallowed (best-effort).
  Future<void> warmUp() async {
    if (_isWarmedUp) return;
    debugPrint('ML_SERVICE: 🔥 Warming up Render server (background)...');
    try {
      final res = await http
          .get(Uri.parse(_healthUrl))
          .timeout(_warmupTimeout);
      if (res.statusCode == 200) {
        _isWarmedUp = true;
        debugPrint('ML_SERVICE: ✅ Server warmed up successfully.');
      }
    } catch (e) {
      debugPrint('ML_SERVICE: ⚠️ Warm-up ping failed (non-critical): $e');
    }
  }

  // ─── Main entry point ───────────────────────────────────────────────────────

  /// Returns the FULL catalog re-ranked by AI as [AiRecommendationResult].
  ///
  /// [destinations] — full sorted catalog (AI picks first, then popularity).
  /// [aiPickCount]  — number of items at the top ranked by AI.
  Future<AiRecommendationResult> getCloudRecommendations(
    String userId,
    List<DestinationModel> allDestinations,
  ) async {
    if (userId.isEmpty) {
      debugPrint('ML_SERVICE: No userId — using popularity sort.');
      return _rerank(allDestinations: allDestinations, aiRankedIds: []);
    }

    List<String> aiRankedIds = [];

    try {
      final url = Uri.parse('$_baseUrl$userId');
      debugPrint(
        'ML_SERVICE: 🤖 Calling Cloud API: $url '
        '(timeout: ${_requestTimeout.inSeconds}s)',
      );

      final response = await http.get(url).timeout(
        _requestTimeout,
        onTimeout: () {
          debugPrint(
            'ML_SERVICE: ⏱️ Timed out after ${_requestTimeout.inSeconds}s '
            '(Render cold-start). Falling back to popularity sort.',
          );
          return http.Response('{"error":"timeout"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = (data['recommendations'] as List<dynamic>?) ?? [];
        aiRankedIds = raw.map((e) => e.toString()).toList();
        _isWarmedUp = true;
        debugPrint(
          'ML_SERVICE: ✅ Success! ${aiRankedIds.length} AI IDs received.',
        );
      } else if (response.statusCode == 404) {
        debugPrint(
          'ML_SERVICE: ℹ️ User not in ML model yet. Popularity sort.',
        );
      } else {
        debugPrint(
          'ML_SERVICE: ❌ HTTP ${response.statusCode}. Popularity sort.',
        );
      }
    } on SocketException catch (e) {
      debugPrint('ML_SERVICE: ❌ No network: $e');
    } on http.ClientException catch (e) {
      debugPrint('ML_SERVICE: ❌ HTTP Client error: $e');
    } on TimeoutException catch (e) {
      debugPrint('ML_SERVICE: ⏱️ Outer timeout: $e');
    } catch (e) {
      debugPrint('ML_SERVICE: ❌ Unexpected error: $e');
    }

    return _rerank(
      allDestinations: allDestinations,
      aiRankedIds: aiRankedIds,
    );
  }

  // ─── Re-ranking core ────────────────────────────────────────────────────────

  /// **Full-catalog re-ranking algorithm — O(N log N)**
  ///
  /// 1. Build an index Map `{ destinationId → aiRank }` for O(1) lookup.
  /// 2. Sort the entire list with one comparator pass:
  ///    • Both in AI  → lower AI rank wins (position 0 = highest priority).
  ///    • Only A in AI → A comes first.
  ///    • Neither     → higher trendingScore wins; tie-break by rating.
  /// 3. Empty [aiRankedIds] → every item falls to case 3 = pure popularity sort.
  AiRecommendationResult _rerank({
    required List<DestinationModel> allDestinations,
    required List<String> aiRankedIds,
  }) {
    // Step 1: O(1) rank lookup map
    final Map<String, int> aiRankMap = {
      for (int i = 0; i < aiRankedIds.length; i++) aiRankedIds[i]: i,
    };

    // Step 2: Copy (never mutate original)
    final List<DestinationModel> sorted =
        List<DestinationModel>.from(allDestinations);

    // Step 3: Single-pass sort — O(N log N)
    sorted.sort((a, b) {
      final rankA = aiRankMap[a.id];
      final rankB = aiRankMap[b.id];

      if (rankA != null && rankB != null) {
        return rankA.compareTo(rankB);       // Case 1: both AI — preserve rank
      } else if (rankA != null) {
        return -1;                            // Case 2: A is AI pick → A first
      } else if (rankB != null) {
        return 1;                             // Case 2: B is AI pick → B first
      } else {
        // Case 3: neither — popularity sort
        final trendCmp = b.trendingScore.compareTo(a.trendingScore);
        if (trendCmp != 0) return trendCmp;
        return b.averageRating.compareTo(a.averageRating);
      }
    });

    // Count items that matched AI IDs (some AI IDs may not be in catalog)
    final int aiPickCount =
        sorted.where((d) => aiRankMap.containsKey(d.id)).length;

    debugPrint(
      'ML_SERVICE: Re-ranked ${sorted.length} items '
      '($aiPickCount AI picks + ${sorted.length - aiPickCount} popularity).',
    );

    return AiRecommendationResult(
      destinations: sorted,
      aiPickCount: aiPickCount,
    );
  }

  // ─── API compatibility shims ────────────────────────────────────────────────
  Future<void> init() async {}
  void dispose() {}
}

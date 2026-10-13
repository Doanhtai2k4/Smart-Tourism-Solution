import 'package:travel_app/shared/models/destination_model.dart';

/// Result object returned by the AI recommendation system.
///
/// [destinations] — Full catalog sorted by re-ranking:
///                  AI-recommended items first (in AI order),
///                  remaining items sorted by trendingScore → rating.
/// [aiPickCount]  — Number of items at the top that were chosen by AI.
///                  Use this in the UI to show "AI Pick" badges on the
///                  first [aiPickCount] items in the list.
class AiRecommendationResult {
  final List<DestinationModel> destinations;
  final int aiPickCount;

  const AiRecommendationResult({
    required this.destinations,
    required this.aiPickCount,
  });

  /// Convenience: returns true if AI data was available (not pure fallback).
  bool get hasAiData => aiPickCount > 0;
}

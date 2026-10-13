import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageService {
  final String accessKey;
  final String placeholderUrl;

  ImageService({required this.accessKey, String? placeholderUrl})
      : placeholderUrl = placeholderUrl ??
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e';

  /// Fetches images for the given list of keywords in parallel.
  /// Always returns a list with the same length as input. Uses placeholder when not found.
  Future<List<String>> fetchImages(List<String> queries) async {
    final futures = queries.map((q) => _fetchSingleImage(q));
    final List<String?> results = await Future.wait(futures);
    // Replace nulls with placeholder, keep order
    return results.map((r) => r ?? placeholderUrl).toList();
  }

  Future<String?> _fetchSingleImage(String query) async {
    try {
      var trimmed = query.toString().trim();
      if (trimmed.isEmpty) return placeholderUrl;

      // 1. If it's already a resolved Unsplash URL, return it directly
      if (trimmed.startsWith('http') && !trimmed.contains('source.unsplash.com')) {
        return trimmed;
      }

      // 2. If it is a dead source.unsplash.com URL, extract the query keyword
      if (trimmed.contains('source.unsplash.com')) {
        try {
          final uri = Uri.parse(trimmed);
          final rawQuery = uri.query;
          if (rawQuery.isNotEmpty) {
            final parts = rawQuery.split(',');
            trimmed = parts.first.trim();
            trimmed = Uri.decodeComponent(trimmed);
          }
        } catch (e) {
          dev.log('Error parsing source.unsplash.com URL: $e');
        }
      }

      // 3. Fallback when accessKey is empty
      if (accessKey.isEmpty) {
        return placeholderUrl;
      }

      final uri = Uri.https('api.unsplash.com', '/search/photos', {
        'query': trimmed,
        'orientation': 'landscape',
        'per_page': '1',
      });

      final resp = await http
          .get(uri, headers: {'Authorization': 'Client-ID $accessKey'})
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) {
        dev.log('Unsplash API error ${resp.statusCode} ${resp.body}');
        return placeholderUrl;
      }

      final Map<String, dynamic> jsonBody = json.decode(resp.body);
      final results = jsonBody['results'];
      if (results is List && results.isNotEmpty) {
        final first = results.first as Map<String, dynamic>;
        final urls = first['urls'] as Map<String, dynamic>?;
        if (urls != null && urls['regular'] != null) {
          return urls['regular'] as String;
        }
        if (urls != null && urls['raw'] != null) {
          return urls['raw'] as String;
        }
      }

      return placeholderUrl;
    } catch (e) {
      dev.log('Error fetching image for "$query": $e');
      return placeholderUrl;
    }
  }
}

final imageServiceProvider = Provider<ImageService>((ref) {
  final key = dotenv.env['UNSPLASH_ACCESS_KEY'] ?? '';
  return ImageService(accessKey: key);
});

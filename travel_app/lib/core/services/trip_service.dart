import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../shared/models/travel_db_model.dart';
import '../constants/api_constants.dart';

part 'trip_service.g.dart';

@riverpod
TripService tripService(Ref ref) {
  return TripService();
}

class TripService {
  static String get baseUrl => ApiConstants.activeBaseUrl;

  /// Tham gia chuyến đi bằng mã shareCode
  Future<TravelDbModel> joinTrip(String shareCode, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.joinTrip}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'share_code': shareCode,
          'user_id': userId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return TravelDbModel.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Mã mời không hợp lệ');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Mã mời không hợp lệ hoặc đã hết hạn');
      } else {
        throw Exception('Lỗi máy chủ (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Không thể tham gia chuyến đi: ${e.toString()}');
    }
  }
}

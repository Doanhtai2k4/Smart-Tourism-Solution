import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/addtrip/models/trip_plan_request.dart';
import '../../features/addtrip/models/travel_gemini_response.dart';
import '../../features/chat/models/chat_message_model.dart';
import '../../shared/models/ai_recommended_destination.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/features/packing/models/packing_model.dart';
import '../constants/api_constants.dart';


part 'ai_backend_service.g.dart';

@riverpod
AiBackendService aiBackendService(Ref ref) {
  return AiBackendService();
}


class AiBackendService {
  // Sử dụng hằng số từ ApiConstants
  static String get baseUrl => ApiConstants.activeBaseUrl;

  /// Gửi yêu cầu lập lịch trình tới Backend
  Future<TravelGeminiResponse> getTripPlan(TripPlanRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trips/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toMap()),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (responseData['status'] == 'success') {
          return TravelGeminiResponse.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Lỗi không xác định từ server');
        }
      } else {
        _handleHttpError(response.statusCode);
        throw Exception('Server error'); // Sẽ không chạm tới do _handleHttpError ném rồi
      }
    } on SocketException {
      throw Exception('Không có kết nối internet. Vui lòng kiểm tra lại mạng.');
    } on HttpException {
      throw Exception('Không tìm thấy máy chủ. Vui lòng thử lại sau.');
    } on FormatException {
      throw Exception('Dữ liệu phản hồi không đúng định dạng.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Gửi yêu cầu Chat tới Backend
  Future<String> getChatResponse(
    String message, 
    Map<String, dynamic> tripContext, 
    List<ChatMessageModel> history,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'tripContext': tripContext,
          'history': history.map((m) => m.toJson()).toList(),
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return responseData['data']['reply'] ?? 'Trợ lý không có câu trả lời.';
        } else {
          throw Exception(responseData['message'] ?? 'Lỗi chatbot');
        }
      } else {
        _handleHttpError(response.statusCode);
        return ''; // Không bao giờ chạm tới
      }
    } on SocketException {
      throw Exception('Lỗi kết nối mạng. Không thể gửi tin nhắn.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi chatbot: ${e.toString()}');
    }
  }

  /// Gợi ý điểm đến dựa trên sở thích (Discovery)
  Future<List<AIRecommendedDestination>> getRecommendedDestinations(List<String> hobbies) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/discovery/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'hobbies': hobbies}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'] ?? [];
          return data.map((e) => AIRecommendedDestination.fromJson(e as Map<String, dynamic>)).toList();
        } else {

          throw Exception(responseData['message'] ?? 'Lỗi gợi ý điểm đến');
        }
      } else {
        _handleHttpError(response.statusCode);
        return [];
      }
    } on SocketException {
      throw Exception('Lỗi mạng. Không thể tải gợi ý điểm đến.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi discovery: ${e.toString()}');
    }
  }

  /// Xử lý các mã lỗi HTTP phổ biến

  /// Lưu sở thích người dùng để xử lý Cold Start (Pseudo-history)
  Future<void> saveUserPreferences(String userId, List<String> interests) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/preferences'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'interests': interests,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _handleHttpError(response.statusCode);
      }
    } on SocketException {
      throw Exception('Lỗi kết nối mạng. Không thể lưu sở thích.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi khi lưu sở thích: ${e.toString()}');
    }
  }

  /// 5. TẠO DANH SÁCH ĐỒ DÙNG (SMART PACKING LIST)
  Future<List<PackingCategory>> generatePackingList(
    String destination, 
    int days, 
    String weatherContext, 
    String gender, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiConstants.packingList}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'destination': destination,
          'days': days,
          'weather_context': weatherContext,
          'gender': gender,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          // Trả về danh sách categories từ field 'categories' trong data
          return PackingListResponse.fromJson(responseData['data']).categories;
        } else {
          throw Exception(responseData['message'] ?? 'Lỗi không thể tạo danh sách đồ dùng.');
        }
      } else {
        _handleHttpError(response.statusCode);
        throw Exception('Server error');
      }
    } on SocketException {
      throw Exception('Không có kết nối internet. Vui lòng kiểm tra lại mạng.');
    } catch (e) {
      debugPrint("--- LỖI KẾT NỐI PACKING LIST API ---");
      debugPrint(e.toString());
      if (e is Exception) rethrow;
      throw Exception('Lỗi khi tạo danh sách đồ dùng: ${e.toString()}');
    }
  }

  /// 6. LAZY GENERATION: Sinh hành lý và lưu trực tiếp vào Firestore
  Future<List<PackingCategory>> generateLazyPackingList(
    String tripId,
    String destination,
    int days, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Gọi API sinh danh sách với các giá trị mặc định và ngày tháng
    final categories = await generatePackingList(
      destination,
      days,
      "Thông thường",
      "Unisex",
      startDate: startDate,
      endDate: endDate,
    );

    // Lưu kết quả vào Firestore để lần sau không cần sinh lại
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .update({
      'packing_list': categories.map((c) => c.toJson()).toList(),
    });

    return categories;
  }

  void _handleHttpError(int statusCode) {
    switch (statusCode) {
      case 400:
        throw Exception('Yêu cầu không hợp lệ. Vui lòng kiểm tra lại thông tin.');
      case 404:
        throw Exception('Không tìm thấy endpoint trên server (404).');
      case 422:
        throw Exception('Dữ liệu gửi lên không đúng định dạng yêu cầu.');
      case 500:
        throw Exception('Máy chủ đang gặp sự cố (500). Vui lòng thử lại sau.');
      case 503:
        throw Exception('Dịch vụ tạm thời không khả dụng. Máy chủ đang bảo trì.');
      default:
        throw Exception('Lỗi máy chủ ($statusCode). Vui lòng liên hệ hỗ trợ.');
    }
  }
}

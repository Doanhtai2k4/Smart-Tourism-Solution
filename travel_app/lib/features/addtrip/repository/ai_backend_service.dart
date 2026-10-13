import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/api_constants.dart';

// Đảm bảo import đúng đường dẫn các file model của bạn
import 'package:travel_app/features/addtrip/models/travel_gemini_response.dart';
import 'package:travel_app/features/addtrip/models/trip_plan_request.dart';
// import 'đường_dẫn_tới_file/chat_message_model.dart'; // Mở comment nếu cần dùng ChatMessageModel

part 'ai_backend_service.g.dart';

@riverpod
AiBackendService aiBackendService(Ref ref) {
  return AiBackendService();
}

class AiBackendService {
  // Địa chỉ kết nối tới Server Python
  // Chú ý: 10.0.2.2 là localhost dành cho Máy ảo Android (Android Emulator)
  // Nếu bạn chạy trên thiết bị thật (cắm cáp) hãy đổi thành IP LAN của máy tính (VD: 192.168.1.x)
  static String get baseUrl => ApiConstants.activeBaseUrl;

  /// ==========================================
  /// 1. GỌI API LẬP LỊCH TRÌNH TỪ BACKEND
  /// ==========================================
  Future<TravelGeminiResponse> getTripPlan(TripPlanRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/trips/generate'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            // Chuyển object Dart thành JSON để gửi đi
            body: jsonEncode(request.toMap()),
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        // Đọc dữ liệu JSON Server trả về (Giải mã UTF-8 để không lỗi tiếng Việt)
        final Map<String, dynamic> decodedResponse = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        // Kiểm tra format StandardResponse từ Server Python
        if (decodedResponse['status'] == 'success') {
          // Trích xuất phần dữ liệu cốt lõi
          final Map<String, dynamic> data = decodedResponse['data'];

          // In ra để kiểm tra (rất hữu ích khi nhận Mock Data)
          debugPrint("📥 Dữ liệu nhận từ Python: $data");

          // Parse JSON vào Model có sẵn của bạn
          // Tạm thời để trong khối try/catch phòng trường hợp Mock Data chưa khớp hẳn model
          try {
            return TravelGeminiResponse.fromJson(data);
          } catch (parseError) {
            throw Exception(
              'Đã nhận được Data từ Server nhưng lỗi parse: $parseError\nData: $data',
            );
          }
        } else {
          throw Exception('Lỗi từ Server: ${decodedResponse['message']}');
        }
      } else {
        throw Exception('Lỗi kết nối HTTP: Mã ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception(
          'Yêu cầu quá hạn (Timeout). AI Server đang bận hoặc phản hồi quá lâu. Vui lòng thử lại.');
    } catch (e) {
      debugPrint("--- LỖI KẾT NỐI API SERVER ---");
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// ==========================================
  /// 2. GỌI API TRỢ LÝ ẢO (CHATBOT) TỪ BACKEND
  /// ==========================================
  Future<String> getChatResponse({
    required String message,
    required Map<String, dynamic> tripContext,
    required List<Map<String, dynamic>>
    history, // Truyền danh sách tin nhắn cũ đã toMap()
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'message': message,
              'tripContext': tripContext,
              'history': history, // Gửi kèm lịch sử để Server lo việc ghi nhớ
            }),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        if (decodedResponse['status'] == 'success') {
          // Trả về thẳng câu reply dạng String
          return decodedResponse['data']['reply'] as String;
        } else {
          throw Exception('Lỗi từ Server: ${decodedResponse['message']}');
        }
      } else {
        throw Exception('Lỗi kết nối HTTP: Mã ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Lỗi: AI phản hồi quá lâu. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint("--- LỖI KẾT NỐI CHAT API ---");
      debugPrint(e.toString());
      throw Exception('Không thể gửi tin nhắn lúc này. Vui lòng thử lại sau.');
    }
  }
}


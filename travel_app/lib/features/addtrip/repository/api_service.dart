import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:travel_app/features/addtrip/models/travel_gemini_response.dart';

part 'api_service.g.dart';

@riverpod
GeminiApiService geminiApiService(Ref ref) {
  return GeminiApiService();
}

class GeminiApiService {
  late final GenerativeModel _model;

  GeminiApiService() {
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    _model = GenerativeModel(
      // 1. Sử dụng ID chính xác cho bản ổn định
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.7, // Giúp AI sáng tạo vừa đủ nhưng vẫn bám sát JSON
      ),
      // 2. Thêm Safety Settings để tránh lỗi AI từ chối phản hồi
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  Future<TravelGeminiResponse> getGeminiComplete(String prompt) async {
    try {
      final content = [Content.text(prompt)];

      // Gọi API thông qua SDK chính thức
      final response = await _model.generateContent(content);

      final String? rawText = response.text;

      if (rawText == null || rawText.isEmpty) {
        throw Exception(
          'AI không trả về dữ liệu. Có thể do bộ lọc an toàn của Google.',
        );
      }

      // Làm sạch Markdown nếu có
      final cleanedText = rawText
          .replaceAll(RegExp(r'```json|```', caseSensitive: false), '')
          .trim();

      // Giải mã JSON và parse vào Model
      final Map<String, dynamic> decodedJson = json.decode(cleanedText);
      return TravelGeminiResponse.fromJson(decodedJson);
    } catch (e) {
      print("--- LỖI HỆ THỐNG AI ---");
      print(e);

      // Nếu vẫn báo lỗi "Not Found", hãy kiểm tra lại vùng quốc gia của API Key
      throw Exception('Không thể tạo lịch trình: $e');
    }
  }

  Future<String> getChatResponse(
    String message,
    Map<String, dynamic> tripContext,
  ) async {
    try {
      final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

      // Tạo một model riêng cho Chat vì khác với model lập kế hoạch (JSON)
      // Chat Model trả về text thông thường
      final chatModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(temperature: 0.7),
      );

      final String destination = tripContext['destination'] ?? 'Không rõ';
      final String startDate = tripContext['startDate'] ?? 'Không rõ';
      final String endDate = tripContext['endDate'] ?? 'Không rõ';
      final String overview = tripContext['overview'] ?? 'Không có mô tả';

      final String systemPrompt =
          '''
      Bạn là một Trợ lý Du lịch AI thân thiện và chuyên nghiệp. 
      Bạn đang hỗ trợ người dùng trong chuyến đi của họ. Dưới đây là thông tin về chuyến đi hiện tại:
      - Điểm đến: $destination
      - Ngày đi: $startDate
      - Ngày về: $endDate
      - Mô tả tổng quan: $overview
      
      Hãy trả lời các câu hỏi của người dùng ngắn gọn, súc tích, bằng tiếng Việt. Nếu họ hỏi những thứ không liên quan đến du lịch, hãy lịch sự từ chối và hướng họ về chuyến đi.
      ''';

      final content = [
        Content.text(systemPrompt),
        Content.text("Người dùng hỏi: $message"),
      ];

      final response = await chatModel.generateContent(content);
      return response.text ?? 'Xin lỗi, tôi không thể trả lời lúc này.';
    } catch (e) {
      print("--- LỖI CHAT AI ---");
      print(e);
      throw Exception('Không thể gửi tin nhắn.');
    }
  }
}

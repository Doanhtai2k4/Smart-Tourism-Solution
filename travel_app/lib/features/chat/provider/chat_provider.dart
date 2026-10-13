import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/travel_db_model.dart';
import '../../addtrip/repository/ai_backend_service.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  bool build() {
    return false; // Trạng thái 'isTyping'
  }

  /// Existing sendMessage kept for compatibility but updated for new service
  Future<void> sendMessage(
    String text,
    TravelDbModel trip,
    List<Map<String, dynamic>> history,
  ) async {
    if (text.trim().isEmpty) return;

    final aiBackend = ref.read(aiBackendServiceProvider);
    state = true;

    try {
      final mapContext = {
        'destination': trip.destination,
        'startDate': trip.startDate.toString(),
        'endDate': trip.endDate.toString(),
        'overview': trip.overview,
      };

      final aiResponseText = await aiBackend.getChatResponse(
        message: text,
        tripContext: mapContext,
        history: history,
      );
      print("AI Response: $aiResponseText");
    } catch (e) {
      print("Lỗi gửi tin nhắn AI: $e");
    } finally {
      state = false;
    }
  }

  /// New helper: returns the AI response while managing the typing state.
  Future<String> getAiResponse(
    String text,
    TravelDbModel trip,
    List<Map<String, dynamic>> history,
  ) async {
    if (text.trim().isEmpty) return '';

    final aiBackend = ref.read(aiBackendServiceProvider);
    state = true;

    try {
      final mapContext = {
        'destination': trip.destination,
        'startDate': trip.startDate.toIso8601String().split('T')[0],
        'endDate': trip.endDate.toIso8601String().split('T')[0],
        'overview': trip.overview,
      };

      final aiResponseText = await aiBackend.getChatResponse(
        message: text,
        tripContext: mapContext,
        history: history,
      );
      return aiResponseText;
    } catch (e) {
      print("❌ Lỗi getAiResponse chi tiết: $e");
      return 'Xin lỗi, tôi đang gặp sự cố kết nối với trợ lý ảo. Vui lòng kiểm tra internet và thử lại sau.';
    } finally {
      state = false;
    }
  }
}


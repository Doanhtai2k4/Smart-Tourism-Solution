import 'package:flutter/foundation.dart';

class ApiConstants {
  // Thay đổi URL này sau khi deploy lên Render
  static const String renderUrl = 'https://travel-ai-server-14w0.onrender.com';
  
  static bool useRender = false; // Chuyển thành true để dùng server Render

  static String get activeBaseUrl => useRender
      ? '$renderUrl/api/v1'
      : (kIsWeb ? 'http://localhost:8000/api/v1' : 'http://10.0.2.2:8000/api/v1');
      
  static String get baseDomain => useRender
      ? renderUrl
      : (kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000');
  
  // Endpoint cho tính năng Packing List
  static const String packingList = '/ai/packing-list';
  
  // Các endpoint khác
  static const String generateTrip = '/trips/generate';
  static const String chat = '/chat';
  static const String discovery = '/discovery/recommend';
  static const String joinTrip = '/trips/join';
}

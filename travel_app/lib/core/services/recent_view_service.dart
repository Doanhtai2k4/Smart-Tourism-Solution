import 'package:shared_preferences/shared_preferences.dart';

class RecentViewService {
  static const String _key = 'recent_location_ids';

  /// Thêm một địa điểm vào danh sách đã xem gần đây
  static Future<void> addRecentLocation(String locationId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ids = prefs.getStringList(_key) ?? [];

    // Nếu đã tồn tại, xóa đi để đưa lên đầu
    ids.remove(locationId);
    
    // Chèn vào vị trí đầu tiên
    ids.insert(0, locationId);

    // Giới hạn tối đa 10 phần tử
    if (ids.length > 10) {
      ids = ids.sublist(0, 10);
    }

    await prefs.setStringList(_key, ids);
  }

  /// Lấy danh sách ID các địa điểm đã xem gần đây
  static Future<List<String>> getRecentLocationIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}

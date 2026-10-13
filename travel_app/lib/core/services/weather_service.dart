import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather_service.g.dart';

enum WeatherCondition {
  sunny('Nắng', ['Biển', 'Núi', 'Công viên', 'Thiên nhiên']),
  rainy('Mưa', ['Bảo tàng', 'Trung tâm thương mại', 'Cafe', 'Trong nhà']),
  cloudy('Nhiều mây', ['Văn hóa', 'Lịch sử', 'Dạo phố']);

  final String label;
  final List<String> boostedCategories;
  const WeatherCondition(this.label, this.boostedCategories);
}

@riverpod
class WeatherService extends _$WeatherService {
  @override
  WeatherCondition build() {
    // Mock logic: Sunny during the day (6 AM - 6 PM), Rainy/Cloudy otherwise
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 18) {
      return WeatherCondition.sunny;
    } else if (hour >= 18 && hour < 22) {
      return WeatherCondition.cloudy;
    } else {
      return WeatherCondition.rainy;
    }
  }

  /// Manually set weather for testing/demo purposes
  void setWeather(WeatherCondition condition) {
    state = condition;
  }
}

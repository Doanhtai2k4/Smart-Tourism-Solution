import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

@JsonSerializable()
class WeatherForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  WeatherForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) => _$WeatherForecastFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherForecastToJson(this);

  String get weatherDescription {
    switch (weatherCode) {
      case 0: return 'Trời quang';
      case 1: case 2: case 3: return 'Nhiều mây';
      case 45: case 48: return 'Sương mù';
      case 51: case 53: case 55: return 'Mưa phùn';
      case 61: case 63: case 65: return 'Mưa';
      case 71: case 73: case 75: return 'Tuyết';
      case 80: case 81: case 82: return 'Mưa rào';
      case 95: case 96: case 99: return 'Dông';
      default: return 'Không xác định';
    }
  }

  String get weatherIcon {
    switch (weatherCode) {
      case 0: return '☀️';
      case 1: case 2: case 3: return '☁️';
      case 45: case 48: return '🌫️';
      case 51: case 53: case 55: return '🌧️';
      case 61: case 63: case 65: return '🌧️';
      case 80: case 81: case 82: return '🌦️';
      case 95: case 96: case 99: return '⚡';
      default: return '❓';
    }
  }

  bool get isBadWeather {
    // Mã từ 61 (mưa) trở lên hoặc sương mù dày (45, 48) được coi là cần lưu ý
    return weatherCode >= 61 || weatherCode == 45 || weatherCode == 48 || weatherCode >= 80;
  }

  String get alertMessage {
    if (weatherCode >= 95) return 'Có dông sét! Hạn chế ra ngoài.';
    if (weatherCode >= 80) return 'Mưa rào lớn, nên mang theo áo mưa.';
    if (weatherCode >= 61) return 'Có mưa, đừng quên mang theo ô.';
    if (weatherCode == 45 || weatherCode == 48) return 'Sương mù dày, cẩn thận khi lái xe.';
    return '';
  }
}

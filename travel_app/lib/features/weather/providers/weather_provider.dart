import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider((ref) => WeatherService());

final tripWeatherProvider = FutureProvider.family<List<WeatherForecast>, WeatherParams>((ref, params) async {
  final service = ref.read(weatherServiceProvider);
  return service.getForecast(
    lat: params.lat,
    lng: params.lng,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

class WeatherParams {
  final double lat;
  final double lng;
  final DateTime startDate;
  final DateTime endDate;

  WeatherParams({
    required this.lat,
    required this.lng,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherParams &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

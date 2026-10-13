import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class WeatherService {
  final _dio = Dio();

  Future<List<WeatherForecast>> getForecast({
    required double lat,
    required double lng,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'daily': 'weathercode,temperature_2m_max,temperature_2m_min',
          'timezone': 'auto',
          'start_date': startStr,
          'end_date': endStr,
        },
      );

      final daily = response.data['daily'];
      final List<WeatherForecast> forecasts = [];

      for (int i = 0; i < (daily['time'] as List).length; i++) {
        forecasts.add(WeatherForecast(
          date: DateTime.parse(daily['time'][i]),
          maxTemp: daily['temperature_2m_max'][i].toDouble(),
          minTemp: daily['temperature_2m_min'][i].toDouble(),
          weatherCode: daily['weathercode'][i].toInt(),
        ));
      }

      return forecasts;
    } catch (e) {
      print('Weather API Error: $e');
      return [];
    }
  }
}

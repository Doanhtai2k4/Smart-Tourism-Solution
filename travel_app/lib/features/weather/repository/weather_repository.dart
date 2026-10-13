import 'package:travel_app/features/weather/entity/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getCurrentWeather(double lat, double lon);
}

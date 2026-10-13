import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entity/weather_entity.dart';
import '../remote/weather_api_service.dart';
import '../repository/weather_repository.dart';
import '../repository/weather_repository_imp.dart';
part 'weather_provider.g.dart';

@riverpod
Dio dio(Ref ref) => Dio();

@riverpod
WeatherApiService weatherApiService(Ref ref) {
  // Đã sửa thành watch
  return WeatherApiService(dio: ref.watch(dioProvider));
}

@riverpod
WeatherRepository weatherRepository(Ref ref) {
  // Đã sửa thành watch
  return WeatherRepositoryImpl(
    apiService: ref.watch(weatherApiServiceProvider),
  );
}

@riverpod
Future<WeatherEntity> weatherForecast(Ref ref, double lat, double lon) {
  // Đã sửa thành watch
  final repo = ref.watch(weatherRepositoryProvider);
  return repo.getCurrentWeather(lat, lon);
}

import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final String locationName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;

  const WeatherEntity({
    required this.locationName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
  });

  @override
  List<Object?> get props => [
    locationName,
    country,
    temperature,
    feelsLike,
    tempMin,
    tempMax,
    humidity,
    windSpeed,
    description,
    icon,
  ];
}

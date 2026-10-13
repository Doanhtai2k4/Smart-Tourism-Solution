import 'package:flutter/material.dart';

IconData getWeatherIcon(String condition) {
  final lowerCondition = condition.toLowerCase();
  if (lowerCondition.contains('sun') || lowerCondition.contains('clear')) {
    return Icons.wb_sunny;
  } else if (lowerCondition.contains('cloud')) {
    return Icons.cloud;
  } else if (lowerCondition.contains('rain')) {
    return Icons.water_drop;
  } else if (lowerCondition.contains('snow')) {
    return Icons.ac_unit;
  } else if (lowerCondition.contains('storm')) {
    return Icons.thunderstorm;
  }
  return Icons.wb_cloudy;
}

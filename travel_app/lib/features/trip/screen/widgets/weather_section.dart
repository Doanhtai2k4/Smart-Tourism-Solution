import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/features/trip/screen/widgets/section_header.dart';

import '../../../../core/utilities/weather_utils.dart';
import '../../../weather/entity/weather_entity.dart';
import '../../../weather/provider/weather_provider.dart';

class WeatherSection extends ConsumerWidget {
  final String destination;
  final double latitude;
  final double longitude;

  const WeatherSection({
    super.key,
    required this.destination,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(
      weatherForecastProvider(latitude, longitude),
    );

    return forecastAsync.when(
      data: (forecast) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Icons.wb_sunny_outlined,
              title: context.l10n.weatherForecast,
            ),
            const SizedBox(height: 16),
            WeatherCard(destination: destination, weather: forecast),
          ],
        );
      },
      loading:
          () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String destination;
  final WeatherEntity weather;

  const WeatherCard({
    super.key,
    required this.destination,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withAlpha(76),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                destination,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    weather.description,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              Icon(
                getWeatherIcon(weather.description),
                size: 80,
                color: Colors.white.withAlpha(229),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(
                Icons.water_drop_outlined,
                context.l10n.humidity,
                '${weather.humidity}%',
              ),
              _buildWeatherDetail(
                Icons.air,
                context.l10n.wind,
                '${weather.windSpeed} ${context.l10n.kmh}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
      ],
    );
  }
}

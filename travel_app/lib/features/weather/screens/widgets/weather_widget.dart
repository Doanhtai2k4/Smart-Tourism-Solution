import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app/core/services/notification_service.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import '../../providers/weather_provider.dart';
import '../../models/weather_model.dart';

class TripWeatherWidget extends ConsumerWidget {
  final String travelId;
  final String destination;
  final double lat;
  final double lng;
  final DateTime startDate;
  final DateTime endDate;

  const TripWeatherWidget({
    super.key,
    required this.travelId,
    required this.destination,
    required this.lat,
    required this.lng,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(tripWeatherProvider(WeatherParams(
      lat: lat,
      lng: lng,
      startDate: startDate,
      endDate: endDate,
    )));

    // Xử lý thông báo đẩy khi có dữ liệu
    weatherAsync.whenData((forecasts) {
      if (forecasts.isNotEmpty) {
        final today = forecasts.firstWhere(
          (f) => DateFormat('yyyy-MM-dd').format(f.date) == 
                 DateFormat('yyyy-MM-dd').format(DateTime.now()),
          orElse: () => forecasts.first,
        );

        // Chỉ kích hoạt thông báo khi hôm nay nằm trong khoảng thời gian diễn ra chuyến đi (Trip is Ongoing)
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);
        final startMidnight = DateTime(startDate.year, startDate.month, startDate.day);
        final endMidnight = DateTime(endDate.year, endDate.month, endDate.day);
        
        final isTripOngoing = (todayMidnight.isAtSameMomentAs(startMidnight) || todayMidnight.isAtSameMomentAs(endMidnight)) ||
            (todayMidnight.isAfter(startMidnight) && todayMidnight.isBefore(endMidnight));

        if (isTripOngoing && today.isBadWeather) {
          final user = ref.read(userInfoProvider);
          if (user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(notificationServiceProvider).checkAndTriggerWeatherNotification(
                userId: user.uid,
                destination: destination,
                alertMessage: today.alertMessage,
                travelId: travelId,
              );
            });
          }
        }
      }
    });

    return weatherAsync.when(
      data: (forecasts) {
        if (forecasts.isEmpty) return const Center(child: Text("Không có dữ liệu thời tiết"));
        
        final badWeatherDay = forecasts.firstWhere(
          (f) => f.isBadWeather, 
          orElse: () => forecasts.first
        );
        final hasBadWeather = forecasts.any((f) => f.isBadWeather);

        return Column(
          children: [
            if (hasBadWeather)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Cảnh báo: ${badWeatherDay.alertMessage}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: forecasts.length,
                itemBuilder: (context, index) => _WeatherCard(forecast: forecasts[index]),
              ),
            ),
          ],
        );
      },
      loading: () => _buildLoading(context),
      error: (err, _) => Center(child: Text("Lỗi: $err")),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 100,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final WeatherForecast forecast;
  const _WeatherCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isToday = DateFormat('yyyy-MM-dd').format(forecast.date) == 
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday ? colors.primary.withValues(alpha: 0.1) : colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isToday ? colors.primary : colors.outlineVariant.withValues(alpha: 0.5),
          width: isToday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isToday ? "Hôm nay" : DateFormat('dd/MM').format(forecast.date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isToday ? colors.primary : colors.onSurface,
                ),
              ),
              if (forecast.isBadWeather) ...[
                const SizedBox(width: 4),
                const Icon(Icons.error_outline, color: Colors.red, size: 14),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            forecast.weatherIcon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            "${forecast.maxTemp.toInt()}° / ${forecast.minTemp.toInt()}°",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            forecast.weatherDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

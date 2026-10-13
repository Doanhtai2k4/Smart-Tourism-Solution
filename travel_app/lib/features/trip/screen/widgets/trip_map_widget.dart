import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/features/trip/screen/full_route_map_screen.dart';

class TripMapWidget extends StatelessWidget {
  final double currentLat;
  final double currentLng;
  final double destinationLat;
  final double destinationLng;
  final String destinationName;
  final double height;

  const TripMapWidget({
    super.key,
    required this.currentLat,
    required this.currentLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
    this.height = 250, // Tăng nhẹ chiều cao để nhìn rõ hơn
  });

  @override
  Widget build(BuildContext context) {
    // 1. Khởi tạo tọa độ
    final startPoint = LatLng(currentLat, currentLng);
    final endPoint = LatLng(destinationLat, destinationLng);

    // 2. Tính toán điểm trung tâm để bản đồ không bị lệch
    final centerPoint = LatLng(
      (currentLat + destinationLat) / 2,
      (currentLng + destinationLng) / 2,
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullRouteMapScreen(
              currentLat: currentLat,
              currentLng: currentLng,
              destinationLat: destinationLat,
              destinationLng: destinationLng,
              destinationName: destinationName,
            ),
          ),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: centerPoint,
                    initialZoom: 5.0, // Zoom xa để thấy cả 2 điểm
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none, // Tắt kéo thả để làm nút bấm
                    ),
                  ),
                  children: [
            // Lớp nền bản đồ miễn phí
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hoadev.travel_app',
            ),

            // Vẽ đường nối giữa vị trí hiện tại và điểm đến
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [startPoint, endPoint],
                  color: context.colors.primary,
                  strokeWidth: 4,
                  // XÓA 'const' ở đây
                  pattern: StrokePattern.dashed(segments: [10, 5]),
                  strokeCap: StrokeCap.round,
                ),
              ],
            ),

            // Đánh dấu các vị trí
            MarkerLayer(
              markers: [
                // Điểm bắt đầu (Vị trí hiện tại)
                Marker(
                  point: startPoint,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.my_location, color: context.colors.primary, size: 24),
                ),
                // Điểm đến
                Marker(
                  point: endPoint,
                  width: 150, // Rộng hơn để chứa label
                  height: 60,
                  child: Column(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                        ),
                        child: Text(
                          destinationName,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ), // closes MarkerLayer
          ], // closes children
        ), // closes FlutterMap
      ), // closes ClipRRect
    ), // closes Positioned.fill
            // Lớp Overlay hướng dẫn người dùng bấm vào
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_out_map, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Bấm để xem chi tiết lộ trình',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
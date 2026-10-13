import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_app/core/extensions/context_theme.dart';

class FullRouteMapScreen extends StatelessWidget {
  final double currentLat;
  final double currentLng;
  final double destinationLat;
  final double destinationLng;
  final String destinationName;

  const FullRouteMapScreen({
    super.key,
    required this.currentLat,
    required this.currentLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    final startPoint = LatLng(currentLat, currentLng);
    final endPoint = LatLng(destinationLat, destinationLng);
    
    // Bounds để bản đồ tự động Zoom cho vừa vặn 2 điểm trên màn hình
    final bounds = LatLngBounds.fromPoints([startPoint, endPoint]);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(50.0), // Padding để các marker không bị sát lề
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Lớp nền bản đồ miễn phí
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hoadev.travel_app',
              ),

              // Đường nối nét đứt
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [startPoint, endPoint],
                    color: context.colors.primary,
                    strokeWidth: 4,
                    pattern: StrokePattern.dashed(segments: [10, 5]),
                    strokeCap: StrokeCap.round,
                  ),
                ],
              ),

              // Đánh dấu các vị trí
              MarkerLayer(
                markers: [
                  Marker(
                    point: startPoint,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.my_location, color: context.colors.primary, size: 24),
                  ),
                  Marker(
                    point: endPoint,
                    width: 150,
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
              ),
            ],
          ),
          
          // Nút Quay lại
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

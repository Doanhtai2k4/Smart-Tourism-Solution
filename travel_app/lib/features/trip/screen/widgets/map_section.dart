import 'package:flutter/material.dart';
import 'package:travel_app/core/extensions/context_l10n.dart'; // Import để dùng đa ngôn ngữ
import 'package:travel_app/features/trip/screen/widgets/section_header.dart';
import 'package:travel_app/features/trip/screen/widgets/trip_map_widget.dart';

class MapSection extends StatelessWidget {
  final double currentLat;
  final double currentLng;
  final double destinationLat;
  final double destinationLng;
  final String destinationName;

  const MapSection({
    super.key,
    required this.currentLat,
    required this.currentLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Kiểm tra an toàn: Nếu AI không trả về tọa độ (bằng 0), không hiển thị Map để tránh app trông bị lỗi
    if (destinationLat == 0 && destinationLng == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. Sử dụng localization để hiển thị "Lộ trình" hoặc "Route Map" tùy theo ngôn ngữ app
        SectionHeader(
          icon: Icons.map_outlined,
          title: context.l10n.dailyItinerary, // Hoặc thay bằng key tương ứng trong file l10n của bạn
        ),

        const SizedBox(height: 16),

        // 3. Gọi Widget bản đồ thực tế mà mình đã sửa ở bước trước
        TripMapWidget(
          currentLat: currentLat,
          currentLng: currentLng,
          destinationLat: destinationLat,
          destinationLng: destinationLng,
          destinationName: destinationName,
          height: 250,
        ),
      ],
    );
  }
}
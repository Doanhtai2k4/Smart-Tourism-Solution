import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/features/addtrip/models/travel_gemini_response.dart';
import 'package:travel_app/features/discovery/providers/discovery_providers.dart';
import 'package:travel_app/features/discovery/repositories/recommendation_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/core/routing/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class TimelineActivityCard extends ConsumerWidget {
  final Activity activity;
  final String? destination;

  const TimelineActivityCard({super.key, required this.activity, this.destination});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.colors;
    final hasLocalId = activity.destinationId != null && activity.destinationId!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: cs.primary.withAlpha(30), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(context, ref),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.description,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        if (activity.reasoning != null && activity.reasoning!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildReasoningBadge(context, activity.type, activity.reasoning!),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              hasLocalId ? Icons.info_outline : Icons.map_outlined, 
                              size: 14, 
                              color: cs.primary
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasLocalId ? "Xem chi tiết địa điểm" : "Xem trên bản đồ",
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 12,
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: cs.primary.withAlpha(150),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final id = activity.destinationId;
    
    // 1. Thử tìm trong database cục bộ nếu có ID
    if (id != null && id.isNotEmpty) {
      try {
        final localDest = await ref.read(destinationDetailsProvider(id).future);
        if (localDest != null && context.mounted) {
          context.pushNamed(RouteNames.discoveryDetail, extra: localDest);
          return;
        }
      } catch (e) {
        debugPrint("Local destination not found, falling back to Maps: $e");
      }
    }

    // AI activities may not include destinationId. Resolve the trip destination
    // so the detail action still opens the in-app destination page.
    if (destination != null && destination!.trim().isNotEmpty) {
      try {
        final matches = await ref
            .read(recommendationRepositoryProvider)
            .searchDestinations(destination!.trim());
        if (matches.isNotEmpty && context.mounted) {
          context.pushNamed(RouteNames.discoveryDetail, extra: matches.first);
          return;
        }
      } catch (e) {
        debugPrint("Destination search failed, falling back to Maps: $e");
      }
    }

    // 2. Phương án dự phòng: Mở Google Maps tìm kiếm theo tên
    // Loại bỏ emoji để chuỗi tìm kiếm sạch hơn, tránh lỗi trên một số thiết bị
    var searchTitle = activity.title.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F300}-\u{1F5FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true), '').trim();
    
    if (destination != null && destination!.isNotEmpty) {
      final destLower = destination!.toLowerCase();
      final titleLower = searchTitle.toLowerCase();
      if (!titleLower.contains(destLower)) {
        searchTitle = "$searchTitle, $destination";
      }
    }
    
    final query = Uri.encodeComponent(searchTitle);
    
    // Sử dụng geo: intent cho Android để mở trực tiếp app Maps (mượt hơn)
    final googleMapsUrl = Uri.parse("geo:0,0?q=$query");
    final fallbackUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không thể tìm thấy ứng dụng bản đồ")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
      // Cố gắng mở link web nếu mọi thứ khác thất bại
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildReasoningBadge(BuildContext context, String? type, String reasoning) {
    Color badgeColor;
    IconData badgeIcon;

    switch (type?.toLowerCase()) {
      case 'indoor':
        badgeColor = Colors.blue;
        badgeIcon = Icons.beach_access; // Dùng làm biểu tượng che mưa/nắng
        break;
      case 'outdoor':
        badgeColor = Colors.green;
        badgeIcon = Icons.park;
        break;
      case 'event':
        badgeColor = Colors.purple;
        badgeIcon = Icons.celebration;
        break;
      default:
        badgeColor = Colors.orange;
        badgeIcon = Icons.auto_awesome; // Icon AI/Idea mặc định
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(20),
        border: Border.all(color: badgeColor.withAlpha(40)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(badgeIcon, size: 14, color: badgeColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reasoning,
              style: GoogleFonts.beVietnamPro(
                fontSize: 13,
                color: badgeColor.withAlpha(220),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

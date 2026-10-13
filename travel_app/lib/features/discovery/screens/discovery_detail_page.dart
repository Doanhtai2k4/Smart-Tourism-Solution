import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/core/services/tracking_service.dart';
import 'package:travel_app/core/services/recent_view_service.dart';
import 'package:travel_app/core/services/destination_service.dart';
import 'package:travel_app/features/discovery/widgets/discovery_map_section.dart';
import 'package:travel_app/shared/models/destination_model.dart';

// Components
import 'components/destination_header.dart';
import 'components/quick_info_bar.dart';
import 'components/destination_about_section.dart';
import '../providers/discovery_providers.dart';

import 'components/user_review_section.dart';
import 'components/bottom_action_bar.dart';
import 'components/nearby_places_section.dart';

class DiscoveryDetailPage extends ConsumerStatefulWidget {
  final DestinationModel destination;

  const DiscoveryDetailPage({
    super.key,
    required this.destination,
  });

  @override
  ConsumerState<DiscoveryDetailPage> createState() => _DiscoveryDetailPageState();
}

class _DiscoveryDetailPageState extends ConsumerState<DiscoveryDetailPage> {
  DateTime? _enterTime;
  late TrackingService _trackingService;

  @override
  void initState() {
    super.initState();
    _enterTime = DateTime.now();
    // Lưu vào danh sách xem gần đây
    RecentViewService.addRecentLocation(widget.destination.id);
    
    // Tăng lượt xem trên Firestore (Firebase thực tế)
    DestinationService().incrementViewCount(widget.destination.id);
    // Log view interaction with category for ML
    ref.read(trackingServiceProvider).trackViewDetail(widget.destination.id, category: widget.destination.category);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _trackingService = ref.read(trackingServiceProvider);
  }

  @override
  void dispose() {
    if (_enterTime != null) {
      final seconds = DateTime.now().difference(_enterTime!).inSeconds;
      ref.read(trackingServiceProvider).trackDwellTime(widget.destination.id, seconds, category: widget.destination.category);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu thời gian thực từ Firestore
    final liveDestAsync = ref.watch(destinationStreamProvider(widget.destination.id));

    return liveDestAsync.when(
      data: (liveDest) {
        // Ưu tiên sử dụng dữ liệu từ Stream (Real-time), 
        // nếu chưa có thì dùng dữ liệu truyền từ constructor để tránh nháy màn hình.
        final dest = liveDest ?? widget.destination;

        return Scaffold(
          backgroundColor: context.colors.surface,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // HEADER: SliverAppBar with Hero image
              DestinationHeader(destination: dest),

              // CONTENT
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Title Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 16, color: context.colors.primary),
                              const SizedBox(width: 4),
                              Text(
                                dest.province ?? 'Việt Nam',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dest.name,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface,
                              height: 1.2,
                            ),
                          ),
                          if (dest.address != null && dest.address!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.place_outlined, size: 13, color: context.colors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    dest.address!,
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 13,
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // Quick Info Bar (Horizontal Scrollable Blocks)
                    QuickInfoBar(destination: dest),
                    
                    const SizedBox(height: 32),

                    // Detail Sections: About, Category, Suitable, Activities
                    DestinationAboutSection(destination: dest),
                    
                    const SizedBox(height: 16),

                    // Map Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DiscoveryMapSection(destination: dest),
                    ),

                    const SizedBox(height: 32),

                    // Nearby Places Section (Recommendations)
                    NearbyPlacesSection(currentDestination: dest),

                    const SizedBox(height: 16),

                    // User Reviews Section (Social Proof)
                    UserReviewSection(destination: dest),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomActionBar(destination: dest),
        );
      },
      // Trường hợp lỗi hoặc đang load lần đầu: dùng dữ liệu từ constructor làm fallback
      loading: () => _buildStaticPage(widget.destination),
      error: (e, stack) => _buildStaticPage(widget.destination),
    );
  }

  Widget _buildStaticPage(DestinationModel dest) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          DestinationHeader(destination: dest),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                QuickInfoBar(destination: dest),
                const SizedBox(height: 32),
                DestinationAboutSection(destination: dest),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(destination: dest),
    );
  }
}

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/shared/models/destination_model.dart';

class HorizontalDestinationCarousel extends StatelessWidget {
  final String title;
  final AsyncValue<List<DestinationModel>> asyncData;
  final Function(DestinationModel) onTap;

  const HorizontalDestinationCarousel({
    super.key,
    required this.title,
    required this.asyncData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: GoogleFonts.beVietnamPro(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 270,
          child: asyncData.when(
            data: (destinations) {
              if (destinations.isEmpty) {
                return const Center(child: Text('Không có địa điểm nào'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  return HorizontalDestinationCard(
                    destination: destinations[index],
                    onTap: () => onTap(destinations[index]),
                  );
                },
              );
            },
            loading: () => const _HorizontalCarouselShimmer(),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Lỗi tải dữ liệu', style: GoogleFonts.beVietnamPro(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HorizontalDestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onTap;

  const HorizontalDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16, bottom: 10, left: 4, top: 4),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Full-bleed Image (Hero)
            Positioned.fill(
              child: Hero(
                tag: destination.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: destination.images.isNotEmpty ? destination.images[0] : '',
                    fit: BoxFit.cover,
                    memCacheWidth: 600, // Optimized for high density carousel
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Gradient Overlay for Text Readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(20),
                      Colors.black.withAlpha(180),
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            // Category Badge with Blur (Glassmorphism)
            if (destination.category != null)
              Positioned(
                top: 10,
                right: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      color: context.colors.primary.withAlpha(178),
                      child: Text(
                        destination.category!,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Rating Badge (Top Left)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      destination.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 11, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info Row at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Name & Price/Budget
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPriceOrBudget(context),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Row 2: Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.province ?? destination.country,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Row 3: Metrics (Social Proof)
                    Row(
                      children: [
                        _buildSmallMetric(Icons.favorite, Colors.pinkAccent, _formatCount(destination.favoriteCount)),
                        const SizedBox(width: 12),
                        _buildSmallMetric(Icons.visibility, Colors.blueAccent, _formatCount(destination.viewCount)),
                        if (destination.idealDuration != null) ...[
                          const Spacer(),
                          Text(
                            '${destination.idealDuration} ngày',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildSmallMetric(IconData icon, Color color, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withAlpha(200)),
        const SizedBox(width: 4),
        Text(
          count,
          style: GoogleFonts.beVietnamPro(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceOrBudget(BuildContext context) {
    if (destination.ticketPrice != null) {
      if (destination.ticketPrice == 0) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.green.withAlpha(50), borderRadius: BorderRadius.circular(6)),
          child: Text(
            'Miễn phí',
            style: GoogleFonts.beVietnamPro(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: Colors.amber.withAlpha(50), borderRadius: BorderRadius.circular(6)),
        child: Text(
          '${_formatCurrency(destination.ticketPrice!)} đ',
          style: GoogleFonts.beVietnamPro(
            color: Colors.amberAccent[100],
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      );
    } else if (destination.budgetLevel != null) {
      return Text(
        destination.budgetLevel!,
        style: GoogleFonts.beVietnamPro(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}m';
  }

  String _formatCurrency(int price) {
    if (price < 10000) return price.toString();
    if (price < 1000000) return '${(price / 1000).toInt()}k';
    return '${(price / 1000000).toStringAsFixed(1)}tr';
  }
}

class _HorizontalCarouselShimmer extends StatelessWidget {
  const _HorizontalCarouselShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 190,
            margin: const EdgeInsets.only(right: 16, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}

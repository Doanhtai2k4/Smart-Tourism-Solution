import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/shared/models/destination_model.dart';

class DestinationCard extends ConsumerWidget {
  final DestinationModel destination;
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = destination.images.isNotEmpty
        ? destination.images[0]
        : 'https://via.placeholder.com/400x200';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Phần Hình ảnh (Top)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildShimmer(),
                    errorWidget: (context, url, err) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                // Badge category with Blur
                if (destination.category != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          color: context.colors.primary.withAlpha(178),
                          child: Text(
                            _getLocalizedLabel(context, destination.category!),
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Trending Score Indicator if needed
                if (destination.trendingScore > 80)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.trending.toUpperCase(),
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 2. Phần Nội dung (Bottom)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dòng 1: Tên & Giá/Ngân sách
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          destination.name,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildPriceOrBudget(context),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Dòng 2: Vị trí
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, 
                        size: 14, color: context.colors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.province ?? destination.country,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            color: context.colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Dòng 3: Chỉ số tin cậy (Rating & Interaction)
                  Row(
                    children: [
                      // Rating
                      _buildInfoTag(
                        context,
                        Icons.star,
                        destination.averageRating.toStringAsFixed(1),
                        Colors.amber,
                      ),
                      const SizedBox(width: 12),
                      // Interaction Count
                      _buildInfoTag(
                        context,
                        Icons.favorite_border,
                        _formatCount(destination.favoriteCount),
                        Colors.pinkAccent,
                      ),
                      if (destination.viewCount > 0) ...[
                        const SizedBox(width: 12),
                        _buildInfoTag(
                          context,
                          Icons.visibility_outlined,
                          _formatCount(destination.viewCount),
                          Colors.blue,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceOrBudget(BuildContext context) {
    if (destination.ticketPrice != null) {
      if (destination.ticketPrice == 0) {
        return Text(
          context.l10n.free,
          style: GoogleFonts.beVietnamPro(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        );
      }
      return Text(
        '${_formatCurrency(destination.ticketPrice!)} đ',
        style: GoogleFonts.beVietnamPro(
          color: context.colors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      );
    } else if (destination.budgetLevel != null) {
      return Text(
        _getLocalizedLabel(context, destination.budgetLevel!),
        style: GoogleFonts.beVietnamPro(
          color: context.colors.outline,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInfoTag(BuildContext context, IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}m';
  }

  String _formatCurrency(int price) {
    if (price < 1000000) return '${(price / 1000).toInt()}k';
    return '${(price / 1000000).toStringAsFixed(1)}tr';
  }

  String _getLocalizedLabel(BuildContext context, String value) {
    final l10n = context.l10n;
    switch (value) {
      case 'Biển': return l10n.cat_beach;
      case 'Núi': return l10n.cat_mountain;
      case 'Thành phố': return l10n.cat_city;
      case 'Văn hóa': return l10n.cat_culture;
      case 'Giá rẻ': return l10n.budget_cheap;
      case 'Trung bình': return l10n.budget_medium;
      case 'Cao cấp': return l10n.budget_luxury;
      default: return value;
    }
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(height: 180, color: Colors.white),
    );
  }
}

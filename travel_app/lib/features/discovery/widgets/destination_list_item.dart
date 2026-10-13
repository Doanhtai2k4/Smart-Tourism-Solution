import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/shared/models/destination_model.dart';

class DestinationListItem extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onTap;
  /// When true, shows an "AI Pick" badge. Set by the discovery page
  /// based on how many items were ranked by the AI server.
  final bool isAiPick;

  const DestinationListItem({
    super.key,
    required this.destination,
    required this.onTap,
    this.isAiPick = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = destination.images.isNotEmpty
        ? destination.images[0]
        : 'https://via.placeholder.com/400x200';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Image (Hero) + optional AI Pick badge
            Hero(
              tag: destination.id,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      memCacheWidth: 330,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[100]),
                      errorWidget: (context, url, err) => Container(
                        width: 110,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  if (isAiPick)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withAlpha(76),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome,
                                size: 9, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              'AI Pick',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Right: Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Row 1: Name & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildRatingBadge(),
                      ],
                    ),

                    // Row 2: Location & Basic Metrics
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, 
                          size: 13, color: context.colors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.province ?? destination.country,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              color: context.colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.visibility_outlined, 
                          size: 13, color: context.colors.outline),
                        const SizedBox(width: 4),
                        Text(
                          _formatCount(destination.viewCount),
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    // Row 3: Budget & Duration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Row(
                          children: [
                            Icon(Icons.payments_outlined, 
                              size: 13, color: context.colors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              _getPriceLabel(),
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.colors.secondary,
                              ),
                            ),
                          ],
                        ),
                        if (destination.idealDuration != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer.withAlpha(76),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${destination.idealDuration} ngày',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: context.colors.primary,
                              ),
                            ),
                          ),
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

  Widget _buildRatingBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
        const SizedBox(width: 2),
        Text(
          destination.averageRating.toStringAsFixed(1),
          style: GoogleFonts.beVietnamPro(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.amber[800],
          ),
        ),
      ],
    );
  }

  String _getPriceLabel() {
    if (destination.ticketPrice != null) {
      if (destination.ticketPrice == 0) return 'Miễn phí';
      return '${_formatCurrency(destination.ticketPrice!)} đ';
    }
    return destination.budgetLevel ?? 'Chưa cập nhật';
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

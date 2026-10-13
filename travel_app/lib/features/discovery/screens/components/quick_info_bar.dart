import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/shared/models/destination_model.dart';

class QuickInfoBar extends StatelessWidget {
  final DestinationModel destination;

  const QuickInfoBar({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildInfoChip(
            context,
            icon: Icons.star_rounded,
            iconColor: Colors.amber,
            label: '${destination.averageRating}',
            subLabel: context.l10n.likes_count(destination.favoriteCount ?? 0),
          ),
          const SizedBox(width: 12),
          _buildInfoChip(
            context,
            icon: Icons.payments_outlined,
            iconColor: Colors.green,
            label: destination.budgetLevel ?? context.l10n.flexible,
            subLabel: _formatTicketPrice(context, destination.ticketPrice),
          ),
          const SizedBox(width: 12),
          _buildInfoChip(
            context,
            icon: Icons.hourglass_bottom_rounded,
            iconColor: Colors.blue,
            label: context.l10n.days_count(destination.idealDuration ?? 0),
            subLabel: context.l10n.ideal,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant.withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              Text(
                subLabel,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 11,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTicketPrice(BuildContext context, int? price) {
    if (price == null || price <= 0) return context.l10n.free;
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return formatter.format(price);
  }
}

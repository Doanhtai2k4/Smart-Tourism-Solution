import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/shared/models/destination_model.dart';

class DestinationAboutSection extends StatefulWidget {
  final DestinationModel destination;

  const DestinationAboutSection({super.key, required this.destination});

  @override
  State<DestinationAboutSection> createState() => _DestinationAboutSectionState();
}

class _DestinationAboutSectionState extends State<DestinationAboutSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final dest = widget.destination;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context.l10n.about_this_place),
          const SizedBox(height: 12),
          
          // Expandable Description
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dest.description,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                    height: 1.6,
                  ),
                  maxLines: _isExpanded ? null : 4,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                Text(
                  _isExpanded ? context.l10n.show_less : context.l10n.read_more,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Metadata Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (dest.category != null)
                _buildMetadataChip(context, dest.category!, Icons.category_outlined),
              ...dest.bestTimeToVisit.map((season) => 
                _buildMetadataChip(context, season, Icons.wb_sunny_outlined)),
              ...dest.suitableFor.map((suitable) => 
                _buildMetadataChip(context, suitable, Icons.people_outline)),
            ],
          ),
          const SizedBox(height: 32),

          // Top Activities
          if (dest.topActivities.isNotEmpty) ...[
            _buildSectionTitle(context.l10n.top_activities),
            const SizedBox(height: 16),
            ...dest.topActivities.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.beVietnamPro(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMetadataChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withAlpha(76),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.primaryContainer.withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

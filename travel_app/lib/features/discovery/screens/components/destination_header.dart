import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/shared/models/destination_model.dart';
import 'package:travel_app/shared/widgets/share_bottom_sheet.dart';
import 'package:travel_app/core/services/tracking_service.dart';
import 'package:travel_app/core/services/realtime_recommender_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DestinationHeader extends ConsumerStatefulWidget {
  final DestinationModel destination;

  const DestinationHeader({super.key, required this.destination});

  @override
  ConsumerState<DestinationHeader> createState() => _DestinationHeaderState();
}

class _DestinationHeaderState extends ConsumerState<DestinationHeader> {

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingServiceProvider);
    final cs = context.colors;

    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      stretch: true,
      backgroundColor: cs.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withAlpha(76),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        _buildActionButton(
          icon: Icons.share_rounded,
          onPressed: () {
            ShareBottomSheet.show(
              context,
              widget.destination,
              onShareSuccess: () {
                tracking.trackShare(widget.destination.id);
                ref.read(realtimeRecommenderProvider.notifier)
                    .updatePreferences(widget.destination, weight: 2.0);
              },
            );
          },
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Hero(
          tag: widget.destination.id,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.destination.images.isNotEmpty 
                    ? widget.destination.images.first 
                    : 'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?q=80&w=1000&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black26,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black54,
                    ],
                    stops: [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color iconColor = Colors.white,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CircleAvatar(
        backgroundColor: Colors.black.withAlpha(76),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : IconButton(
                icon: Icon(icon, color: iconColor, size: 20),
                onPressed: onPressed,
              ),
      ),
    );
  }

}

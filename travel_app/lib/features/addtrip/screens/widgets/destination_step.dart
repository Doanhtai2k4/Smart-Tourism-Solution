import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app/features/addtrip/screens/widgets/selectable_chip.dart';
import 'package:travel_app/features/addtrip/screens/widgets/step_title.dart';

import 'package:travel_app/core/extensions/context_theme.dart';
import '../../../../core/enums/trip_type.dart';
import '../../../../core/extensions/context_l10n.dart';
import '../../../../core/utilities/trip_utils.dart';
import '../../../../shared/models/destination_model.dart';
import '../../providers/travel_provider.dart';
import 'input_label.dart';

class DestinationStep extends ConsumerWidget {
  final TextEditingController currentLocationController;
  final TextEditingController destinationController;
  final TripType? selectedTripType;
  final ValueChanged<TripType> onTripTypeChanged;

  const DestinationStep({
    super.key,
    required this.currentLocationController,
    required this.destinationController,
    required this.selectedTripType,
    required this.onTripTypeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trendingAsync = ref.watch(trendingDestinationsProvider);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(
            icon: Icons.place_outlined,
            title: l10n.destination_step_title,
            subtitle: l10n.destination_step_subtitle,
          ),
          const SizedBox(height: 32),

          InputLabel(text: l10n.destination_label),
          const SizedBox(height: 12),

          // Dynamic Trending Destinations
          SizedBox(
            height: 100,
            child: trendingAsync.when(
              data: (destinations) {
                if (destinations.isEmpty) {
                  return _buildFallbackPicks(context);
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: destinations.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final dest = destinations[index];
                    return _buildTrendingCard(context, dest);
                  },
                );
              },
              loading: () => _buildLoadingShimmer(),
              error: (err, stack) => _buildFallbackPicks(context),
            ),
          ),

          const SizedBox(height: 16),
          CustomTextField(
            controller: destinationController,
            hintText: l10n.destination_hint,
            prefixIcon: Icons.location_on_outlined,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 24),

          InputLabel(text: l10n.starting_from_label),
          const SizedBox(height: 8),
          CustomTextField(
            controller: currentLocationController,
            hintText: l10n.starting_from_hint,
            prefixIcon: Icons.my_location_outlined,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 32),

          InputLabel(text: l10n.trip_type_label),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                TripType.values.map((type) {
                  return SelectableChip(
                    label: type.label(context),
                    icon: getTripTypeIcon(type),
                    isSelected: selectedTripType == type,
                    onTap: () => onTripTypeChanged(type),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(BuildContext context, DestinationModel destination) {
    final imageUrl =
        destination.images.isNotEmpty
            ? destination.images.first
            : 'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?q=80&w=1000&auto=format&fit=crop';

    return GestureDetector(
      onTap: () => destinationController.text = destination.name,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(80),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destination.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    destination.averageRating.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackPicks(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickPick(context, 'Hà Nội'),
          _buildQuickPick(context, 'Đà Nẵng'),
          _buildQuickPick(context, 'Đà Lạt'),
          _buildQuickPick(context, 'Sapa'),
          _buildQuickPick(context, 'Phú Quốc'),
        ],
      ),
    );
  }

  Widget _buildQuickPick(BuildContext context, String city) {
    final cs = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(city),
        avatar: Icon(Icons.trending_up, size: 14, color: cs.primary),
        onPressed: () => destinationController.text = city,
        backgroundColor: cs.surface,
        side: BorderSide(color: cs.outlineVariant.withAlpha(50)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

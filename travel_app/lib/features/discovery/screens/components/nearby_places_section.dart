import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/routing/app_routes.dart';
import 'package:travel_app/features/discovery/providers/discovery_providers.dart';
import 'package:travel_app/features/discovery/widgets/horizontal_destination_carousel.dart';
import 'package:travel_app/shared/models/destination_model.dart';

class NearbyPlacesSection extends ConsumerWidget {
  final DestinationModel currentDestination;

  const NearbyPlacesSection({
    super.key,
    required this.currentDestination,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogDestinationsProvider);

    return catalogAsync.when(
      data: (allDestinations) {
        final List<DestinationModel> nearby = allDestinations
            .where((d) => d.id != currentDestination.id)
            .toList();

        final curLat = currentDestination.latitude;
        final curLng = currentDestination.longitude;

        if (curLat != null && curLng != null && curLat != 0 && curLng != 0) {
          nearby.sort((a, b) {
            final distA = (a.latitude != null && a.longitude != null)
                ? Geolocator.distanceBetween(curLat, curLng, a.latitude!, a.longitude!)
                : double.infinity;
            final distB = (b.latitude != null && b.longitude != null)
                ? Geolocator.distanceBetween(curLat, curLng, b.latitude!, b.longitude!)
                : double.infinity;
            return distA.compareTo(distB);
          });
        } else {
          // Fallback: Sort by category similarity
          nearby.sort((a, b) {
            final simA = (a.category == currentDestination.category) ? 0 : 1;
            final simB = (b.category == currentDestination.category) ? 0 : 1;
            return simA.compareTo(simB);
          });
        }

        if (nearby.isEmpty) return const SizedBox.shrink();

        return HorizontalDestinationCarousel(
          title: context.l10n.nearby_places,
          asyncData: AsyncValue.data(nearby.take(10).toList()),
          onTap: (dest) {
             context.pushNamed(
              RouteNames.discoveryDetail,
              extra: dest,
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

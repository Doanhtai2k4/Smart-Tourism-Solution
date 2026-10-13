import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/shared/models/destination_model.dart';
import 'package:travel_app/core/services/tracking_service.dart';


class DiscoveryMapSection extends ConsumerWidget {
  final DestinationModel destination;

  const DiscoveryMapSection({
    super.key,
    required this.destination,
  });

  Future<void> _launchMaps(WidgetRef ref) async {
    final lat = destination.latitude;
    final lng = destination.longitude;
    if (lat == null || lng == null) return;
    
    // Track map interaction
    ref.read(trackingServiceProvider).trackMapInteraction(destination.id);

    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lat = destination.latitude;
    final lng = destination.longitude;
    final cs = context.colors;

    if (lat == null || lng == null || (lat == 0 && lng == 0)) {
      return const SizedBox.shrink();
    }

    final point = LatLng(lat, lng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vị trí địa điểm',
              style: GoogleFonts.beVietnamPro(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _launchMaps(ref),
              icon: const Icon(Icons.map_rounded, size: 18),
              label: Text(
                'Mở bản đồ',
                style: GoogleFonts.beVietnamPro(fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withAlpha(50)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 13.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.trekko.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 150,
                      height: 80,
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 35),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4)
                              ],
                            ),
                            child: Text(
                              destination.name,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

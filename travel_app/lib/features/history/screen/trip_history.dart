import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/common/empty_state.dart';
import '../../../core/common/loader.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../shared/models/travel_db_model.dart';
import '../../../shared/models/destination_model.dart';
import '../../../shared/widgets/trip_card.dart';
import '../../trip/provider/user_trips_provider.dart';
import '../../../core/services/recent_view_service.dart';

class TripHistory extends ConsumerStatefulWidget {
  const TripHistory({super.key});

  @override
  ConsumerState<TripHistory> createState() => _TripHistoryState();
}

class _TripHistoryState extends ConsumerState<TripHistory> {
  @override
  Widget build(BuildContext context) {
    final cs = context.colors;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          title: Text(
            context.l10n.trip_history_title,
            style: GoogleFonts.beVietnamPro(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          bottom: TabBar(
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.primary,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            tabs: [
              Tab(text: context.l10n.tab_visited),
              Tab(text: context.l10n.tab_recent),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            VisitedTripsTab(),
            RecentViewsTab(),
          ],
        ),
      ),
    );
  }
}

class VisitedTripsTab extends ConsumerWidget {
  const VisitedTripsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitedTripsAsync = ref.watch(visitedTripsProvider);

    return visitedTripsAsync.when(
      loading: () => const Center(child: Loader()),
      error: (e, _) => Center(child: Text(context.l10n.error_occurred(e.toString()))),
      data: (trips) {
        if (trips.isEmpty) {
          return EmptyState(
            icon: Icons.history_edu_rounded,
            title: context.l10n.no_visited_trips_title,
            subtitle: context.l10n.no_visited_trips_subtitle,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Stack(
                children: [
                  TripCard(
                    trip: trip,
                    onTap: () => context.pushNamed(
                      'trip',
                      pathParameters: {'travelId': trip.travelId},
                    ),
                  ),
                  // Overlay Badge for visited date
                  if (trip.visitedAt != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy').format(trip.visitedAt!),
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class RecentViewsTab extends StatefulWidget {
  const RecentViewsTab({super.key});

  @override
  State<RecentViewsTab> createState() => _RecentViewsTabState();
}

class _RecentViewsTabState extends State<RecentViewsTab> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: RecentViewService.getRecentLocationIds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Loader());
        }

        final recentIds = snapshot.data ?? [];
        if (recentIds.isEmpty) {
          return EmptyState(
            icon: Icons.visibility_outlined,
            title: context.l10n.no_recent_views_title,
            subtitle: context.l10n.no_recent_views_subtitle,
          );
        }

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('destinations')
              .where(FieldPath.documentId, whereIn: recentIds)
              .get(),
          builder: (context, firestoreSnapshot) {
            if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Loader());
            }

            if (!firestoreSnapshot.hasData || firestoreSnapshot.data!.docs.isEmpty) {
              return EmptyState(
                icon: Icons.error_outline,
                title: context.l10n.error_loading_data,
                subtitle: context.l10n.please_try_again,
              );
            }

            // Map data sang DestinationModel
            final fetchedDestinations = firestoreSnapshot.data!.docs.map((doc) {
              return DestinationModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
            }).toList();

            // QUAN TRỌNG: Sắp xếp lại danh sách theo đúng thứ tự của recentIds
            final sortedDestinations = recentIds.map((id) {
              return fetchedDestinations.firstWhere((d) => d.id == id);
            }).toList();

            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: sortedDestinations.length,
              itemBuilder: (context, index) {
                final destination = sortedDestinations[index];
                return _RecentViewCard(destination: destination);
              },
            );
          },
        );
      },
    );
  }
}

class _RecentViewCard extends StatelessWidget {
  final DestinationModel destination;
  const _RecentViewCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        'discovery-detail', 
        extra: destination,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: context.colors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      destination.images.isNotEmpty 
                        ? destination.images.first 
                        : 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              destination.averageRating.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: context.colors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: context.colors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.province ?? destination.country,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 11,
                              color: context.colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
}

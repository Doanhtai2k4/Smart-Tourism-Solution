import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/features/discovery/providers/discovery_providers.dart';
import 'package:travel_app/core/routing/app_routes.dart';
import 'package:travel_app/core/services/realtime_recommender_service.dart';
import 'package:travel_app/features/discovery/widgets/ai_destination_shimmer.dart';
import 'package:travel_app/core/services/tracking_service.dart';
import 'package:travel_app/shared/models/destination_model.dart';
import 'package:travel_app/features/discovery/widgets/horizontal_destination_carousel.dart';
import 'package:travel_app/shared/widgets/filter_bottom_sheet.dart';
import 'package:travel_app/features/search/providers/search_filter_provider.dart';
import 'package:travel_app/shared/widgets/active_filters_header.dart';
import '../widgets/discovery_category_bar.dart';
import '../widgets/destination_list_item.dart';
import '../widgets/vertical_destination_card.dart';
import '../../../l10n/app_localizations.dart';

class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> with WidgetsBindingObserver {
  AppLocalizations get l10n => context.l10n;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.detached) {
      // Force sync preferences when app goes to background or is about to be terminated
      ref.read(realtimeRecommenderProvider.notifier).forceSync();
    }
  }

  void _onDestinationTap(DestinationModel destination) {
    // Track user activity using new TrackingService
    ref.read(trackingServiceProvider).trackViewDetail(destination.id);
    
    // Real-time In-Session Recommendation Tracking
    ref.read(realtimeRecommenderProvider.notifier).updatePreferences(destination, weight: 1.0);

    // Navigate to Discovery Detail
    if (mounted) {
      context.pushNamed(RouteNames.discoveryDetail, extra: destination);
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(searchFilterProvider);
    final hasActiveSearch = filter.hasActiveSearch;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(catalogDestinationsProvider);
            ref.invalidate(trendingDestinationsProvider);
          },
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context, filter),

              if (!hasActiveSearch) ...[
                    // Tầng 1: Địa điểm Hot Nổi Bật (Trending)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: HorizontalDestinationCarousel(
                          title: l10n.trending_destinations_title,
                          asyncData: ref.watch(trendingDestinationsProvider),
                          onTap: _onDestinationTap,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // Tầng 2: Dành Riêng Cho Bạn (Real-time Context)
                    SliverToBoxAdapter(
                      child: HorizontalDestinationCarousel(
                        title: l10n.personalized_destinations_title,
                        asyncData: ref.watch(realtimeDestinationsProvider),
                        onTap: _onDestinationTap,
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Tiêu đề Tầng 3
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          l10n.you_might_like_title,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),

                    // Tầng 3: Gợi ý AI (Vertical List)
                    _buildAiRecommendations(context),
                  ] else ...[
                    // Active Filters Chips (only shown if searching)
                    SliverToBoxAdapter(
                      child: const ActiveFiltersHeader(),
                    ),
                    // Search Results Tier
                    _buildSearchResults(context, filter),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, FilterCriteria filter) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 280, // Increased to provide enough space for branding + search bar
      backgroundColor: context.colors.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colors.primaryContainer.withAlpha(200),
                    context.colors.surface,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50, // Slightly higher to accommodate Safe Area if needed
              left: 20,
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trekko',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: context.colors.primary,
                        letterSpacing: -1.2,
                      ),
                    ),
                    Text(
                      l10n.greeting_message,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(140), // Increased slightly for spacing
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withAlpha(20),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(searchFilterProvider.notifier).updateQuery(val);
                    if (val.length > 2) {
                      // Track search query for ML (Only if > 2 chars to avoid noise)
                      ref.read(trackingServiceProvider).trackSearch(val);
                    }
                    setState(() {});
                  },
                  style: GoogleFonts.outfit(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: l10n.search_destination_hint_discovery,
                    hintStyle: GoogleFonts.outfit(color: context.colors.onSurfaceVariant.withAlpha(150)),
                    prefixIcon: Icon(Icons.search_rounded, color: context.colors.primary),
                    suffixIcon: filter.isAnyFilterActive 
                      ? IconButton(
                          icon: const Icon(Icons.tune_rounded, color: Colors.blue),
                          onPressed: _showFilterSheet,
                        )
                      : IconButton(
                          icon: const Icon(Icons.tune_rounded),
                          onPressed: _showFilterSheet,
                        ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const DiscoveryCategoryBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiRecommendations(BuildContext context) {
    return ref.watch(aiDestinationsProvider).when(
      data: (result) {
        final destinations = result.destinations;
        final aiPickCount = result.aiPickCount;

        if (destinations.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l10n.no_recommendations_found),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return VerticalDestinationCard(
                destination: destination,
                onTap: () => _onDestinationTap(destination),
              );
            },
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.builder(
          itemCount: 3,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: AiDestinationShimmer(),
          ),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text('${l10n.error}: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSearchResults(BuildContext context, FilterCriteria filter) {
    return ref.watch(destinationSearchResultsProvider).when(
      data: (destinations) {
        if (destinations.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Icon(Icons.search_off, size: 64, color: Colors.grey.withAlpha(128)),
                  const SizedBox(height: 16),
                    Text(
                      l10n.search_no_results(''), // Should really have query but current implementation doesn't pass it easy
                      style: GoogleFonts.beVietnamPro(color: Colors.grey),
                    ),
                  if (filter.isAnyFilterActive)
                    TextButton(
                      onPressed: () => ref.read(searchFilterProvider.notifier).clearFilters(),
                        child: Text(l10n.clear_filters),
                    ),
                ],
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList.builder(
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return DestinationListItem(
                destination: destination,
                onTap: () => _onDestinationTap(destination),
              );
            },
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        sliver: SliverList.builder(
          itemCount: 3,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: AiDestinationShimmer(),
          ),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(child: Text(context.l10n.search_error(error.toString()))),
      ),
    );
  }

}

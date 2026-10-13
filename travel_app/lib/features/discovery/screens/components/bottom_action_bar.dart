import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/core/routing/app_routes.dart';
import 'package:travel_app/features/discovery/providers/favorites_provider.dart';
import 'package:travel_app/features/discovery/repositories/favorites_repository.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import 'package:travel_app/shared/models/destination_model.dart';
import 'package:travel_app/core/services/tracking_service.dart';
import 'package:travel_app/core/services/realtime_recommender_service.dart';

class BottomActionBar extends ConsumerStatefulWidget {
  final DestinationModel destination;

  const BottomActionBar({super.key, required this.destination});

  @override
  ConsumerState<BottomActionBar> createState() => _BottomActionBarState();
}

class _BottomActionBarState extends ConsumerState<BottomActionBar> {
  bool _isToggling = false;

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingServiceProvider);
    final cs = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            // Favorite Button (Left)
            ref.watch(isFavoriteProvider(widget.destination.id)).when(
              data: (isFav) => Container(
                decoration: BoxDecoration(
                  color: isFav ? Colors.red.withAlpha(25) : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isFav ? Colors.red.withAlpha(50) : cs.outlineVariant.withAlpha(128)),
                ),
                child: IconButton(
                  iconSize: 28,
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : cs.onSurfaceVariant,
                  ),
                  onPressed: _isToggling ? null : () => _toggleFavorite(isFav),
                ),
              ),
              loading: () => Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, stack) => const Icon(Icons.error_outline),
            ),
            const SizedBox(width: 16),

            // Plan Trip Button (Right)
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    tracking.trackPlanTrip(widget.destination.id);
                    ref.read(realtimeRecommenderProvider.notifier)
                        .updatePreferences(widget.destination, weight: 5.0);
                        
                    context.pushNamed(
                      RouteNames.planTrip,
                      extra: '${widget.destination.name}, ${widget.destination.country}',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    context.l10n.plan_itinerary_now,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(bool isFav) async {
    final user = ref.read(userInfoProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.login_to_favorite_error)),
      );
      return;
    }

    setState(() => _isToggling = true);
    
    try {
      if (!isFav) {
        ref.read(trackingServiceProvider).trackAddFavorite(widget.destination.id);
        ref.read(realtimeRecommenderProvider.notifier)
            .updatePreferences(widget.destination, weight: 3.0);
      }

      await ref.read(favoritesRepositoryProvider).toggleFavorite(
        userId: user.uid,
        destination: widget.destination,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.somethingWentWrong)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }
}

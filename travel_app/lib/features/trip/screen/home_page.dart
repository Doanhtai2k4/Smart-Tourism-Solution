import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/core/common/async_view.dart';
import 'package:travel_app/core/common/loader.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/features/trip/screen/widgets/month_widget.dart';

import '../../../core/common/app_error_state.dart';
import '../../../core/common/empty_state.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../shared/widgets/trip_card.dart';
import '../model/month_this_count.dart';
import '../provider/user_trips_provider.dart';
import '../../../features/auth/provider/auth_providers.dart';

import '../../../core/utils.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/routing/app_routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Chạy các kiểm tra tự động khi mở app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAutomatedChecks();
    });
  }

  Future<void> _runAutomatedChecks() async {
    final user = ref.read(userInfoProvider);
    if (user == null) return;

    final notificationService = NotificationService();

    // 1. Kiểm tra lễ hội tự động (hỗ trợ đa ngôn ngữ)
    if (mounted) {
      await notificationService.checkAndTriggerFestivalNotifications(
        user.uid,
        languageCode: Localizations.localeOf(context).languageCode,
      );
    }

    // 2. Kiểm tra chuyến đi sắp tới (Ví dụ gợi ý logic)
    await _checkAndNotifyUpcomingTrips(user.uid);
  }

  Future<void> _checkAndNotifyUpcomingTrips(String userId) async {
    try {
      final now = DateTime.now();
      final threeDaysLater = now.add(const Duration(days: 3));
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where(
            Filter.or(
              Filter('member_ids', arrayContains: userId),
              Filter('memberIds', arrayContains: userId),
            ),
          )
          .where('startDate', isGreaterThanOrEqualTo: now.toIso8601String())
          .where('startDate', isLessThanOrEqualTo: threeDaysLater.toIso8601String())
          .get();
 
      if (querySnapshot.docs.isNotEmpty) {
        final notificationService = NotificationService();
        for (var doc in querySnapshot.docs) {
          final tripData = doc.data();
          final status = tripData['status'] as String? ?? 'planned';
          final isVisited = tripData['isVisited'] as bool? ?? false;
          if (status == 'visited' || isVisited) {
            continue;
          }
          final tripName = tripData['destination'] ?? 'chuyến đi';
          // Avoid spamming if already notified recently - simplistic check
          // Ideally we would have a 'notified' flag in the trip or a local preference
          await notificationService.sendNotification(
            userId: userId,
            title: "Chuyến đi sắp tới!",
            body: "Bạn có một chuyến đi đến $tripName sắp bắt đầu. Đừng quên chuẩn bị hành lý nhé!",
            type: 'upcoming_trip',
            travelId: doc.id,
          );
        }
      }
    } catch (e) {
      debugPrint("Error checking upcoming trips: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersTrip = ref.watch(userTripsProvider);
    final monthCountAsync = ref.watch(monthTripCountProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          const _AppBarWidget(),
          _HeaderWidget(monthCountAsync: monthCountAsync),
          _JoinTripButton(onJoin: () => _showJoinTripDialog(context)),
          _TripsListWidget(usersTrip: usersTrip),
        ],
      ),
    );
  }

  void _showJoinTripDialog(BuildContext context) {
    context.pushNamed('groupTrips');
  }
}

class _JoinTripButton extends StatelessWidget {
  final VoidCallback onJoin;
  const _JoinTripButton({required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onJoin,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.colors.primary,
                  child: const Icon(Icons.group_add, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.joinGroup,
                        style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        context.l10n.joinGroupDescription,
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: context.colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



/// Extracted AppBar widget - only rebuilds when necessary
class _AppBarWidget extends StatelessWidget {
  const _AppBarWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0.5,
      expandedHeight: 76,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
        title: Text(
          "Trekko",
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      actions: [
        const _UserProfileAvatar(),
        const NotificationIconBadge(),
      ],
    );
  }
}

class _UserProfileAvatar extends ConsumerWidget {
  const _UserProfileAvatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () {
          context.pushNamed(RouteNames.profile);
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE4E6EB),
            backgroundImage: getAvatarProvider(user?.profilePic),
            child: getAvatarProvider(user?.profilePic) == null
                ? const Icon(Icons.person, color: Color(0xFF8A8D91), size: 24)
                : null,
          ),
        ),
      ),
    );
  }
}

class NotificationIconBadge extends ConsumerWidget {
  const NotificationIconBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final theme = Theme.of(context);

    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      // Lắng nghe real-time các thông báo CHƯA ĐỌC
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        int unreadCount = 0;
        if (snapshot.hasData) {
          unreadCount = snapshot.data!.docs.length;
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8, right: 19),
          child: GestureDetector(
            onTap: () {
              context.pushNamed(RouteNames.notifications);
            },
            child: Badge(
              backgroundColor: Colors.red,
              label: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              isLabelVisible: unreadCount > 0, // Chỉ hiện badge nếu có thông báo mới
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Icon(Icons.notifications_none_rounded, color: theme.colorScheme.onSurface),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Extracted Header widget - only rebuilds when monthCountAsync changes
class _HeaderWidget extends StatelessWidget {
  final AsyncValue<MonthTripCount> monthCountAsync;

  const _HeaderWidget({required this.monthCountAsync});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            AsyncView(
              value: monthCountAsync,
              builder: (count) => MonthWidget(count.thisMonth, count.lastMonth),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.yourTrips,
              style: context.text.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extracted TripsList widget - only rebuilds when usersTrip changes
class _TripsListWidget extends StatelessWidget {
  final AsyncValue<List<dynamic>> usersTrip;

  const _TripsListWidget({required this.usersTrip});

  @override
  Widget build(BuildContext context) {
    return usersTrip.when(
      loading: () => const SliverToBoxAdapter(child: Center(child: Loader())),
      error: (e, _) =>
          SliverToBoxAdapter(child: AppErrorState(message: e.toString())),
      data: (trips) {
        if (trips.isEmpty) {
          return SliverToBoxAdapter(
            child: EmptyState(
              title: context.l10n.noTripsYet,
              icon: Icons.travel_explore_outlined,
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final trip = trips[index];
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: TripCard(
                trip: trip,
                onTap: () => context.pushNamed(
                  'trip',
                  pathParameters: {'travelId': trip.travelId},
                ),
              ),
            );
          }, childCount: trips.length),
        );
      },
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLast;

  const _AppBarAction({
    required this.icon,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: 8, right: isLast ? 19 : 12),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(icon, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}

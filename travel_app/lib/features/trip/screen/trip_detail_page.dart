import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:travel_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/features/trip/screen/widgets/accomodation_section.dart';
import 'package:travel_app/features/trip/screen/widgets/budget_card.dart';
import 'package:travel_app/features/trip/screen/widgets/map_section.dart';
import 'package:travel_app/features/trip/screen/widgets/mark_visited_button.dart';
import 'package:travel_app/features/trip/screen/widgets/section_header.dart';
import 'package:travel_app/features/trip/screen/widgets/timeline_activity_card.dart';
import 'package:travel_app/features/trip/screen/widgets/transport_section.dart';
import 'package:travel_app/features/trip/screen/widgets/trekko_slider.dart';
import 'package:travel_app/features/trip/screen/widgets/user_preferences_section.dart';
import 'package:travel_app/features/trip/screen/widgets/weather_section.dart';
import '../../weather/screens/widgets/weather_widget.dart';
import 'package:travel_app/shared/models/travel_db_model.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/common/app_dialog.dart';
import '../../../core/common/async_view.dart';
import '../../../core/enums/trip_status.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_snackbar.dart';
import '../../../core/extensions/context_theme.dart';
import '../../settings/provider/settings_provider.dart';
import '../provider/user_trips_provider.dart';
import '../../auth/provider/auth_providers.dart';
import 'package:travel_app/features/packing/screens/packing_list_screen.dart';

class TripDetailPage extends ConsumerStatefulWidget {
  final String travelId;

  const TripDetailPage({super.key, required this.travelId});

  @override
  ConsumerState<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends ConsumerState<TripDetailPage> {
  AppLocalizations get l10n => context.l10n;
  bool _languageDialogShown = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.travelId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy chuyến đi')),
          );
        }

        final tripData = snapshot.data!.data() as Map<String, dynamic>;
        // Đảm bảo travelId luôn chính xác từ document ID
        final trip = TravelDbModel.fromJson({
          ...tripData,
          'travelId': snapshot.data!.id,
        });

        _checkAndShowLanguageDialog(trip);
        return _buildTripContent(context, ref, trip);
      },
    );
  }

  void _checkAndShowLanguageDialog(TravelDbModel trip) async {
    if (_languageDialogShown) return;

    final locale = await ref.read(languageProvider.future);
    final currentLang = locale.languageCode;

    if (trip.language == currentLang) return;

    _languageDialogShown = true;
    if (!mounted) return;
    final travelId = widget.travelId;

    final shouldRegenerate = await AppDialog.confirm(
      context,
      title: l10n.tripDifferentLanguageTitle,
      message: l10n.tripDifferentLanguageMessage(
        trip.language.toUpperCase(),
        currentLang.toUpperCase(),
      ),
      confirmText: l10n.regenerate,
      cancelText: l10n.keepOriginal,
    );

    if (shouldRegenerate == true && mounted) {
      ref.read(regenerateTripInCurrentLanguageProvider(travelId));
    }
  }

  Widget _buildTripContent(BuildContext context, WidgetRef ref, TravelDbModel trip) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Stack(
        children: [
          CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, trip),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
              child: UserPreferencesSection(trip: trip),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildMembersSection(context, trip),
          ),

          SliverToBoxAdapter(
            child: _buildPackingListCard(context, trip),
          ),
          
          SliverToBoxAdapter(
            child: _buildExpenseTrackerCard(context, trip),
          ),

          SliverToBoxAdapter(
            child: _buildVaultCard(context, trip),
          ),

          SliverToBoxAdapter(
            child: _buildEmergencyCard(context, trip),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
              child: SectionHeader(
                icon: Icons.calendar_today_outlined,
                title: context.l10n.dailyItinerary,
              ),
            ),
          ),

          // Timeline Content
          ...trip.dailyPlan.asMap().entries.map(
                (entry) => _buildDayTimelineSliver(context, entry.value, entry.key, trip.destination),
              ),

          // Additional Sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trip.accommodationSuggestions.isNotEmpty)
                    AccommodationSection(suggestions: trip.accommodationSuggestions),

                  const SizedBox(height: 24),

                  TransportationSection(details: trip.transportationDetails),

                  const SizedBox(height: 24),

                  if (trip.destinationLat != null && trip.destinationLng != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          icon: Icons.wb_sunny_outlined,
                          title: "Dự báo thời tiết chuyến đi",
                        ),
                        TripWeatherWidget(
                          travelId: trip.travelId,
                          destination: trip.destination,
                          lat: trip.destinationLat!,
                          lng: trip.destinationLng!,
                          startDate: trip.startDate,
                          endDate: trip.endDate,
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  MapSection(
                    currentLat: trip.currentLat ?? 0,
                    currentLng: trip.currentLng ?? 0,
                    destinationLat: trip.destinationLat ?? 0,
                    destinationLng: trip.destinationLng ?? 0,
                    destinationName: trip.destination,
                  ),

                  const SizedBox(height: 24),

                  BudgetCard(
                    budget: trip.budget?.toString() ?? '0',
                    budgetType: trip.budgetType,
                    destination: trip.destination,
                    startDate: trip.startDate,
                    endDate: trip.endDate,
                  ),
                  const SizedBox(height: 48),

                  MarkVisitedButton(
                    isVisited: trip.isVisited || trip.status == TripStatus.visited,
                    onPressed: () async {
                      final confirmed = await AppDialog.confirm(
                        context,
                        title: "Hoàn thành chuyến đi",
                        message: "Bạn đã hoàn thành chuyến đi này và muốn lưu vào lịch sử?",
                        confirmText: "Đồng ý",
                        cancelText: "Bỏ qua",
                      );

                      if (confirmed != true) return;

                      try {
                        await ref
                            .read(tripStatusProvider.notifier)
                            .markAsVisited(widget.travelId);

                        if (!context.mounted) return;
                        context.showSuccessSnack("Đã thêm vào lịch sử chuyến đi!");
                        context.pop(); // Quay lại màn hình trước
                      } catch (_) {
                        if (!context.mounted) return;
                        context.showErrorSnack(context.l10n.somethingWentWrong);
                      }
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      Positioned(
            right: 16,
            bottom: 16,
            child: Builder(
              builder: (context) {
                final cs = context.colors;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: "ask_ai",
                      onPressed: () {
                        context.pushNamed(
                          'tripChat',
                          pathParameters: {'travelId': trip.travelId},
                          extra: trip,
                        );
                      },
                      backgroundColor: cs.primary, // More prominent blue
                      elevation: 4,
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.smart_toy_rounded, // AI Robot icon
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TravelDbModel trip) {
    final cs = context.colors;
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: cs.primary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(
              trip.isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: trip.isFavorite ? Colors.redAccent : Colors.white,
            ),
          ),
          onPressed: () async {
            final newStatus = !trip.isFavorite;
            await ref.read(tripStatusProvider.notifier).toggleFavorite(trip.travelId, newStatus);
            ref.invalidate(tripByIdProvider(trip.travelId));
            if (context.mounted) {
              context.showSuccessSnack(
                newStatus ? context.l10n.added_to_favorites : context.l10n.removed_from_favorites,
              );
            }
          },
        ),
        if (trip.userId == ref.watch(userInfoProvider)?.uid) ...[
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined, size: 20, color: Colors.white),
            ),
            onPressed: () => context.pushNamed(RouteNames.planTrip, extra: trip),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, size: 20, color: Colors.white),
            ),
            onPressed: () => _showDeleteDialog(context, ref, trip),
          ),
        ]
        else
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, size: 20, color: Colors.white),
            ),
            onPressed: () => _showLeaveDialog(context, ref, trip),
          ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, size: 20, color: Colors.white),
          ),
          onPressed: () => _showShareCodeDialog(context, trip),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            TrekkoSlider(
              images: trip.images,
              destination: trip.destination,
              height: 350,
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    trip.destination,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSummaryTag(Icons.calendar_month, context.l10n.days_count(trip.totalDays)),
                        _buildSummaryTag(Icons.account_balance_wallet, trip.budget ?? "Chưa cập nhật"),
                        _buildSummaryTag(Icons.speed, trip.pace ?? context.l10n.pace_moderate),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTag(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTimelineSliver(BuildContext context, dynamic dayPlan, int index, String destination) {
    // Mặc định chỉ mở (expand) ngày đầu tiên
    final initiallyExpanded = index == 0;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        color: context.colors.surface,
        child: Theme(
          // Ẩn hai đường viền trên/dưới mặc định của ExpansionTile
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    context.l10n.day_label(dayPlan.day),
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy').format(dayPlan.date),
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                child: Column(
                  children: List.generate(
                    dayPlan.activities.length,
                    (actIndex) {
                      final activity = dayPlan.activities[actIndex];
                      final isLast = actIndex == dayPlan.activities.length - 1;
                      return _buildActivityTimelineRow(context, activity, isLast, destination);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTimelineRow(BuildContext context, dynamic activity, bool isLast, String destination) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Indicator
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                activity.time,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          
          // Timeline Stem
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 22),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.surface, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withAlpha(80),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: context.colors.primary.withAlpha(50),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Activity Card
          Expanded(
            child: TimelineActivityCard(activity: activity, destination: destination),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic trip,
  ) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: context.l10n.deleteTrip,
      message: context.l10n.deleteConfirmation,
      confirmText: context.l10n.delete,
      cancelText: context.l10n.cancel,
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      await _deleteTrip(context, ref, trip);
    }
  }

  Future<void> _deleteTrip(BuildContext context, WidgetRef ref, TravelDbModel trip) async {
    try {
      final userModel = ref.read(userInfoProvider);
      
      // Gửi thông báo đến thành viên khác trước khi xóa
      if (trip.memberIds.length > 1) {
        try {
          final notificationService = NotificationService();
          await notificationService.sendGroupNotification(
            memberIds: trip.memberIds,
            excludeUserId: userModel?.uid,
            title: "Chuyến đi đã bị hủy",
            body: "<b>${userModel?.name}</b> đã xóa chuyến đi đến <b>${trip.destination}</b>.",
            type: 'group_update',
            travelId: widget.travelId,
          );
        } catch (notifErr) {
          debugPrint("Silent error: Failed to send delete trip notification due to security rules: $notifErr");
        }
      }

      await ref.read(deleteTripProvider(widget.travelId).future);

      if (!context.mounted) return;
      context.showSuccessSnack(context.l10n.deleteSuccess);
      context.pop();
    } catch (_) {
      if (!context.mounted) return;
      context.showErrorSnack(context.l10n.failedDeleteTrip);
    }
  }

  Future<void> _showLeaveDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic trip,
  ) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: "Rời nhóm",
      message: "Bạn có chắc chắn muốn rời khỏi chuyến đi này không?",
      confirmText: "Rời nhóm",
      cancelText: context.l10n.cancel,
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      await _leaveTrip(context, ref, trip);
    }
  }

  Future<void> _leaveTrip(BuildContext context, WidgetRef ref, TravelDbModel trip) async {
    try {
      final userModel = ref.read(userInfoProvider);
      
      await ref.read(tripStatusProvider.notifier).leaveTrip(widget.travelId);

      // Gửi thông báo đến các thành viên còn lại
      try {
        final notificationService = NotificationService();
        await notificationService.sendGroupNotification(
          memberIds: trip.memberIds,
          excludeUserId: userModel?.uid,
          title: "Thành viên rời nhóm",
          body: "<b>${userModel?.name}</b> đã rời khỏi chuyến đi đến <b>${trip.destination}</b>.",
          type: 'group_update',
          travelId: widget.travelId,
        );
      } catch (notifErr) {
        debugPrint("Silent error: Failed to send leave group notification due to security rules: $notifErr");
      }

      if (!context.mounted) return;
      context.showSuccessSnack("Đã rời khỏi nhóm thành công");
      context.pop();
    } catch (e) {
      if (!context.mounted) return;
      context.showErrorSnack("Không thể rời nhóm lúc này. Vui lòng thử lại sau.");
    }
  }


  Widget _buildPackingListCard(BuildContext context, TravelDbModel trip) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PackingListScreen(
                tripId: trip.travelId,
                destination: trip.destination,
                days: trip.totalDays,
                weatherContext: "Thời tiết tại ${trip.destination} vào tháng ${trip.startDate.month}",
                gender: "Unisex",
                startDate: trip.startDate,
                endDate: trip.endDate,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary,
                context.colors.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.backpack,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chuẩn bị hành lý AI",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Gợi ý danh sách đồ dùng thông minh dựa trên chuyến đi của bạn.",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context, TravelDbModel trip) {
    // Hiển thị tối đa 4 thành viên đầu tiên, còn lại hiển thị số lượng +N
    final displayLimit = 4;
    final displayIds = trip.memberIds.take(displayLimit).toList();
    final remainingCount = trip.memberIds.length - displayLimit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thành viên nhóm",
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              if (trip.memberIds.length > 1)
                Text(
                  "${trip.memberIds.length} người tham gia",
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: Stack(
              children: [
                // Render danh sách avatar xếp chồng
                ...displayIds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final userId = entry.value;
                  final isOwner = userId == trip.userId;
                  
                  return Positioned(
                    left: index * 32.0,
                    child: _buildModernAvatar(context, userId, isOwner, trip),
                  );
                }),
                
                // Badge hiển thị số lượng còn lại
                if (remainingCount > 0)
                  Positioned(
                    left: displayLimit * 32.0,
                    child: _buildCountBadge(context, remainingCount),
                  ),
                
                // Nút mời thêm thành viên
                Positioned(
                  left: (remainingCount > 0 ? (displayLimit + 1) : displayIds.length) * 32.0,
                  child: _buildAddMemberAction(context, trip),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTrackerCard(BuildContext context, TravelDbModel trip) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.expenses,
            pathParameters: {'travelId': trip.travelId},
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade700,
                Colors.orange.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quản lý chi tiêu",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Theo dõi và chia sẻ chi phí chuyến đi với nhóm của bạn.",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultCard(BuildContext context, TravelDbModel trip) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.vault,
            pathParameters: {'travelId': trip.travelId},
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal.shade700,
                Colors.teal.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.folder_shared_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kho tài liệu",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Lưu trữ an toàn vé máy bay, hộ chiếu và các giấy tờ cần thiết.",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context, TravelDbModel trip) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.emergency,
            pathParameters: {'travelId': trip.travelId},
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade800,
                Colors.red.shade500,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sos_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Thông tin khẩn cấp",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Truy cập nhanh số cứu hộ, y tế và liên hệ người thân.",
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAvatar(BuildContext context, String userId, bool isOwner, TravelDbModel trip) {
    return _MemberAvatar(userId: userId, isOwner: isOwner, trip: trip);
  }

  Widget _buildCountBadge(BuildContext context, int count) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.surface, width: 3),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.shade200,
        child: Text(
          "+$count",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildAddMemberAction(BuildContext context, TravelDbModel trip) {
    return GestureDetector(
      onTap: () => _showShareCodeDialog(context, trip),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.surface, width: 3),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: context.colors.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person_add_alt_1_outlined,
            color: context.colors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showShareCodeDialog(BuildContext context, TravelDbModel trip) {
    if (trip.shareCode == null || trip.shareCode!.isEmpty) {
      context.showInfoSnack("Mã chia sẻ đang được khởi tạo, vui lòng thử lại sau.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            "Chia sẻ chuyến đi",
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Sử dụng mã dưới đây để mời bạn bè cùng tham gia:"),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                trip.shareCode!,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: context.colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: trip.shareCode!));
                  Navigator.pop(context);
                  context.showSuccessSnack("Đã copy mã mời: ${trip.shareCode}");
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text("Sao chép mã"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatar extends ConsumerWidget {
  final String userId;
  final bool isOwner;
  final TravelDbModel trip;

  const _MemberAvatar({
    required this.userId,
    required this.isOwner,
    required this.trip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng FutureProvider để tải 1 lần, tránh việc stream bị reset gây load liên tục
    final userDataAsync = ref.watch(anyUserFutureProvider(userId));

    return userDataAsync.when(
      data: (user) => _buildAvatarUI(context, user.profilePic, user.name ?? "U"),
      loading: () => _buildPlaceholder(context),
      error: (e, _) {
        // Nếu lỗi (ví dụ lỗi quyền), hiển thị avatar mặc định không spinner
        return _buildAvatarUI(context, isOwner ? trip.ownerPhoto : null, "U");
      },
    );
  }

  Widget _buildAvatarUI(BuildContext context, String? photoUrl, String name) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : "U";
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.surface, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFE4E6EB),
        backgroundImage: getAvatarProvider(photoUrl),
        child: getAvatarProvider(photoUrl) == null 
            ? const Icon(Icons.person, color: Color(0xFF8A8D91), size: 24)
            : null,
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.surface, width: 3),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.shade200,
        child: Icon(Icons.person, size: 20, color: Colors.grey.shade400),
      ),
    );
  }
}

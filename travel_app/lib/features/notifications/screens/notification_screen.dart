import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_snackbar.dart';
import 'package:travel_app/features/notifications/models/notification_model.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/provider/auth_providers.dart';
import '../../../core/common/loader.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  String _selectedFilter = 'all'; // 'all', 'latest', 'unread'
  final NotificationService _notificationService = NotificationService();

  String formatTimeAgo(DateTime time, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return context.l10n.just_now;
    if (difference.inMinutes < 60) return "${difference.inMinutes} ${context.l10n.just_now.toLowerCase()}"; // fallback or leave as is if no better l10n
    if (difference.inHours < 24) return "${difference.inHours} ${context.l10n.just_now.toLowerCase()}";
    if (difference.inDays == 1) return context.l10n.yesterday;
    if (difference.inDays < 7) return "${difference.inDays} ${context.l10n.just_now.toLowerCase()}";
    return DateFormat('dd/MM/yyyy').format(time);
  }

  Future<void> _markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllAsRead(userId);
      if (mounted) {
        context.showSuccessSnack(context.l10n.mark_all_read_success);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnack(context.l10n.update_error);
      }
    }
  }

  List<NotificationModel> _applyFilter(List<NotificationModel> notifications) {
    if (_selectedFilter == 'unread') {
      return notifications.where((n) => !n.isRead).toList();
    } else if (_selectedFilter == 'latest') {
      final now = DateTime.now();
      return notifications.where((n) => now.difference(n.timestamp).inHours < 24).toList();
    }
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userInfoProvider);
    if (user == null) {
      return Scaffold(body: Center(child: Text(context.l10n.please_login)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        title: Text(
          context.l10n.notifications_title,
          style: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: Colors.blue),
            tooltip: context.l10n.mark_all_read_tooltip,
            onPressed: () => _markAllAsRead(user.uid),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', context.l10n.filter_all),
                  const SizedBox(width: 8),
                  _buildFilterChip('latest', context.l10n.filter_latest),
                  const SizedBox(width: 8),
                  _buildFilterChip('unread', context.l10n.filter_unread),
                ],
              ),
            ),
          ),
          
          // Notifications List
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _notificationService.getNotificationsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Loader());
                }

                final allNotifications = snapshot.data ?? [];
                final filteredNotifications = _applyFilter(allNotifications);

                if (filteredNotifications.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  itemCount: filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final item = filteredNotifications[index];
                    return _FacebookNotificationItem(
                      notification: item,
                      timeAgo: formatTimeAgo(item.timestamp, context),
                      onTap: () async {
                        if (!item.isRead) {
                          await _notificationService.markAsRead(user.uid, item.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = filter);
      },
      selectedColor: context.colors.primary,
      backgroundColor: Colors.grey[200],
      labelStyle: GoogleFonts.beVietnamPro(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      pressElevation: 0,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            context.l10n.no_notifications_found,
            style: GoogleFonts.beVietnamPro(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _FacebookNotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final String timeAgo;
  final VoidCallback onTap;

  const _FacebookNotificationItem({
    required this.notification,
    required this.timeAgo,
    required this.onTap,
  });

  List<TextSpan> _parseContent(String text, TextStyle baseStyle) {
    List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r"<b>(.*?)</b>");
    int lastIndex = 0;

    for (final match in regExp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }

  String _getTranslatedBody(BuildContext context, String body, String type) {
    if (type == 'upcoming_trip' || type == 'trip_reminder') {
      final match = RegExp(r"đến (.*?) sắp").firstMatch(body);
      final dest = match != null ? match.group(1) ?? "" : "";
      return context.l10n.notifUpcomingTripBody(dest);
    } else if (type == 'group_update') {
      final matches = RegExp(r"<b>(.*?)</b>").allMatches(body).toList();
      final member = matches.isNotEmpty ? matches[0].group(1) ?? "" : "";
      final dest = matches.length > 1 ? matches[1].group(1) ?? "" : "";
      return context.l10n.notifNewMemberBody(member, dest);
    } else if (type == 'event') {
      if (body.contains("pháo hoa")) return context.l10n.notifFestivalDanangBody;
      if (body.contains("Hội An")) return context.l10n.notifFestivalHoiAnBody;
      if (body.contains("ngàn hoa")) return context.l10n.notifFestivalDaLatBody;
      if (body.contains("Nha Trang")) return context.l10n.notifFestivalNhaTrangBody;
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    
    IconData iconData;
    Color iconBgColor;

    switch (notification.type) {
      case 'event':
        iconData = Icons.festival_rounded;
        iconBgColor = Colors.orange;
        break;
      case 'holiday':
        iconData = Icons.celebration_rounded;
        iconBgColor = Colors.redAccent;
        break;
      case 'trip_reminder':
        iconData = Icons.flight_takeoff_rounded;
        iconBgColor = Colors.green;
        break;
      case 'group_update':
        iconData = Icons.person_rounded;
        iconBgColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications_rounded;
        iconBgColor = cs.primary;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: notification.isRead ? Colors.white : const Color(0xFFE7F3FF),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading CircleAvatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: iconBgColor.withValues(alpha: 0.1),
                  child: Icon(iconData, color: iconBgColor, size: 28),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(iconData, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Tránh chiếm quá nhiều không gian dọc
                children: [
                  RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                    text: TextSpan(
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      children: _parseContent(_getTranslatedBody(context, notification.body, notification.type), GoogleFonts.beVietnamPro()),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    timeAgo,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      color: notification.isRead ? Colors.black45 : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing Blue Dot
            if (!notification.isRead)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 20, left: 8),
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

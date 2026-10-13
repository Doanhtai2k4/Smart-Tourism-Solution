import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/common/app_error_state.dart';
import '../../../core/common/empty_state.dart';
import '../../../core/common/loader.dart';
import '../../../core/extensions/context_snackbar.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/services/trip_service.dart';
import '../../../shared/widgets/trip_card.dart';
import '../../auth/provider/auth_providers.dart';
import '../provider/user_trips_provider.dart';

class GroupTripsPage extends ConsumerStatefulWidget {
  const GroupTripsPage({super.key});

  @override
  ConsumerState<GroupTripsPage> createState() => _GroupTripsPageState();
}

class _GroupTripsPageState extends ConsumerState<GroupTripsPage> {
  final _codeController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      context.showErrorSnack("Vui lòng nhập đủ 6 ký tự");
      return;
    }

    setState(() => _isJoining = true);

    try {
      final userModel = ref.read(userInfoProvider);
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null || userModel == null) throw Exception("Vui lòng đăng nhập lại");

      final trip = await ref.read(tripServiceProvider).joinTrip(code, user.uid);

      if (mounted) {
        context.showSuccessSnack("Chào mừng bạn đã tham gia nhóm!");
        _codeController.clear();
        setState(() => _isJoining = false);
        
        // Điều hướng vào màn hình chi tiết
        context.pushNamed(
          'trip',
          pathParameters: {'travelId': trip.travelId},
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        context.showErrorSnack(e.toString().replaceAll("Exception: ", ""));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final joinedTripsAsync = ref.watch(joinedTripsProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text("Chuyến đi nhóm", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Phần nhập mã tham gia
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.colors.primary, context.colors.primary.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tham gia nhóm mới",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Nhập mã mời 6 ký tự để cùng lên kế hoạch với bạn bè.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            decoration: InputDecoration(
                              hintText: "MÃ MỜI",
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 6,
                            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isJoining ? null : _handleJoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: context.colors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isJoining
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text("THAM GIA", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tiêu đề danh sách
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Nhóm đã tham gia",
                    style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Danh sách chuyến đi đã tham gia
          joinedTripsAsync.when(
            loading: () => const SliverToBoxAdapter(child: Center(child: Loader())),
            error: (e, _) => SliverToBoxAdapter(child: AppErrorState(message: e.toString())),
            data: (trips) {
              if (trips.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: "Chưa tham gia nhóm nào",
                    subtitle: "Hãy nhập mã mời ở trên để bắt đầu lập kế hoạch cùng bạn bè.",
                    icon: Icons.group_off_outlined,
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final trip = trips[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Stack(
                      children: [
                        TripCard(
                          trip: trip,
                          onTap: () => context.pushNamed(
                            'trip',
                            pathParameters: {'travelId': trip.travelId},
                          ),
                        ),
                        // Badge hiển thị người mời
                        if (trip.ownerName != null && trip.ownerName!.isNotEmpty)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (trip.ownerPhoto != null && trip.ownerPhoto!.isNotEmpty)
                                    CircleAvatar(
                                      radius: 8,
                                      backgroundImage: NetworkImage(trip.ownerPhoto!),
                                    )
                                  else
                                    const Icon(Icons.person, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Từ ${trip.ownerName}",
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }, childCount: trips.length),
              );
            },
          ),
        ],
      ),
    );
  }
}

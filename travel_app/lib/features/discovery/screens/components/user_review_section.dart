import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/shared/models/destination_model.dart';
import '../../providers/review_controller.dart';
import 'package:travel_app/core/services/tracking_service.dart';


class UserReviewSection extends ConsumerStatefulWidget {
  final DestinationModel destination;

  const UserReviewSection({super.key, required this.destination});

  @override
  ConsumerState<UserReviewSection> createState() => _UserReviewSectionState();
}

class _UserReviewSectionState extends ConsumerState<UserReviewSection> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final reviewAsync = ref.watch(reviewControllerProvider(widget.destination.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Reviews List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.community_reviews,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {}, // TODO: See all reviews
                child: Text(
                  context.l10n.see_all,
                  style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildReviewList(cs),
        
        const SizedBox(height: 32),

        // 2. Submission Form (MANDATORY DISPLAY)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.outlineVariant.withAlpha(128)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.your_rating,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.share_experience_hint,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              reviewAsync.when(
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )),
                error: (err, stack) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Lỗi tải nhận xét cũ: $err',
                      style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.orange),
                    ),
                  );
                },
                data: (state) {
                  // Sincronize controller text with state if it's the first load or an update from server
                  if (_reviewController.text != state.comment && !state.isSubmitting && state.comment.isNotEmpty) {
                    _reviewController.text = state.comment;
                  }
                  
                  final currentRating = state.rating;
                  final isSubmitting = state.isSubmitting;

                  return Column(
                    children: [
                      // Interactive Star Rating Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          final isSelected = starIndex <= currentRating;
                          return IconButton(
                            onPressed: isSubmitting 
                              ? null 
                              : () => ref.read(reviewControllerProvider(widget.destination.id).notifier).updateRating(starIndex.toDouble()),
                            iconSize: 32,
                            icon: Icon(
                              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: isSelected ? Colors.amber : cs.outline,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            constraints: const BoxConstraints(),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Review Text Field
                      TextField(
                        controller: _reviewController,
                        maxLines: 3,
                        enabled: !isSubmitting,
                        onChanged: (val) => ref.read(reviewControllerProvider(widget.destination.id).notifier).updateComment(val),
                        style: GoogleFonts.beVietnamPro(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: context.l10n.enter_review_hint,
                          hintStyle: GoogleFonts.beVietnamPro(fontSize: 14, color: cs.outline),
                          filled: true,
                          fillColor: cs.surface,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: cs.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: cs.outlineVariant.withAlpha(128)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: cs.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: (currentRating == 0 || isSubmitting) 
                            ? null 
                            : () {
                              ref.read(reviewControllerProvider(widget.destination.id).notifier).submitReview(
                                onSuccess: (msg) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg), backgroundColor: Colors.green),
                                  );
                                  // Track review for ML
                                  ref.read(trackingServiceProvider).trackReview(widget.destination.id, currentRating);
                                  FocusScope.of(context).unfocus();
                                },
                                onError: (err) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(err), backgroundColor: Colors.red),
                                  );
                                },
                              );
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: isSubmitting 
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                state.isUpdate ? context.l10n.update_review : context.l10n.send_review,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewList(ColorScheme cs) {
    final reviewsAsync = ref.watch(destinationReviewsProvider(widget.destination.id));

    return reviewsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const Icon(Icons.lock_person_outlined, color: Colors.orange, size: 28),
            const SizedBox(height: 8),
            Text(
              err.toString().contains('permission-denied')
                ? 'Lỗi phân quyền Firestore: Bạn chưa có quyền đọc nhận xét. Vui lòng kiểm tra Security Rules trên Firebase Console.'
                : 'Lỗi tải nhận xét: $err',
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(color: Colors.orange, fontSize: 13),
            ),
          ],
        ),
      ),
      data: (reviews) {
        if (reviews.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              context.l10n.no_reviews_yet,
              style: GoogleFonts.beVietnamPro(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: reviews.length > 5 ? 5 : reviews.length, // Show top 5
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final review = reviews[index];
            final DateTime? updatedAt = (review['updatedAt'] as dynamic)?.toDate();
            final dateStr = updatedAt != null 
                ? DateFormat('dd/MM/yyyy').format(updatedAt)
                : context.l10n.just_now;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: review['userPhoto'] != null && (review['userPhoto'] as String).isNotEmpty
                      ? NetworkImage(review['userPhoto'] as String)
                      : null,
                  child: review['userPhoto'] == null || (review['userPhoto'] as String).isEmpty
                      ? Icon(Icons.person, size: 20, color: cs.primary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review['userName'] as String? ?? context.l10n.anonymous_user,
                            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            dateStr,
                            style: GoogleFonts.beVietnamPro(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          Icons.star_rounded, 
                          size: 14, 
                          color: i < (review['rating'] as num? ?? 0).toInt() ? Colors.amber : cs.outlineVariant,
                        )),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        review['comment'] as String? ?? '',
                        style: GoogleFonts.beVietnamPro(fontSize: 13, color: cs.onSurfaceVariant, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

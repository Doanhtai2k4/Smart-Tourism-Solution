import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/document_model.dart';
import '../provider/vault_provider.dart';
import 'widgets/add_document_bottom_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class DocumentListScreen extends ConsumerWidget {
  final String tripId;
  const DocumentListScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(tripDocumentsProvider(tripId));
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          "Kho tài liệu",
          style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: docsAsync.when(
        data: (docs) => docs.isEmpty
            ? _buildEmptyState(context)
            : GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) => _buildDocumentCard(context, docs[index], ref)
                    .animate(delay: (index * 50).ms)
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Lỗi: $err")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDocumentSheet(context, tripId),
        label: const Text("Thêm tài liệu"),
        icon: const Icon(Icons.add_a_photo_rounded),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: context.colors.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            "Chưa có tài liệu nào",
            style: GoogleFonts.beVietnamPro(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Lưu vé, hộ chiếu và các giấy tờ quan trọng tại đây."),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, TravelDocumentModel doc, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _openDocument(doc.fileUrl),
      onLongPress: () => _showDeleteDialog(context, ref, doc),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: doc.fileUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: context.colors.primary.withValues(alpha: 0.05),
                      child: Icon(Icons.insert_drive_file_rounded, size: 40, color: context.colors.primary),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(doc.type),
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(doc.uploadedAt),
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.ticket: return Icons.airplane_ticket_rounded;
      case DocumentType.passport: return Icons.badge_rounded;
      case DocumentType.hotel: return Icons.hotel_rounded;
      case DocumentType.visa: return Icons.verified_rounded;
      case DocumentType.insurance: return Icons.security_rounded;
      case DocumentType.other: return Icons.description_rounded;
    }
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showAddDocumentSheet(BuildContext context, String tripId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AddDocumentBottomSheet(tripId: tripId),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, TravelDocumentModel doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa tài liệu?"),
        content: Text("Bạn có chắc chắn muốn xóa tài liệu '${doc.title}' không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              await ref.read(vaultActionsProvider).deleteDocument(doc);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

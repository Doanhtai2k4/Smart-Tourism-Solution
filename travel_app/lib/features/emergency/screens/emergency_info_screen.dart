import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_model.dart';
import '../provider/emergency_provider.dart';
import 'widgets/emergency_forms.dart';

class EmergencyInfoScreen extends ConsumerWidget {
  final String tripId;
  const EmergencyInfoScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(tripEmergencyProvider(tripId));
    final colors = context.colors;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Text(
            "Thông tin khẩn cấp",
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelStyle: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Địa phương"),
              Tab(text: "Y tế"),
              Tab(text: "Liên hệ"),
            ],
          ),
        ),
        body: infoAsync.when(
          data: (info) {
            if (info == null) {
              // Yêu cầu khởi tạo dữ liệu ở background sau khi frame hiện tại hoàn tất
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(emergencyActionsProvider).setInitialLocalNumbers(tripId);
              });
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _buildLocalSection(context, ref, info),
                _buildMedicalSection(context, ref, info),
                _buildContactsSection(context, ref, info),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Lỗi: $err")),
        ),
      ),
    );
  }

  Widget _buildLocalSection(BuildContext context, WidgetRef ref, EmergencyModel info) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildEmergencyCard(
          context,
          ref,
          title: "Số điện thoại cứu hộ",
          contacts: info.localNumbers,
          isUrgent: true,
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          context,
          title: "Thông tin Đại sứ quán",
          content: info.embassyInfo ?? "Chưa có thông tin. Hãy lưu lại địa chỉ Đại sứ quán Việt Nam tại điểm đến.",
          icon: Icons.account_balance_rounded,
          onEdit: () => _showEditEmbassyDialog(context, ref, info),
        ),
      ],
    );
  }

  Widget _buildMedicalSection(BuildContext context, WidgetRef ref, EmergencyModel info) {
    final medical = info.medicalInfo;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildMedicalRow(context, "Nhóm máu", medical?.bloodType ?? "Chưa rõ", Icons.bloodtype_rounded),
        _buildMedicalRow(context, "Dị ứng", medical?.allergies ?? "Không có", Icons.warning_amber_rounded),
        _buildMedicalRow(context, "Tình trạng bệnh lý", medical?.chronicConditions ?? "Không có", Icons.medical_services_rounded),
        _buildMedicalRow(context, "Ghi chú thêm", medical?.notes ?? "Không có", Icons.note_alt_rounded),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () => _showEditMedicalSheet(context, info),
          icon: const Icon(Icons.edit_rounded),
          label: const Text("Cập nhật thông tin y tế"),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
      ],
    );
  }

  Widget _buildContactsSection(BuildContext context, WidgetRef ref, EmergencyModel info) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildEmergencyCard(
          context,
          ref,
          title: "Liên hệ người thân",
          contacts: info.personalContacts,
          isUrgent: false,
          info: info,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _showAddContactSheet(context, info),
          icon: const Icon(Icons.person_add_rounded),
          label: const Text("Thêm liên hệ khẩn cấp"),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyCard(BuildContext context, WidgetRef ref, {required String title, required List<EmergencyContact> contacts, required bool isUrgent, EmergencyModel? info}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.shade50 : context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUrgent ? Colors.red.shade200 : context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: isUrgent ? Colors.red.shade700 : null)),
          const SizedBox(height: 16),
          if (contacts.isEmpty)
             const Text("Chưa có liên hệ nào được lưu.")
          else
            ...contacts.map((c) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(c.relation != null && c.relation!.isNotEmpty ? "${c.relation} - ${c.phone}" : c.phone),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUrgent && info != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      onPressed: () => _deleteContact(context, ref, info, c),
                      style: IconButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.1)),
                    ),
                  if (!isUrgent && info != null) const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.call_rounded, color: Colors.green),
                    onPressed: () => _makeCall(c.phone),
                    style: IconButton.styleFrom(backgroundColor: Colors.green.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  void _deleteContact(BuildContext context, WidgetRef ref, EmergencyModel info, EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa liên hệ"),
        content: Text("Bạn có chắc chắn muốn xóa liên hệ '${contact.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final updatedContacts = List<EmergencyContact>.from(info.personalContacts)..remove(contact);
              final updatedInfo = EmergencyModel(
                tripId: info.tripId,
                localNumbers: info.localNumbers,
                personalContacts: updatedContacts,
                medicalInfo: info.medicalInfo,
                embassyInfo: info.embassyInfo,
              );
              ref.read(emergencyActionsProvider).updateInfo(updatedInfo);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.text.bodySmall),
                Text(value, style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String content, required IconData icon, VoidCallback? onEdit}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.colors.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
              if (onEdit != null)
                IconButton(
                  icon: Icon(Icons.edit_rounded, color: context.colors.primary, size: 20),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content),
        ],
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showEditMedicalSheet(BuildContext context, EmergencyModel info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => MedicalInfoForm(info: info),
    );
  }

  void _showAddContactSheet(BuildContext context, EmergencyModel info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => EmergencyContactForm(info: info),
    );
  }

  void _showEditEmbassyDialog(BuildContext context, WidgetRef ref, EmergencyModel info) {
    final ctrl = TextEditingController(text: info.embassyInfo);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đại sứ quán Việt Nam"),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Nhập địa chỉ, số điện thoại...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              final updatedInfo = EmergencyModel(
                tripId: info.tripId,
                localNumbers: info.localNumbers,
                personalContacts: info.personalContacts,
                medicalInfo: info.medicalInfo,
                embassyInfo: ctrl.text.trim().isEmpty ? null : ctrl.text.trim(),
              );
              ref.read(emergencyActionsProvider).updateInfo(updatedInfo);
              Navigator.pop(ctx);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }
}

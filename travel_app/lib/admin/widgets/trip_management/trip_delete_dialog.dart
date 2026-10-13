import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class TripDeleteDialog extends StatefulWidget {
  final String tripId;
  final String destination;

  const TripDeleteDialog({super.key, required this.tripId, required this.destination});

  @override
  State<TripDeleteDialog> createState() => _TripDeleteDialogState();
}

class _TripDeleteDialogState extends State<TripDeleteDialog> {
  final AdminService _adminService = AdminService();
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 12),
          Text('Xác nhận xóa'),
        ],
      ),
      content: Text('Bạn có chắc chắn muốn xóa chuyến đi đến "${widget.destination}" không?\n\nChuyến đi sẽ được đưa vào thùng rác (Soft Delete) và có thể khôi phục từ database nếu cần.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _isDeleting ? null : _handleDelete,
          child: _isDeleting 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    try {
      await _adminService.softDeleteTrip(widget.tripId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đưa chuyến đi vào thùng rác')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}

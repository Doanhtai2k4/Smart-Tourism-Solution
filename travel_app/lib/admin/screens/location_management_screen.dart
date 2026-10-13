import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/admin_service.dart';
import '../../shared/models/destination_model.dart';
import '../widgets/location_management/location_detail_admin_dialog.dart';
import '../widgets/location_management/location_form_dialog.dart';

class LocationManagementScreen extends StatefulWidget {
  const LocationManagementScreen({super.key});

  @override
  State<LocationManagementScreen> createState() => _LocationManagementScreenState();
}

class _LocationManagementScreenState extends State<LocationManagementScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sorting State
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Quản lý địa điểm',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showLocationDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Thêm địa điểm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm địa điểm, tỉnh thành...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8), size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                  ],
                ),
              ),
            ).animate().fade(duration: 200.ms).slideY(begin: -0.05),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getLocationsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final allDocs = snapshot.data!.docs;
                final List<DestinationModel> locations = [];

                for (var doc in allDocs) {
                  try {
                    final data = doc.data() as Map<String, dynamic>;
                    final model = DestinationModel.fromFirestore(doc.id, data);
                    
                    if (_searchQuery.isEmpty || 
                        model.name.toLowerCase().contains(_searchQuery) || 
                        (model.province?.toLowerCase().contains(_searchQuery) ?? false)) {
                      locations.add(model);
                    }
                  } catch (e) {
                    debugPrint('Lỗi parse địa điểm ${doc.id}: $e');
                  }
                }

                // Áp dụng Sorting Local trên list model
                if (_sortColumnIndex != null) {
                  locations.sort((a, b) {
                    String aValue = '';
                    String bValue = '';
                    
                    if (_sortColumnIndex == 1) { // Tên địa điểm
                      aValue = a.name.toLowerCase();
                      bValue = b.name.toLowerCase();
                    } else if (_sortColumnIndex == 2) { // Phân loại
                      aValue = (a.category ?? '').toLowerCase();
                      bValue = (b.category ?? '').toLowerCase();
                    }

                    return _sortAscending 
                        ? aValue.compareTo(bValue)
                        : bValue.compareTo(aValue);
                  });
                }

                if (locations.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy địa điểm nào',
                      style: TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          cardTheme: const CardThemeData(elevation: 0, color: Colors.transparent),
                          dividerTheme: const DividerThemeData(color: Color(0xFFF1F5F9)),
                        ),
                        child: PaginatedDataTable(
                          header: const Text(
                            'Danh sách địa điểm hệ thống',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          sortColumnIndex: _sortColumnIndex,
                          sortAscending: _sortAscending,
                          columns: [
                            const DataColumn(label: Text('Ảnh', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(
                              label: const Text('Tên địa điểm', style: TextStyle(fontWeight: FontWeight.bold)),
                              onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                            ),
                            DataColumn(
                              label: const Text('Phân loại', style: TextStyle(fontWeight: FontWeight.bold)),
                              onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                            ),
                            const DataColumn(label: Text('Tọa độ', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          source: LocationDataSource(
                            locations: locations,
                            context: context,
                            onView: _viewLocationDetail,
                            onReview: _showReviewsModeration,
                            onEdit: (id, location) => _showLocationDialog(id: id, initialData: location),
                            onDelete: _confirmDelete,
                          ),
                          rowsPerPage: 10,
                          showFirstLastButtons: true,
                        ),
                      ),
                    ),
                  ),
                ).animate().fade(duration: 300.ms, delay: 100.ms).slideY(begin: 0.05);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _viewLocationDetail(DestinationModel location) {
    showDialog(
      context: context,
      builder: (context) => LocationDetailAdminDialog(location: location),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa địa điểm', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn xóa địa điểm này không? Dữ liệu sẽ bị gỡ bỏ khỏi hệ thống.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              _adminService.deleteLocation(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã xóa địa điểm thành công'),
                backgroundColor: Color(0xFFEF4444),
              ));
            },
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _showLocationDialog({String? id, DestinationModel? initialData}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationFormDialog(id: id, initialData: initialData),
    );
  }

  void _showReviewsModeration(String locationId, String locationName) async {
    final reviews = await _adminService.getLocationReviews(locationId);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kiểm duyệt đánh giá',
                            style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            locationName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Chưa có đánh giá nào cho địa điểm này',
                        style: TextStyle(color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: reviews.length,
                      separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        final rating = (review['rating'] as num?)?.toDouble() ?? 5.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating.toString(),
                                      style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review['userName'] ?? 'Người dùng ẩn danh',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      review['comment'] ?? review['content'] ?? 'Không có nội dung',
                                      style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                onPressed: () => _confirmDeleteReview(locationId, review['id'], () {
                                  setDialogState(() {
                                    reviews.removeAt(index);
                                  });
                                }),
                                tooltip: 'Gỡ bỏ đánh giá',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteReview(String locId, String revId, VoidCallback onSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa đánh giá', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn gỡ bỏ đánh giá này? Đánh giá bị gỡ sẽ không hiển thị trên ứng dụng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              _adminService.deleteReview(locId, revId);
              Navigator.pop(context);
              onSuccess();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã gỡ bỏ đánh giá thành công'),
                backgroundColor: Color(0xFFEF4444),
              ));
            },
            child: const Text('Đồng ý xóa'),
          ),
        ],
      ),
    );
  }
}

class LocationDataSource extends DataTableSource {
  final List<DestinationModel> locations;
  final BuildContext context;
  final Function(DestinationModel) onView;
  final Function(String, String) onReview;
  final Function(String, DestinationModel) onEdit;
  final Function(String) onDelete;

  LocationDataSource({
    required this.locations,
    required this.context,
    required this.onView,
    required this.onReview,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= locations.length) return null;
    final location = locations[index];
    final imageUrl = location.images.isNotEmpty ? location.images.first : '';

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported_rounded, size: 20, color: Color(0xFF94A3B8)),
                    )
                  : const Icon(Icons.image_not_supported_rounded, size: 20, color: Color(0xFF94A3B8)),
            ),
          ),
        ),
        DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(location.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(location.province ?? 'Việt Nam', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        )),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              location.category ?? 'Địa điểm',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
          ),
        ),
        DataCell(Text(
          '${location.latitude?.toStringAsFixed(3) ?? 0}, ${location.longitude?.toStringAsFixed(3) ?? 0}',
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF64748B)),
        )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility_outlined, color: Color(0xFF10B981), size: 20),
              onPressed: () => onView(location),
              tooltip: 'Xem chi tiết',
            ),
            IconButton(
              icon: const Icon(Icons.rate_review_outlined, color: Color(0xFFF59E0B), size: 20),
              onPressed: () => onReview(location.id, location.name),
              tooltip: 'Duyệt đánh giá',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF3B82F6), size: 20),
              onPressed: () => onEdit(location.id, location),
              tooltip: 'Chỉnh sửa',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
              onPressed: () => onDelete(location.id),
              tooltip: 'Xóa địa điểm',
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => locations.length;

  @override
  int get selectedRowCount => 0;
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/models/travel_db_model.dart';
import '../services/admin_service.dart';
import '../widgets/trip_management/trip_delete_dialog.dart';
import '../widgets/trip_detail/admin_trip_detail_view.dart';

class TripManagementScreen extends StatefulWidget {
  const TripManagementScreen({super.key});

  @override
  State<TripManagementScreen> createState() => _TripManagementScreenState();
}

class _TripManagementScreenState extends State<TripManagementScreen> {
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
          'Quản lý chuyến đi',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
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
                          hintText: 'Tìm kiếm theo tên chuyến đi hoặc điểm đến...',
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
          
          // Danh sách Chuyến đi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getAllTripsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                // Parse dữ liệu thành List Model một lần duy nhất
                final List<TravelDbModel> trips = [];
                for (var doc in snapshot.data!.docs) {
                  try {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['isDeleted'] == true) continue;

                    final trip = TravelDbModel.fromJson({
                      ...data,
                      'travelId': data['travelId'] ?? doc.id,
                    });
                    
                    // Lọc theo tìm kiếm
                    if (_searchQuery.isEmpty || 
                        trip.destination.toLowerCase().contains(_searchQuery) ||
                        (trip.ownerName?.toLowerCase().contains(_searchQuery) ?? false)) {
                      trips.add(trip);
                    }
                  } catch (e) {
                    debugPrint('Lỗi parse trip ID ${doc.id}: $e');
                  }
                }

                // Áp dụng Sắp xếp (Sorting) Local
                if (_sortColumnIndex != null) {
                  trips.sort((a, b) {
                    Comparable aValue;
                    Comparable bValue;
                    
                    switch (_sortColumnIndex) {
                      case 0: aValue = a.destination.toLowerCase(); bValue = b.destination.toLowerCase(); break;
                      case 1: aValue = (a.ownerName ?? '').toLowerCase(); bValue = (b.ownerName ?? '').toLowerCase(); break;
                      case 4: aValue = a.status.name.toLowerCase(); bValue = b.status.name.toLowerCase(); break;
                      default: return 0;
                    }
                    
                    return _sortAscending 
                        ? aValue.compareTo(bValue)
                        : bValue.compareTo(aValue);
                  });
                }

                if (trips.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy chuyến đi nào',
                      style: TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
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
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        cardTheme: const CardThemeData(elevation: 0, color: Colors.transparent),
                        dividerTheme: const DividerThemeData(color: Color(0xFFF1F5F9)),
                      ),
                      child: PaginatedDataTable(
                        header: const Text(
                          'Danh sách chuyến đi hệ thống',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        columns: [
                          DataColumn(
                            label: const Text('Điểm đến', style: TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (columnIndex, ascending) => _sort<String>((t) => t.destination, columnIndex, ascending),
                          ),
                          DataColumn(
                            label: const Text('Người tạo', style: TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (columnIndex, ascending) => _sort<String>((t) => t.ownerName ?? '', columnIndex, ascending),
                          ),
                          const DataColumn(label: Text('Thời gian', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('Ngân sách', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                            label: const Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (columnIndex, ascending) => _sort<String>((t) => t.status.name, columnIndex, ascending),
                          ),
                          const DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        source: _TripDataSource(
                          trips: trips, 
                          context: context, 
                          adminService: _adminService,
                          onView: _viewTripDetail,
                          onDelete: _deleteTrip,
                        ),
                        rowsPerPage: 10,
                        showFirstLastButtons: true,
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

  // Hàm sắp xếp dùng chung
  void _sort<T>(Comparable<T> Function(TravelDbModel t) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _viewTripDetail(TravelDbModel trip) {
    showDialog(
      context: context,
      builder: (context) => AdminTripDetailView(tripId: trip.travelId),
    );
  }

  void _deleteTrip(TravelDbModel trip) {
    showDialog(
      context: context,
      builder: (context) => TripDeleteDialog(
        tripId: trip.travelId,
        destination: trip.destination,
      ),
    );
  }
}

class _TripDataSource extends DataTableSource {
  final List<TravelDbModel> trips;
  final BuildContext context;
  final AdminService adminService;
  final Function(TravelDbModel) onView;
  final Function(TravelDbModel) onDelete;

  _TripDataSource({
    required this.trips,
    required this.context,
    required this.adminService,
    required this.onView,
    required this.onDelete,
  });

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'planned': return 'ĐÃ LÊN LỊCH';
      case 'ongoing': return 'ĐANG DIỄN RA';
      case 'completed': return 'HOÀN THÀNH';
      case 'cancelled': return 'ĐÃ HỦY';
      default: return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned': return const Color(0xFF3B82F6);
      case 'ongoing': return const Color(0xFFF59E0B);
      case 'completed': return const Color(0xFF10B981);
      case 'cancelled': return const Color(0xFFEF4444);
      default: return const Color(0xFF64748B);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned': return const Color(0xFFEFF6FF);
      case 'ongoing': return const Color(0xFFFFF7ED);
      case 'completed': return const Color(0xFFECFDF5);
      case 'cancelled': return const Color(0xFFFEF2F2);
      default: return const Color(0xFFF1F5F9);
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= trips.length) return null;
    final trip = trips[index];

    return DataRow(cells: [
      DataCell(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              trip.destination, 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            Text(
              '${trip.totalDays} ngày - ${trip.totalPeople} người', 
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
      DataCell(Text(
        trip.ownerName ?? 'Chưa cập nhật',
        style: const TextStyle(color: Color(0xFF475569)),
      )),
      DataCell(Text(
        '${trip.startDate.day}/${trip.startDate.month} - ${trip.endDate.day}/${trip.endDate.month}',
        style: const TextStyle(color: Color(0xFF475569)),
      )),
      DataCell(Text(
        (trip.budget?.isEmpty ?? true) ? 'Chưa nhập' : trip.budget!,
        style: const TextStyle(color: Color(0xFF64748B)),
      )),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusBgColor(trip.status.name),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getStatusColor(trip.status.name),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _getStatusText(trip.status.name),
                style: TextStyle(
                  color: _getStatusColor(trip.status.name), 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: Color(0xFF3B82F6), size: 20),
            onPressed: () => onView(trip),
            tooltip: 'Xem chi tiết chuyến đi',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
            onPressed: () => onDelete(trip),
            tooltip: 'Xóa chuyến đi (Xóa mềm)',
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => trips.length;

  @override
  int get selectedRowCount => 0;
}

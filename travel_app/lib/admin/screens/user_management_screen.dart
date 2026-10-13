import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/admin_service.dart';
import '../widgets/trip_detail/admin_trip_detail_view.dart';
import '../../core/utils.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
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
          'Quản lý người dùng',
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
                          hintText: 'Tìm kiếm người dùng theo tên, email...',
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
              stream: _adminService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Đã có lỗi xảy ra'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final allDocs = snapshot.data!.docs;
                final List<Map<String, dynamic>> users = [];

                for (var doc in allDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  
                  if (_searchQuery.isEmpty || name.contains(_searchQuery) || email.contains(_searchQuery)) {
                    users.add({
                      ...data,
                      'id': doc.id,
                    });
                  }
                }

                // Áp dụng Sorting Local
                if (_sortColumnIndex != null) {
                  users.sort((a, b) {
                    String aValue = '';
                    String bValue = '';
                    
                    if (_sortColumnIndex == 1) { // Tên hiển thị
                      aValue = (a['name'] ?? '').toLowerCase();
                      bValue = (b['name'] ?? '').toLowerCase();
                    } else if (_sortColumnIndex == 2) { // Email
                      aValue = (a['email'] ?? '').toLowerCase();
                      bValue = (b['email'] ?? '').toLowerCase();
                    }

                    return _sortAscending 
                        ? aValue.compareTo(bValue)
                        : bValue.compareTo(aValue);
                  });
                }

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy người dùng nào',
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
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        cardTheme: const CardThemeData(elevation: 0, color: Colors.transparent),
                        dividerTheme: const DividerThemeData(color: Color(0xFFF1F5F9)),
                      ),
                      child: PaginatedDataTable(
                        header: const Text(
                          'Danh sách tài khoản',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        columns: [
                          const DataColumn(label: Text('Avatar', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                            label: const Text('Tên hiển thị', style: TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                          ),
                          DataColumn(
                            label: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
                          ),
                          const DataColumn(label: Text('Ngày tham gia', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                          const DataColumn(label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        source: UserDataSource(
                          users: users, 
                          context: context, 
                          onLock: _onLockUser,
                          onShowHistory: _showUserHistory,
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

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _onLockUser(String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận khóa tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn khóa tài khoản này không? Người dùng sẽ không thể truy cập lại.'),
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
              _adminService.deleteUser(uid);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã cập nhật trạng thái khóa tài khoản'),
                backgroundColor: Color(0xFFEF4444),
              ));
            },
            child: const Text('Đồng ý khóa'),
          ),
        ],
      ),
    );
  }

  void _showUserHistory(String uid, String name) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final createdTrips = await _adminService.getUserCreatedTrips(uid);
    final joinedTrips = await _adminService.getUserJoinedTrips(uid);

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lịch sử hoạt động',
                          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
              DefaultTabController(
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        labelColor: const Color(0xFF3B82F6),
                        unselectedLabelColor: const Color(0xFF64748B),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        tabs: const [
                          Tab(text: 'Chuyến đi đã tạo'),
                          Tab(text: 'Chuyến đi tham gia'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        children: [
                          _buildTripList(createdTrips),
                          _buildTripList(joinedTrips),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripList(List<Map<String, dynamic>> trips) {
    if (trips.isEmpty) {
      return const Center(
        child: Text(
          'Không có lịch sử chuyến đi nào',
          style: TextStyle(color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
        ),
      );
    }
    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
                child: const Icon(Icons.card_travel, color: Color(0xFF0284C7), size: 20),
              ),
              title: Text(
                trip['destination'] ?? 'Chưa xác định',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              subtitle: Text('Mã chuyến đi: ${trip['id']}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AdminTripDetailView(tripId: trip['id']),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class UserDataSource extends DataTableSource {
  final List<Map<String, dynamic>> users;
  final BuildContext context;
  final Function(String) onLock;
  final Function(String, String) onShowHistory;

  UserDataSource({
    required this.users,
    required this.context,
    required this.onLock,
    required this.onShowHistory,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final userData = users[index];

    return DataRow.byIndex(
      index: index,
      onSelectChanged: (_) => onShowHistory(userData['id'], userData['name'] ?? 'Người dùng'),
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: getAvatarProvider(userData['profilePic']) ?? NetworkImage('https://ui-avatars.com/api/?name=${userData['name'] ?? 'User'}&background=3B82F6&color=fff'),
            ),
          ),
        ),
        DataCell(Text(
          userData['name'] ?? 'Ẩn danh',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        )),
        DataCell(Text(
          userData['email'] ?? 'Chưa cập nhật',
          style: const TextStyle(color: Color(0xFF475569)),
        )),
        DataCell(Text(
          userData['createdAt'] != null ? (userData['createdAt'] as dynamic).toDate().toString().split(' ')[0] : 'Chưa cập nhật',
          style: const TextStyle(color: Color(0xFF64748B)),
        )),
        DataCell(_buildStatusBadge(userData['status'] ?? 'active')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.history_rounded, color: Color(0xFF3B82F6), size: 20),
                onPressed: () => onShowHistory(userData['id'], userData['name'] ?? 'Người dùng'),
                tooltip: 'Xem lịch sử hoạt động',
              ),
              IconButton(
                icon: const Icon(Icons.block_rounded, color: Color(0xFFEF4444), size: 20),
                onPressed: () => onLock(userData['id']),
                tooltip: 'Khóa tài khoản',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Đang hoạt động' : 'Đã khóa',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}

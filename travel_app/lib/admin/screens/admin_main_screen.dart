import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dashboard_screen.dart';
import 'user_management_screen.dart';
import 'location_management_screen.dart';
import 'trip_management_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  // Cache kết quả kiểm tra Admin để tránh lag khi rebuild
  Future<DocumentSnapshot>? _adminCheckFuture;
  String? _lastUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData) {
          return _buildLoginRequired();
        }

        // Khởi tạo Future kiểm tra Admin chỉ khi UID thay đổi
        if (_lastUid != snapshot.data!.uid) {
          _lastUid = snapshot.data!.uid;
          _adminCheckFuture = FirebaseFirestore.instance
              .collection('users')
              .doc(_lastUid)
              .get();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: _adminCheckFuture,
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return _buildErrorScreen(userSnapshot.error.toString(), snapshot.data!.uid);
            }

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final data = userSnapshot.data?.data() as Map<String, dynamic>?;
            if (data == null || data['role'] != 'admin') {
              return _buildAccessDenied(snapshot.data!.email);
            }

            // Giao diện quản trị chính khi đã được xác thực hoàn toàn
            // Được bọc trong AdminPortalBody để việc setState chuyển đổi tab không kích hoạt lại các Builder này.
            return AdminPortalBody(firebaseUser: snapshot.data!);
          },
        );
      },
    );
  }

  Widget _buildLoginRequired() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, size: 48, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đăng nhập Portal Admin',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng đăng nhập tài khoản có quyền quản trị để truy cập hệ thống.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showLoginDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Đăng nhập ngay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ).animate().fade().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildAccessDenied(String? email) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.gpp_bad_outlined, size: 48, color: Color(0xFFEF4444)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Từ chối truy cập',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Text(
                'Tài khoản $email không có quyền quản trị viên trên hệ thống.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    foregroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Đăng xuất', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ).animate().fade().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildErrorScreen(String error, String uid) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, size: 48, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Lỗi kết nối Firestore',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: Text(
                  error,
                  style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              const Text('UID của bạn:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  uid,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF334155)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Đăng xuất'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fade().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  void _showLoginDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng nhập quản trị', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
                navigator.pop();
              } catch (e) {
                messenger.showSnackBar(SnackBar(
                  content: Text('Đăng nhập thất bại: $e'),
                  backgroundColor: const Color(0xFFEF4444),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Đăng nhập'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
                navigator.pop();
              } on FirebaseAuthException catch (e) {
                messenger.showSnackBar(SnackBar(
                  content: Text('Đăng nhập Google thất bại: ${e.message ?? e.code}'),
                  backgroundColor: const Color(0xFFEF4444),
                ));
              } catch (e) {
                messenger.showSnackBar(SnackBar(
                  content: Text('Đăng nhập Google thất bại: $e'),
                  backgroundColor: const Color(0xFFEF4444),
                ));
              }
            },
            icon: const Icon(Icons.account_circle_outlined),
            label: const Text('Đăng nhập bằng Google'),
          ),
        ],
      ),
    );
  }
}

class AdminPortalBody extends StatefulWidget {
  final User firebaseUser;
  const AdminPortalBody({super.key, required this.firebaseUser});

  @override
  State<AdminPortalBody> createState() => _AdminPortalBodyState();
}

class _AdminPortalBodyState extends State<AdminPortalBody> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const UserManagementScreen(),
    const TripManagementScreen(),
    const LocationManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          _buildCustomSidebar(context, isDesktop, widget.firebaseUser),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSidebar(BuildContext context, bool isExpanded, User firebaseUser) {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': 'Bảng điều khiển'},
      {'icon': Icons.people_outline, 'activeIcon': Icons.people, 'label': 'Người dùng'},
      {'icon': Icons.map_outlined, 'activeIcon': Icons.map, 'label': 'Chuyến đi'},
      {'icon': Icons.location_on_outlined, 'activeIcon': Icons.location_on, 'label': 'Địa điểm'},
    ];

    return Container(
      width: isExpanded ? 260 : 78,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Deep Slate Dark Background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(4, 0),
          )
        ],
      ),
      child: Column(
        children: [
          // Logo/Brand Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.explore_rounded, color: Colors.white, size: 24),
                ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'TREKKO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                      Text(
                        'PORTAL QUẢN TRỊ',
                        style: TextStyle(
                          color: const Color(0xFF3B82F6).withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                    ],
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = index),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0x333B82F6), Color(0x0A3B82F6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), width: 1)
                            : Border.all(color: Colors.transparent, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected ? item['activeIcon'] : item['icon'],
                            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                            size: 22,
                          ),
                          if (isExpanded) ...[
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item['label'],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF3B82F6),
                                  shape: BoxShape.circle,
                                ),
                              ).animate().scale(duration: 150.ms),
                          ],
                        ],
                      ),
                    ),
                  ),
                ).animate().fade(delay: (index * 50).ms, duration: 300.ms).slideX(begin: -0.1);
              },
            ),
          ),

          // Admin Footer Info & Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
            ),
            child: Column(
              children: [
                if (isExpanded)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                          child: const Icon(Icons.admin_panel_settings, color: Color(0xFF3B82F6), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quản trị viên',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                firebaseUser.email ?? 'admin@trekko.vn',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExpanded
                          ? const Color(0xFFEF4444).withOpacity(0.1)
                          : Colors.transparent,
                      foregroundColor: const Color(0xFFEF4444),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color(0xFFEF4444).withOpacity(isExpanded ? 0.2 : 0.0),
                          width: 1,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: isExpanded
                        ? const Text(
                            'Đăng xuất',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

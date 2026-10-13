import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/features/packing/models/packing_model.dart';
import 'package:travel_app/core/services/ai_backend_service.dart';

class PackingListScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String destination;
  final int days;
  final String weatherContext;
  final String gender;
  final DateTime? startDate;
  final DateTime? endDate;

  const PackingListScreen({
    super.key,
    required this.tripId,
    required this.destination,
    required this.days,
    required this.weatherContext,
    required this.gender,
    this.startDate,
    this.endDate,
  });

  @override
  ConsumerState<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends ConsumerState<PackingListScreen> {
  final ValueNotifier<bool> _isSyncing = ValueNotifier(false);
  bool _isGenerating = false;

  @override
  void dispose() {
    _isSyncing.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkAndGenerate();
  }

  Future<void> _checkAndGenerate() async {
    try {
      // 1. Kiểm tra dữ liệu hiện tại trên Firestore
      final doc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get();

      final data = doc.data();
      final packingList = data?['packing_list'] ?? data?['packingList'];

      // 2. Nếu chưa có hoặc mảng rỗng, tiến hành gọi AI sinh mới
      if (packingList == null || (packingList as List).isEmpty) {
        setState(() => _isGenerating = true);
        
        await ref.read(aiBackendServiceProvider).generateLazyPackingList(
          widget.tripId, 
          widget.destination, 
          widget.days,
          startDate: widget.startDate,
          endDate: widget.endDate,
        );
      }
    } catch (e) {
      debugPrint('Error in _checkAndGenerate: $e');
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  double _calculateProgress(List<PackingCategory> categories) {
    if (categories.isEmpty) return 0.0;

    int totalItems = 0;
    int checkedItems = 0;

    for (var category in categories) {
      totalItems += category.items.length;
      checkedItems += category.items.where((item) => item.isChecked).length;
    }

    return totalItems > 0 ? checkedItems / totalItems : 0.0;
  }

  Future<void> _syncCategories(List<PackingCategory> allCategories) async {
    _isSyncing.value = true;
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .update({
        'packing_list': allCategories.map((c) => c.toJson()).toList(),
      });
    } catch (e) {
      debugPrint('Error updating packing list: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể đồng bộ dữ liệu. Vui lòng thử lại.')),
        );
      }
    } finally {
      if (mounted) {
        _isSyncing.value = false;
      }
    }
  }

  // Đã xoá hàm _toggleItem do PackingItemTile tự quản lý.

  Future<void> _editItemName(PackingItem item, List<PackingCategory> allCategories) async {
    final controller = TextEditingController(text: item.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa vật dụng'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tên vật dụng'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Lưu')),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty && newName.trim() != item.name) {
      setState(() {
        item.name = newName.trim();
      });
      _syncCategories(allCategories);
    }
  }

  Future<void> _addNewItem(List<PackingCategory> allCategories) async {
    if (allCategories.isEmpty) return;
    
    final controller = TextEditingController();
    PackingCategory selectedCategory = allCategories.first;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm đồ dùng mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Nhập tên đồ dùng'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PackingCategory>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Phân loại'),
                    items: allCategories.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.name),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCategory = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                TextButton(
                  onPressed: () => Navigator.pop(context, {'name': controller.text, 'category': selectedCategory}),
                  child: const Text('Thêm'),
                ),
              ],
            );
          }
        );
      },
    );

    if (result != null && result['name'] != null && result['name'].toString().trim().isNotEmpty) {
      final String itemName = result['name'].toString().trim();
      final PackingCategory category = result['category'] as PackingCategory;
      
      setState(() {
        category.items.add(PackingItem(name: itemName, isChecked: false));
      });
      _syncCategories(allCategories);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Danh sách hành lý AI'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSyncing,
            builder: (context, isSyncing, child) {
              if (isSyncing) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.cloud_done, color: Colors.white70, size: 20),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          
          // Ưu tiên packing_list snake_case
          final packingData = data?['packing_list'] ?? data?['packingList'];

          // Hiển thị Loading nếu đang trong quá trình AI làm việc
          if (_isGenerating || packingData == null || (packingData as List).isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'AI đang khởi động máy chủ & chuẩn bị hành lý...',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Vui lòng đợi trong giây lát. Quá trình khởi tạo server có thể mất tới 1 phút nếu là lần đầu tiên trong ngày.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }

          final categories = PackingCategory.fromList(packingData);

          return Scaffold(
            body: _buildContent(theme, categories),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _addNewItem(categories),
              icon: const Icon(Icons.add),
              label: const Text('Thêm đồ'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(ThemeData theme, List<PackingCategory> categories) {
    final progress = _calculateProgress(categories);

    return Column(
      children: [
        _buildProgressCard(theme, progress),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryTile(category, theme, categories);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(ThemeData theme, double progress) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ chuẩn bị',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress == 1.0 
                ? 'Tuyệt vời! Bạn đã sẵn sàng khởi hành. ✈️'
                : 'Bạn vẫn còn một vài món đồ cần chuẩn bị.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(PackingCategory category, ThemeData theme, List<PackingCategory> allCategories) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        key: PageStorageKey<String>('expansion_${category.name}'),
        title: Text(
          category.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: Icon(
          _getCategoryIcon(category.name),
          color: theme.colorScheme.primary,
        ),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        children: category.items.map((item) {
          return PackingItemTile(
            item: item,
            category: category,
            theme: theme,
            onSync: () => _syncCategories(allCategories),
            onDelete: () {
              setState(() {
                category.items.remove(item);
              });
              _syncCategories(allCategories);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa ${item.name}'), duration: const Duration(seconds: 2)),
              );
            },
            onEdit: () => _editItemName(item, allCategories),
          );
        }).toList(),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('quần áo') || name.contains('trang phục')) return Icons.checkroom;
    if (name.contains('điện tử') || name.contains('công nghệ')) return Icons.devices;
    if (name.contains('vệ sinh') || name.contains('cá nhân')) return Icons.spa;
    if (name.contains('giấy tờ')) return Icons.description;
    if (name.contains('thuốc') || name.contains('y tế')) return Icons.medical_services;
    return Icons.shopping_bag;
  }
}

class PackingItemTile extends StatefulWidget {
  final PackingItem item;
  final PackingCategory category;
  final VoidCallback onSync;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final ThemeData theme;

  const PackingItemTile({
    super.key,
    required this.item,
    required this.category,
    required this.onSync,
    required this.onDelete,
    required this.onEdit,
    required this.theme,
  });

  @override
  State<PackingItemTile> createState() => _PackingItemTileState();
}

class _PackingItemTileState extends State<PackingItemTile> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.item.isChecked;
  }

  @override
  void didUpdateWidget(covariant PackingItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật lại state cục bộ nếu data từ Firebase đẩy về có thay đổi thực sự
    if (oldWidget.item.isChecked != widget.item.isChecked) {
      _isChecked = widget.item.isChecked;
    }
  }

  void _toggle() {
    // 1. Optimistic Update: Đổi UI tức thời (rất mượt, không chờ Firebase)
    setState(() {
      _isChecked = !_isChecked;
      widget.item.isChecked = _isChecked;
    });
    // 2. Đồng bộ ngầm lên Firebase
    widget.onSync();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${widget.category.name}_${widget.item.name}_${widget.item.hashCode}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => widget.onDelete(),
      child: InkWell(
        onLongPress: widget.onEdit,
        child: CheckboxListTile(
          value: _isChecked,
          onChanged: (val) => _toggle(),
          title: Text(
            widget.item.name,
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              decoration: _isChecked ? TextDecoration.lineThrough : null,
              color: _isChecked 
                  ? widget.theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)
                  : widget.theme.textTheme.bodyMedium?.color,
              fontWeight: widget.item.reasoning != null ? FontWeight.w600 : null,
            ),
          ),
          subtitle: widget.item.reasoning != null && widget.item.reasoning!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.item.reasoning!,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: widget.theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          activeColor: widget.theme.colorScheme.primary,
          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
}

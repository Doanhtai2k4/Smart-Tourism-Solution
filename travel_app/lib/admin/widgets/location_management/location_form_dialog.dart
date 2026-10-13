import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/destination_model.dart';
import '../../services/admin_service.dart';

class LocationFormDialog extends StatefulWidget {
  final String? id;
  final DestinationModel? initialData;

  const LocationFormDialog({super.key, this.id, this.initialData});

  @override
  State<LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  bool _isSaving = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _imageController; // Dùng comma-separated cho multiple images
  late TextEditingController _categoryController;
  late TextEditingController _provinceController;
  late TextEditingController _countryController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _ticketPriceController;
  late TextEditingController _idealDurationController;
  
  // AI & Context
  late TextEditingController _weatherController;
  late TextEditingController _eventController;
  late TextEditingController _budgetLevelController;
  late TextEditingController _imageQueryController;

  // Lists (Comma-separated)
  late TextEditingController _tagsController;
  late TextEditingController _suitableForController;
  late TextEditingController _bestTimeController;
  late TextEditingController _topActivitiesController;
  late TextEditingController _searchKeywordsController;

  // Stats
  late TextEditingController _ratingController;
  late TextEditingController _viewCountController;
  late TextEditingController _favoriteCountController;
  late TextEditingController _trendingScoreController;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    
    _nameController = TextEditingController(text: data?.name);
    _descController = TextEditingController(text: data?.description);
    _imageController = TextEditingController(text: data?.images.join(', '));
    _categoryController = TextEditingController(text: data?.category);
    _provinceController = TextEditingController(text: data?.province);
    _countryController = TextEditingController(text: data?.country ?? 'Việt Nam');
    _addressController = TextEditingController(text: data?.address);
    _latController = TextEditingController(text: data?.latitude?.toString());
    _lngController = TextEditingController(text: data?.longitude?.toString());
    _ticketPriceController = TextEditingController(text: data?.ticketPrice?.toString());
    _idealDurationController = TextEditingController(text: data?.idealDuration?.toString());
    
    _weatherController = TextEditingController(text: data?.weatherCondition);
    _eventController = TextEditingController(text: data?.upcomingEvent);
    _budgetLevelController = TextEditingController(text: data?.budgetLevel);
    _imageQueryController = TextEditingController(text: data?.imageQuery);

    _tagsController = TextEditingController(text: data?.tags.join(', '));
    _suitableForController = TextEditingController(text: data?.suitableFor.join(', '));
    _bestTimeController = TextEditingController(text: data?.bestTimeToVisit.join(', '));
    _topActivitiesController = TextEditingController(text: data?.topActivities.join(', '));
    _searchKeywordsController = TextEditingController(text: data?.searchKeywords.join(', '));

    _ratingController = TextEditingController(text: data?.averageRating.toString() ?? '5.0');
    _viewCountController = TextEditingController(text: data?.viewCount.toString() ?? '0');
    _favoriteCountController = TextEditingController(text: data?.favoriteCount.toString() ?? '0');
    _trendingScoreController = TextEditingController(text: data?.trendingScore.toString() ?? '0');
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose(); _descController.dispose(); _imageController.dispose();
    _categoryController.dispose(); _provinceController.dispose(); _countryController.dispose();
    _addressController.dispose(); _latController.dispose(); _lngController.dispose();
    _ticketPriceController.dispose(); _idealDurationController.dispose();
    _weatherController.dispose(); _eventController.dispose(); _budgetLevelController.dispose();
    _imageQueryController.dispose(); _tagsController.dispose(); _suitableForController.dispose();
    _bestTimeController.dispose(); _topActivitiesController.dispose(); _searchKeywordsController.dispose();
    _ratingController.dispose(); _viewCountController.dispose(); _favoriteCountController.dispose();
    _trendingScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 900,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              const Divider(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSectionTitle('Thông tin cơ bản'),
                      _buildTwoColumnRow(
                        _buildTextField(_nameController, 'Tên địa điểm', isRequired: true),
                        _buildTextField(_categoryController, 'Phân loại (văn hóa, biển,...)'),
                      ),
                      _buildTwoColumnRow(
                        _buildTextField(_provinceController, 'Tỉnh/Thành phố'),
                        _buildTextField(_countryController, 'Quốc gia'),
                      ),
                      _buildTextField(_addressController, 'Địa chỉ chi tiết'),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle('Vị trí & Hình ảnh'),
                      _buildTwoColumnRow(
                        _buildTextField(_latController, 'Vĩ độ (Latitude)', isNumber: true),
                        _buildTextField(_lngController, 'Kinh độ (Longitude)', isNumber: true),
                      ),
                      _buildTextField(_imageController, 'Danh sách URL ảnh (phân cách bởi dấu phẩy)'),
                      _buildTextField(_imageQueryController, 'Từ khóa tìm ảnh (Unsplash Query)'),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Nội dung & Đặc điểm'),
                      _buildTextField(_descController, 'Mô tả chi tiết', maxLines: 4),
                      _buildTwoColumnRow(
                        _buildTextField(_ticketPriceController, 'Giá vé tham khảo', isNumber: true),
                        _buildTextField(_idealDurationController, 'Số ngày ở lý tưởng', isNumber: true),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Thông tin AI & Ngữ cảnh'),
                      _buildTwoColumnRow(
                        _buildTextField(_weatherController, 'Điều kiện thời tiết/Mùa'),
                        _buildTextField(_eventController, 'Sự kiện sắp tới'),
                      ),
                      _buildTextField(_budgetLevelController, 'Mức chi phí (\$, \$\$, \$\$\$ hoặc mô tả)'),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Danh sách hỗ trợ (Phân cách bởi dấu phẩy)'),
                      _buildTextField(_tagsController, 'Tags (biển, văn hóa, núi,...)'),
                      _buildTextField(_suitableForController, 'Phù hợp cho (Gia đình, Cặp đôi, Trẻ em,...)'),
                      _buildTextField(_bestTimeController, 'Thời điểm đẹp nhất (Tháng 1-3, Mùa xuân,...)'),
                      _buildTextField(_topActivitiesController, 'Hoạt động nổi bật'),
                      _buildTextField(_searchKeywordsController, 'Từ khóa tìm kiếm'),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Số liệu thống kê (Admin Override)'),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_ratingController, 'Đánh giá (0-5)', isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_viewCountController, 'Lượt xem', isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_favoriteCountController, 'Yêu thích', isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(_trendingScoreController, 'Điểm Trending', isNumber: true)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.id == null ? 'Thêm địa điểm mới' : 'Chỉnh sửa địa điểm',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.id == null ? 'Cung cấp đầy đủ thông tin để AI có thể gợi ý chính xác' : 'Cập nhật thông tin cho ${widget.initialData?.name}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isRequired = false, bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Vui lòng nhập $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('Hủy bỏ'),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Lưu thông tin', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final List<String> images = _imageController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final List<String> tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final List<String> suitableFor = _suitableForController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final List<String> bestTime = _bestTimeController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final List<String> activities = _topActivitiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final List<String> keywords = _searchKeywordsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final Map<String, dynamic> data = {
        'name': _nameController.text.trim(),
        'nameLowerCase': _nameController.text.trim().toLowerCase(),
        'description': _descController.text.trim(),
        'images': images,
        'category': _categoryController.text.trim(),
        'province': _provinceController.text.trim(),
        'country': _countryController.text.trim(),
        'address': _addressController.text.trim(),
        'latitude': double.tryParse(_latController.text) ?? 0.0,
        'longitude': double.tryParse(_lngController.text) ?? 0.0,
        'ticketPrice': int.tryParse(_ticketPriceController.text),
        'idealDuration': int.tryParse(_idealDurationController.text),
        'weatherCondition': _weatherController.text.trim(),
        'upcomingEvent': _eventController.text.trim(),
        'budgetLevel': _budgetLevelController.text.trim(),
        'imageQuery': _imageQueryController.text.trim(),
        'tags': tags,
        'suitableFor': suitableFor,
        'bestTimeToVisit': bestTime,
        'topActivities': activities,
        'searchKeywords': keywords,
        'averageRating': double.tryParse(_ratingController.text) ?? 5.0,
        'viewCount': int.tryParse(_viewCountController.text) ?? 0,
        'favoriteCount': int.tryParse(_favoriteCountController.text) ?? 0,
        'trendingScore': int.tryParse(_trendingScoreController.text) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.id == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        await _adminService.addLocation(data);
      } else {
        await _adminService.updateLocation(widget.id!, data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.id == null ? 'Đã thêm địa điểm mới' : 'Đã cập nhật địa điểm')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

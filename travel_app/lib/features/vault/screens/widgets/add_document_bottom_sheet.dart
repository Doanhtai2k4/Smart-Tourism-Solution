import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import '../../models/document_model.dart';
import '../../provider/vault_provider.dart';

class AddDocumentBottomSheet extends ConsumerStatefulWidget {
  final String tripId;
  const AddDocumentBottomSheet({super.key, required this.tripId});

  @override
  ConsumerState<AddDocumentBottomSheet> createState() => _AddDocumentBottomSheetState();
}

class _AddDocumentBottomSheetState extends ConsumerState<AddDocumentBottomSheet> {
  final _titleController = TextEditingController();
  DocumentType _selectedType = DocumentType.other;
  File? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() => _selectedFile = File(pickedFile.path));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Thêm tài liệu mới",
            style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          if (_selectedFile != null)
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: FileImage(_selectedFile!), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _selectedFile = null),
                      style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildPickerButton(
                    context, 
                    Icons.photo_library_rounded, 
                    "Thư viện", 
                    () => _pickImage(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPickerButton(
                    context, 
                    Icons.camera_alt_rounded, 
                    "Chụp ảnh", 
                    () => _pickImage(ImageSource.camera),
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: "Tên tài liệu",
              hintText: "Ví dụ: Vé máy bay đi Đà Lạt",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<DocumentType>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: "Phân loại",
              border: OutlineInputBorder(),
            ),
            items: DocumentType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(_getTypeName(type)));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isUploading || _selectedFile == null ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isUploading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Tải lên tài liệu"),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPickerButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.primary.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
          color: context.colors.primary.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: context.colors.primary),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _getTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.ticket: return "Vé máy bay/tàu";
      case DocumentType.passport: return "Hộ chiếu/CCCD";
      case DocumentType.hotel: return "Đặt phòng khách sạn";
      case DocumentType.visa: return "Visa/Thị thực";
      case DocumentType.insurance: return "Bảo hiểm";
      case DocumentType.other: return "Khác";
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _selectedFile == null) return;

    setState(() => _isUploading = true);
    try {
      await ref.read(vaultActionsProvider).uploadAndSaveDocument(
        tripId: widget.tripId,
        title: _titleController.text,
        type: _selectedType,
        file: _selectedFile!,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải lên: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}

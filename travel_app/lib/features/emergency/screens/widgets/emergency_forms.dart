import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import '../../models/emergency_model.dart';
import '../../provider/emergency_provider.dart';

class MedicalInfoForm extends ConsumerStatefulWidget {
  final EmergencyModel info;
  const MedicalInfoForm({super.key, required this.info});

  @override
  ConsumerState<MedicalInfoForm> createState() => _MedicalInfoFormState();
}

class _MedicalInfoFormState extends ConsumerState<MedicalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bloodTypeCtrl;
  late TextEditingController _allergiesCtrl;
  late TextEditingController _chronicCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    final medical = widget.info.medicalInfo;
    _bloodTypeCtrl = TextEditingController(text: medical?.bloodType);
    _allergiesCtrl = TextEditingController(text: medical?.allergies);
    _chronicCtrl = TextEditingController(text: medical?.chronicConditions);
    _notesCtrl = TextEditingController(text: medical?.notes);
  }

  @override
  void dispose() {
    _bloodTypeCtrl.dispose();
    _allergiesCtrl.dispose();
    _chronicCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final updatedMedical = MedicalInfo(
        bloodType: _bloodTypeCtrl.text.trim().isEmpty ? null : _bloodTypeCtrl.text.trim(),
        allergies: _allergiesCtrl.text.trim().isEmpty ? null : _allergiesCtrl.text.trim(),
        chronicConditions: _chronicCtrl.text.trim().isEmpty ? null : _chronicCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      final updatedInfo = EmergencyModel(
        tripId: widget.info.tripId,
        localNumbers: widget.info.localNumbers,
        personalContacts: widget.info.personalContacts,
        medicalInfo: updatedMedical,
        embassyInfo: widget.info.embassyInfo,
      );

      ref.read(emergencyActionsProvider).updateInfo(updatedInfo);
      Navigator.pop(context);
    }
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
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Cập nhật thông tin y tế", style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _bloodTypeCtrl,
                decoration: const InputDecoration(labelText: "Nhóm máu", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _allergiesCtrl,
                decoration: const InputDecoration(labelText: "Dị ứng", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chronicCtrl,
                decoration: const InputDecoration(labelText: "Tình trạng bệnh lý", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: "Ghi chú thêm", border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Lưu thông tin"),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class EmergencyContactForm extends ConsumerStatefulWidget {
  final EmergencyModel info;
  const EmergencyContactForm({super.key, required this.info});

  @override
  ConsumerState<EmergencyContactForm> createState() => _EmergencyContactFormState();
}

class _EmergencyContactFormState extends ConsumerState<EmergencyContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _relationCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relationCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newContact = EmergencyContact(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        relation: _relationCtrl.text.trim().isEmpty ? null : _relationCtrl.text.trim(),
      );

      final updatedContacts = List<EmergencyContact>.from(widget.info.personalContacts)..add(newContact);

      final updatedInfo = EmergencyModel(
        tripId: widget.info.tripId,
        localNumbers: widget.info.localNumbers,
        personalContacts: updatedContacts,
        medicalInfo: widget.info.medicalInfo,
        embassyInfo: widget.info.embassyInfo,
      );

      ref.read(emergencyActionsProvider).updateInfo(updatedInfo);
      Navigator.pop(context);
    }
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
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Thêm liên hệ khẩn cấp", style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Tên người liên hệ (*)", border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? "Vui lòng nhập tên" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: "Số điện thoại (*)", border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? "Vui lòng nhập số điện thoại" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationCtrl,
                decoration: const InputDecoration(labelText: "Mối quan hệ", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Thêm liên hệ"),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

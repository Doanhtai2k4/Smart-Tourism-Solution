import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/core/utils.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import 'package:travel_app/features/auth/models/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userInfoProvider);
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phoneNumber);
    _bioController = TextEditingController(text: user?.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      _showLoadingDialog();
      final result = await ref.read(authStateProvider.notifier).uploadProfileImage(File(image.path));
      if (mounted) {
        Navigator.pop(context); // Close loading
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
          ),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.profileUpdated),
              backgroundColor: context.colors.primary,
            ),
          ),
        );
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog();
      final result = await ref.read(authStateProvider.notifier).updateProfile(
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        bio: _bioController.text,
      );
      if (mounted) {
        Navigator.pop(context); // Close loading
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
          ),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.profileUpdated),
              backgroundColor: context.colors.primary,
            ),
          ),
        );
      }
    }
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChangePasswordBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userInfoProvider);
    final cs = context.colors;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(context.l10n.editProfile, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Avatar Area
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFE4E6EB),
                      backgroundImage: getAvatarProvider(user?.profilePic),
                      child: getAvatarProvider(user?.profilePic) == null 
                        ? const Icon(Icons.person, size: 80, color: Color(0xFF8A8D91)) 
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 2),
                          ),
                          child: Icon(Icons.camera_alt_rounded, color: cs.onPrimary, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Information Form
              _buildTextField(
                controller: _nameController,
                label: context.l10n.fullName,
                icon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? context.l10n.enterNameError : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: context.l10n.emailAddress,
                icon: Icons.email_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: context.l10n.phone_number,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _bioController,
                label: context.l10n.bio_label,
                icon: Icons.info_outline,
                maxLines: 3,
                hintText: context.l10n.bio_hint,
              ),
              const SizedBox(height: 40),

              // 3. Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(context.l10n.saveChanges, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              
              const Divider(),
              const SizedBox(height: 16),
              
              TextButton.icon(
                onPressed: _showChangePasswordSheet,
                icon: const Icon(Icons.lock_reset_rounded),
                label: Text(context.l10n.change_password),
                style: TextButton.styleFrom(foregroundColor: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    final cs = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: cs.primary),
            filled: true,
            fillColor: readOnly ? cs.surfaceContainerLowest : cs.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: cs.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class ChangePasswordBottomSheet extends ConsumerStatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  ConsumerState<ChangePasswordBottomSheet> createState() => _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends ConsumerState<ChangePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final result = await ref.read(authRepositoryProvider).changePassword(
        oldPassword: _oldPassController.text,
        newPassword: _newPassController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
          ),
          (_) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.change_password_success), backgroundColor: Colors.green),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(context.l10n.change_password, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildPassField(_oldPassController, context.l10n.old_password),
            const SizedBox(height: 16),
            _buildPassField(_newPassController, context.l10n.new_password),
            const SizedBox(height: 16),
            _buildPassField(
              _confirmPassController, 
              context.l10n.confirm_new_password,
              validator: (val) => val != _newPassController.text ? context.l10n.password_mismatch : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(context.l10n.update_password, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassField(TextEditingController controller, String label, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator: validator ?? (val) => val == null || val.length < 6 ? context.l10n.password_min_length : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: context.colors.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}

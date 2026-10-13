import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/l10n/app_localizations.dart';
import 'package:travel_app/core/widgets/custom_auth_widgets.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../models/user_model.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? password;

  const CompleteProfileScreen({
    super.key,
    this.email,
    this.password,
  });

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  DateTime? selectedDate;
  String? selectedGender;
  String? selectedCountry;
  String? selectedOccupation;

  AppLocalizations get l10n => context.l10n;

  List<String> get genderOptions => [l10n.gender_male, l10n.gender_female, l10n.gender_other];
  final List<String> countryOptions = ['Việt Nam', 'Mỹ', 'Nhật Bản', 'Hàn Quốc', 'Pháp', 'Anh', 'Singapore'];
  final List<String> occupationOptions = ['Sinh viên', 'Nhân viên văn phòng', 'Kinh doanh', 'Tự do', 'Nghỉ hưu', 'Khác'];
  


  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.select_dob_error)),
        );
        return;
      }

      // Get current user info robustly
      final authState = ref.read(authStateProvider);
      final firebaseUser = ref.read(firebaseAuthProvider).currentUser;
      
      if (firebaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.session_not_found_error)),
        );
        return;
      }

      final String uid = firebaseUser.uid;
      final String email = firebaseUser.email ?? widget.email ?? '';

      final updatedUser = UserModel(
        uid: uid,
        email: email,
        name: nameController.text.trim(),
        dateOfBirth: selectedDate,
        gender: selectedGender,
        country: selectedCountry,
        occupation: selectedOccupation,
        hobbies: const [],
        isAuthenticated: true,
        createdAt: authState.value?.createdAt ?? DateTime.now(),
      );

      ref.read(authStateProvider.notifier).saveUserProfile(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.complete_profile_title),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.complete_profile_greeting,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.complete_profile_subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                // Name field
                CustomTextField(
                  controller: nameController,
                  hintText: l10n.fullName,
                  prefixIcon: Icons.person_outline,
                  validator: (value) => (value == null || value.isEmpty) ? l10n.pleaseEnterName : null,
                ),
                const SizedBox(height: 16),

                // Date of birth
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: dobController,
                      hintText: l10n.dob_label,
                      prefixIcon: Icons.calendar_today_outlined,
                      validator: (value) => (value == null || value.isEmpty) ? l10n.select_dob_error : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender dropdown
                _buildDropdown(
                  value: selectedGender,
                  hint: l10n.gender_label,
                  items: genderOptions,
                  onChanged: (val) => setState(() => selectedGender = val),
                  validator: (val) => val == null ? l10n.select_gender_error : null,
                ),
                const SizedBox(height: 16),

                // Country dropdown
                _buildDropdown(
                  value: selectedCountry,
                  hint: l10n.country_label,
                  items: countryOptions,
                  onChanged: (val) => setState(() => selectedCountry = val),
                  validator: (val) => val == null ? l10n.validationCompleteAll : null,
                ),
                const SizedBox(height: 16),

                // Occupation dropdown
                _buildDropdown(
                  value: selectedOccupation,
                  hint: l10n.occupation_label,
                  items: occupationOptions,
                  onChanged: (val) => setState(() => selectedOccupation = val),
                  validator: (val) => val == null ? l10n.validationCompleteAll : null,
                ),
                const SizedBox(height: 48),

                // Submit Button
                CustomPrimaryButton(
                  onPressed: _submitProfile,
                  text: l10n.finish_button,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      iconEnabledColor: AppColors.primary,
    );
  }
}

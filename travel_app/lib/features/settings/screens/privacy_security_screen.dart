import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/features/settings/screens/profile_screen.dart';
import '../provider/settings_provider.dart';

class PrivacySecurityScreen extends ConsumerWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferenceProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.privacy_security_title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: prefs.when(
        data: (values) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              title: context.l10n.privacy_title,
              children: [
                _buildSwitchTile(
                  context,
                  title: context.l10n.show_public_profile,
                  subtitle: context.l10n.show_public_profile_sub,
                  value: values['pref_public_profile'] ?? false,
                  onChanged: () => ref.read(preferenceProvider.notifier).toggle('pref_public_profile'),
                ),
                _buildSwitchTile(
                  context,
                  title: context.l10n.search_by_email_phone,
                  subtitle: context.l10n.search_by_email_phone_sub,
                  value: values['pref_allow_search'] ?? true,
                  onChanged: () => ref.read(preferenceProvider.notifier).toggle('pref_allow_search'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: context.l10n.account_security,
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(context.l10n.change_password, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const ChangePasswordBottomSheet(),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                  title: Text(context.l10n.delete_account, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.red)),
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirm_delete_account),
        content: Text(context.l10n.confirm_delete_account_sub),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () {
              // Logic xóa tài khoản thực tế ở đây
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.delete_request_sent)));
            }, 
            child: Text(context.l10n.delete_permanently, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title.toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(BuildContext context, {required String title, required String subtitle, required bool value, required VoidCallback onChanged}) {
    return SwitchListTile.adaptive(
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 13)),
      value: value,
      onChanged: (_) => onChanged(),
      activeColor: context.colors.primary,
    );
  }
}

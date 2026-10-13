import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import '../provider/settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferenceProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notification_settings_title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: prefs.when(
        data: (values) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              title: context.l10n.trip_activity,
              children: [
                _buildSwitchTile(
                  context,
                  ref,
                  title: context.l10n.upcoming_trip_reminder,
                  subtitle: context.l10n.upcoming_trip_reminder_sub,
                  value: values['pref_notify_trip'] ?? true,
                  onChanged: () => ref.read(preferenceProvider.notifier).toggle('pref_notify_trip'),
                ),
                _buildSwitchTile(
                  context,
                  ref,
                  title: context.l10n.group_updates,
                  subtitle: context.l10n.group_updates_sub,
                  value: values['pref_notify_group'] ?? true,
                  onChanged: () => ref.read(preferenceProvider.notifier).toggle('pref_notify_group'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: context.l10n.news_events,
              children: [
                _buildSwitchTile(
                  context,
                  ref,
                  title: context.l10n.event_festival_notifications,
                  subtitle: context.l10n.event_festival_notifications_sub,
                  value: values['pref_notify_event'] ?? true,
                  onChanged: () => ref.read(preferenceProvider.notifier).toggle('pref_notify_event'),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("${context.l10n.error}: $e")),
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

  Widget _buildSwitchTile(
    BuildContext context, 
    WidgetRef ref, {
    required String title, 
    required String subtitle, 
    required bool value, 
    required VoidCallback onChanged
  }) {
    return SwitchListTile.adaptive(
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 13)),
      value: value,
      onChanged: (_) => onChanged(),
      activeColor: context.colors.primary,
    );
  }
}

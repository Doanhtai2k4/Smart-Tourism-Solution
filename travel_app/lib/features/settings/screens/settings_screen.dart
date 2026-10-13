import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/routing/app_routes.dart';

import 'package:travel_app/features/settings/screens/widgets/edit_profile_bottom_sheet.dart';
import 'package:travel_app/features/settings/screens/widgets/language_tile.dart';
import 'package:travel_app/features/settings/screens/widgets/settings_header.dart';
import 'package:travel_app/features/settings/screens/widgets/settings_section.dart';
import 'package:travel_app/features/settings/screens/widgets/settings_tile.dart';
import 'package:travel_app/features/settings/screens/widgets/theme_mode_tile.dart';

import '../../../core/common/app_dialog.dart';
import '../../../core/common/async_view.dart';
import '../../../core/extensions/context_theme.dart';
import '../../auth/provider/auth_providers.dart';
import '../provider/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final localeAsync = ref.watch(languageProvider);
    final themeAsync = ref.watch(themeModeProvider);
    final colors = context.colors;

    if (user == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),

                SettingsHeader(
                  name: user.name ?? context.l10n.user,
                  email: user.email,
                  photoUrl: user.profilePic,
                  onEditPressed: () => _showEditProfileSheet(context, ref),
                ),

                const SizedBox(height: 24),

                SettingsSection(
                  title: context.l10n.preferences,
                  children: [
                    AsyncView<ThemeMode>(
                      value: themeAsync,
                      builder: (themeMode) {
                        return ThemeModeTile(
                          isDarkMode: themeMode == ThemeMode.dark,
                          onToggle: () {
                            ref
                                .read(themeModeProvider.notifier)
                                .toggleTheme();
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AsyncView<Locale>(
                      value: localeAsync,
                      builder: (locale) {
                        return LanguageSelectorTile(
                          currentLocale: locale,
                          onLanguageSelected: (newLocale) {
                            ref
                                .read(languageProvider.notifier)
                                .changeLanguage(newLocale);
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SettingsSection(
                  title: context.l10n.tools_title,
                  children: [
                    SettingsTile(
                      icon: Icons.currency_exchange_rounded,
                      title: context.l10n.currency_converter_title,
                      subtitle: context.l10n.currency_converter_subtitle,
                      onTap: () => context.pushNamed(RouteNames.currencyConverter),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SettingsSection(
                  title: context.l10n.account,
                  children: [
                    SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: context.l10n.privacySecurity,
                      subtitle: context.l10n.privacySecurityDescription,
                      onTap: () => context.pushNamed(RouteNames.privacySecurity),
                    ),

                    const SizedBox(height: 12),
                    SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: context.l10n.notifications,
                      subtitle: context.l10n.notificationsDescription,
                      onTap: () => context.pushNamed(RouteNames.notificationSettings),
                    ),

                  ],
                ),

                const SizedBox(height: 24),

                SettingsSection(
                  title: context.l10n.support,
                  children: [
                    SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: context.l10n.helpSupport,
                      subtitle: context.l10n.helpSupportDescription,
                      onTap: () => context.pushNamed(RouteNames.helpSupport),
                    ),

                    const SizedBox(height: 12),
                    SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: context.l10n.about,
                      subtitle: context.l10n.aboutDescription,
                      onTap: () => context.pushNamed(RouteNames.about),
                    ),

                  ],
                ),

                const SizedBox(height: 24),

                SettingsSection(
                  title: context.l10n.actions,
                  children: [
                    SettingsTile(
                      icon: Icons.logout_rounded,
                      title: context.l10n.logOut,
                      subtitle: context.l10n.logOutDescription,
                      iconColor: colors.error,
                      titleColor: colors.error,
                      onTap: () => _showLogoutDialog(context, ref),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: colors.surface,
      elevation: 0,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.surface, colors.primary.withAlpha(20)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primary.withAlpha(31),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      color: colors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.settings,
                    style: text.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref) {
    context.pushNamed(RouteNames.profile);
  }


  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.destructive(
      context,
      icon: Icons.logout_rounded,
      title: context.l10n.logOut,
      message: context.l10n.logOutConfirmation,
      confirmText: context.l10n.logOut,
      cancelText: context.l10n.cancel,
    );

    if (confirmed == true) {
      ref.read(authStateProvider.notifier).signOut();
    }
  }
}

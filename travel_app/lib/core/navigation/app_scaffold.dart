import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';

import '../routing/app_routes.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  static const _navItems = [
    AppRoutes.home,
    AppRoutes.exploration,
    AppRoutes.history,
    AppRoutes.settings,
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final index = _navItems.indexWhere((path) => location.startsWith(path));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.surface,
      body: child,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.planTrip);
        },
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomAppBar(
        color: colors.surface,
        elevation: 8,
        shadowColor: Colors.black.withAlpha(30),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.zero,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: l10n.home,
                  selectedIndex: selectedIndex,
                  colors: colors,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.explore_outlined,
                  selectedIcon: Icons.explore,
                  label: l10n.explore,
                  selectedIndex: selectedIndex,
                  colors: colors,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.history_outlined,
                  selectedIcon: Icons.history,
                  label: l10n.visited,
                  selectedIndex: selectedIndex,
                  colors: colors,
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: l10n.profile,
                  selectedIndex: selectedIndex,
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int selectedIndex,
    required ColorScheme colors,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => context.go(_navItems[index]),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 24,
                color: isSelected
                    ? colors.primary
                    : colors.onSurface.withAlpha(145),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? colors.primary
                      : colors.onSurface.withAlpha(160),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

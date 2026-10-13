import 'package:flutter/material.dart';

import '../../../../core/extensions/context_theme.dart';
import '../../../../core/utils.dart';

class SettingsHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final VoidCallback onEditPressed;

  const SettingsHeader({
    super.key,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primary.withAlpha(217)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withAlpha(76),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(context),
          const SizedBox(width: 16),
          Expanded(child: _buildUserInfo(context)),
          _buildEditButton(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? ClipOval(
              child: buildAvatarImage(
                photoUrl,
                fit: BoxFit.cover,
                placeholder: (_) => _buildAvatarPlaceholder(context),
              ),
            )
          : _buildAvatarPlaceholder(context),
    );
  }

  Widget _buildAvatarPlaceholder(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE4E6EB),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Color(0xFF8A8D91),
          size: 48,
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final text = context.text;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.bodySmall?.copyWith(
            color: colors.onPrimary.withAlpha(229),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onEditPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.onPrimary.withAlpha(51),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.onPrimary.withAlpha(76),
            width: 1,
          ),
        ),
        child: Icon(Icons.edit_rounded, color: colors.onPrimary, size: 20),
      ),
    );
  }
}

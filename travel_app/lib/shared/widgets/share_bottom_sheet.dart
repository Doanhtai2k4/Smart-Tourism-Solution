import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'brand_icon.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/shared/models/destination_model.dart';

class ShareBottomSheet extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback? onShareSuccess;

  const ShareBottomSheet({
    super.key,
    required this.destination,
    this.onShareSuccess,
  });

  static Future<void> show(BuildContext context, DestinationModel destination, {VoidCallback? onShareSuccess}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareBottomSheet(
        destination: destination,
        onShareSuccess: onShareSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 32),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.share_with,
            style: GoogleFonts.beVietnamPro(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          // Social Media Icons Row
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSocialItem(
                  context,
                  icon: Brand(Brands.facebook_messenger),
                  label: 'Messenger',
                  onTap: () => _handleShare(context, 'Messenger'),
                ),
                _buildSocialItem(
                  context,
                  icon: Brand(Brands.facebook),
                  label: 'Facebook',
                  onTap: () => _handleShare(context, 'Facebook'),
                ),
                _buildSocialItem(
                  context,
                  icon: Brand(Brands.whatsapp),
                  label: 'WhatsApp',
                  onTap: () => _handleShare(context, 'WhatsApp'),
                ),
                _buildSocialItem(
                  context,
                  icon: Brand(Brands.instagram),
                  label: 'Instagram',
                  onTap: () => _handleShare(context, 'Instagram'),
                ),
                _buildSocialItem(
                  context,
                  icon: const Icon(Icons.sms, color: Colors.green, size: 32),
                  label: 'SMS',
                  onTap: () => _handleShare(context, 'SMS'),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 32),
          ),
          // Action Buttons Row
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildActionItem(
                  context,
                  icon: Icons.link_rounded,
                  label: l10n.copy,
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                      text: 'https://trekko.app/destination/${destination.id}',
                    ));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.link_copied),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    onShareSuccess?.call();
                  },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.flag_outlined,
                  label: l10n.report,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.thanks_feedback)),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.visibility_off_outlined,
                  label: l10n.not_interested,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialItem(BuildContext context, {required Widget icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 85,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 32, height: 32, child: icon),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 85,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.black87, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _handleShare(BuildContext context, String platform) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.sharing_via(destination.name, platform)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    onShareSuccess?.call();
  }
}

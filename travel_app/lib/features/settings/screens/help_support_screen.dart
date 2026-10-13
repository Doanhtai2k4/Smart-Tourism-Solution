import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@trekko.vn',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Yêu cầu hỗ trợ ứng dụng Trekko',
        'body': 'Xin chào Trekko,\n\nTôi cần hỗ trợ về...'
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      // Thông báo nếu không mở được
      print('Could not launch $emailLaunchUri');
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.help_support_title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(context.l10n.faq_title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _buildFAQTile(context.l10n.faq_1_q, context.l10n.faq_1_a),
            _buildFAQTile(context.l10n.faq_2_q, context.l10n.faq_2_a),
            _buildFAQTile(context.l10n.faq_3_q, context.l10n.faq_3_a),
            
            const SizedBox(height: 40),
            
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(Icons.support_agent_rounded, size: 48, color: cs.primary),
                  const SizedBox(height: 16),
                  Text(context.l10n.still_need_help, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.contact_support,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _sendEmail,
                      icon: const Icon(Icons.email_outlined),
                      label: Text(context.l10n.send_email),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(question, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(answer, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}

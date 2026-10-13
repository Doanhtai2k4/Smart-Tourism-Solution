import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/extensions/context_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.about_title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome_rounded, size: 80, color: cs.primary),
              ),
              const SizedBox(height: 24),
              
              Text(
                "Trekko",
                style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: cs.primary),
              ),
              Text(
                context.l10n.ai_travel_assistant,
                style: GoogleFonts.outfit(fontSize: 16, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.l10n.version,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 40),
              
              Text(
                context.l10n.developed_with_passion,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 15),
              ),
              
              const Spacer(),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => _showComingSoon(context),
                    child: Text(context.l10n.terms_conditions),
                  ),
                  const Text(" • "),
                  TextButton(
                    onPressed: () => _showComingSoon(context),
                    child: Text(context.l10n.privacy_policy),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "© 2024 Trekko Team. All rights reserved.",
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.loading_data)),
    );
  }
}

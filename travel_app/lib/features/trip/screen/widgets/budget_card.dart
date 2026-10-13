import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetCard extends StatelessWidget {
  final String budget;
  final String? budgetType;
  final String? destination;
  final DateTime? startDate;
  final DateTime? endDate;

  const BudgetCard({
    super.key,
    required this.budget,
    this.budgetType,
    this.destination,
    this.startDate,
    this.endDate,
  });

  String _formatBudget(String budgetStr) {
    // Remove formatting characters first to clean up the number string
    final cleanStr = budgetStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(cleanStr);
    if (value != null) {
      return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(value);
    }
    return budgetStr;
  }

  String _formatDates() {
    if (startDate == null || endDate == null) return 'N/A';
    final formatter = DateFormat('dd/MM/yy');
    return '${formatter.format(startDate!)} - ${formatter.format(endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    final formattedBudget = _formatBudget(budget);
    final isDaily = budgetType?.toLowerCase().contains('day') ?? false;
    final formattedDates = _formatDates();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1B4B), // Deep indigo
            Color(0xFF311042), // Deep violet
            Color(0xFF111827), // Deep slate gray
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF311042).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Abstract light circles for visual depth (Premium glassmorphic card design)
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                ),
              ),
            ),

            // Card details padding
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Chip, Logo, Contactless Wave
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Golden Chip
                      Container(
                        width: 48,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF59E0B), // Golden yellow
                              Color(0xFFD97706),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Inner grid lines of the chip
                            Positioned.fill(
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.3,
                                ),
                                itemCount: 9,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
                                        left: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
                                        bottom: BorderSide(color: Colors.black.withValues(alpha: 0.15), width: 0.5),
                                        right: BorderSide(color: Colors.black.withValues(alpha: 0.15), width: 0.5),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Center square
                            Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: const Color(0xFFFBBF24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Card Brand Logo
                      Row(
                        children: [
                          const Icon(
                            Icons.wifi_tethering_rounded,
                            color: Colors.white60,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'TRAVEL CARD',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Middle Row: Amount and Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDaily
                            ? 'DAILY BUDGET / NGÂN SÁCH MỖI NGÀY'
                            : 'TOTAL BUDGET / TỔNG NGÂN SÁCH CHUYẾN ĐI',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formattedBudget,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Bottom Row: Holder, Dates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Destination / Holder
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DESTINATION / ĐIỂM ĐẾN',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 8,
                                color: Colors.white38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (destination ?? 'UNKNOWN').toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Expiry / Date Range
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'VALID DATES / THỜI HẠN',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 8,
                              color: Colors.white38,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedDates,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

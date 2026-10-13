import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/features/expense/models/expense_model.dart';
import 'package:travel_app/features/expense/provider/expense_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/features/expense/screens/widgets/add_expense_bottom_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:travel_app/core/common/skeleton_loading.dart';
import 'package:travel_app/features/trip/provider/user_trips_provider.dart';

class ExpenseListScreen extends ConsumerWidget {
  final String tripId;
  const ExpenseListScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));
    final summary = ref.watch(expenseSummaryProvider(tripId));
    final tripAsync = ref.watch(tripByIdProvider(tripId));
    final colors = context.colors;
    final budget = _parseBudget(tripAsync.value?.budget);
    final total = summary['total'] ?? 0;

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, total, budget),
          SliverToBoxAdapter(
            child: _buildChartSection(context, summary),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Lịch sử chi tiêu",
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${expensesAsync.value?.length ?? 0} giao dịch",
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          expensesAsync.when(
            data: (expenses) => expenses.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: Text("Chưa có khoản chi nào")),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildExpenseItem(context, expenses[index], ref)
                            .animate(delay: (index * 50).ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.1),
                        childCount: expenses.length,
                      ),
                    ),
                  ),
            loading: () => const SliverToBoxAdapter(child: ListSkeleton()),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text("Lỗi: $err")),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseSheet(context, tripId),
        label: const Text("Thêm chi tiêu"),
        icon: const Icon(Icons.add),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, double total, double budget) {
    final colors = context.colors;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final hasBudget = budget > 0;
    final difference = budget - total;
    final progress = hasBudget ? (total / budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = hasBudget && total > budget;

    return SliverAppBar(
      expandedHeight: hasBudget ? 250 : 180,
      pinned: true,
      backgroundColor: colors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.primary.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                "Tổng chi phí",
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(total),
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasBudget) ...[
                const SizedBox(height: 8),
                Text(
                  isOverBudget
                      ? 'Vượt ngân sách ${currencyFormat.format(total - budget)}'
                      : 'Còn lại ${currencyFormat.format(difference)}',
                  style: GoogleFonts.beVietnamPro(
                    color: isOverBudget ? Colors.red.shade100 : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ngân sách ${currencyFormat.format(budget)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _parseBudget(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    final match = RegExp(r'\d[\d.,]*').firstMatch(value);
    if (match == null) return 0;
    final digitsOnly = match.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digitsOnly) ?? 0;
  }

  Widget _buildChartSection(BuildContext context, Map<String, double> summary) {
    if ((summary['total'] ?? 0) == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: _buildChartSections(context, summary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(context, summary),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(BuildContext context, Map<String, double> summary) {
    final total = summary['total'] ?? 1;
    final List<PieChartSectionData> sections = [];
    
    int index = 0;
    summary.forEach((key, value) {
      if (key == 'total' || value == 0) return;
      
      sections.add(PieChartSectionData(
        color: _getCategoryColor(index),
        value: value,
        title: '${(value / total * 100).toInt()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      index++;
    });
    
    return sections;
  }

  Widget _buildLegend(BuildContext context, Map<String, double> summary) {
    final List<Widget> items = [];
    int index = 0;
    
    summary.forEach((key, value) {
      if (key == 'total' || value == 0) return;
      items.add(_buildLegendItem(context, key, _getCategoryColor(index)));
      index++;
    });

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items,
    );
  }

  Widget _buildLegendItem(BuildContext context, String category, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(category, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildExpenseItem(BuildContext context, ExpenseModel expense, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getCategoryColorByEnum(expense.category).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getCategoryIcon(expense.category), color: _getCategoryColorByEnum(expense.category)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  "${expense.payerName} • ${DateFormat('dd/MM HH:mm').format(expense.date)}",
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(expense.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context, String tripId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddExpenseBottomSheet(tripId: tripId),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];
    return colors[index % colors.length];
  }

  Color _getCategoryColorByEnum(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return Colors.orange;
      case ExpenseCategory.transport: return Colors.blue;
      case ExpenseCategory.accommodation: return Colors.purple;
      case ExpenseCategory.shopping: return Colors.pink;
      case ExpenseCategory.entertainment: return Colors.green;
      case ExpenseCategory.other: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return Icons.restaurant;
      case ExpenseCategory.transport: return Icons.directions_bus;
      case ExpenseCategory.accommodation: return Icons.hotel;
      case ExpenseCategory.shopping: return Icons.shopping_bag;
      case ExpenseCategory.entertainment: return Icons.local_activity;
      case ExpenseCategory.other: return Icons.more_horiz;
    }
  }
}

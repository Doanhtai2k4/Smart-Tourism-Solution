import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import 'package:travel_app/features/expense/models/expense_model.dart';
import 'package:travel_app/features/expense/provider/expense_provider.dart';
import 'package:uuid/uuid.dart';

class AddExpenseBottomSheet extends ConsumerStatefulWidget {
  final String tripId;
  const AddExpenseBottomSheet({super.key, required this.tripId});

  @override
  ConsumerState<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends ConsumerState<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Thêm chi phí mới",
              style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Tên khoản chi",
                hintText: "Ví dụ: Ăn tối, Vé máy bay...",
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập tên" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số tiền (VNĐ)",
                border: OutlineInputBorder(),
                prefixText: "₫ ",
              ),
              validator: (val) => val == null || double.tryParse(val) == null ? "Số tiền không hợp lệ" : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExpenseCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: "Loại chi phí",
                border: OutlineInputBorder(),
              ),
              items: ExpenseCategory.values.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(_getCategoryName(cat)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Lưu chi phí"),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return "Ăn uống";
      case ExpenseCategory.transport: return "Di chuyển";
      case ExpenseCategory.accommodation: return "Chỗ ở";
      case ExpenseCategory.shopping: return "Mua sắm";
      case ExpenseCategory.entertainment: return "Giải trí";
      case ExpenseCategory.other: return "Khác";
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(userInfoProvider);
    if (user == null) return;

    final expense = ExpenseModel(
      id: const Uuid().v4(),
      tripId: widget.tripId,
      payerId: user.uid,
      payerName: user.name ?? "Người dùng",
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: DateTime.now(),
    );

    try {
      await ref.read(expenseActionsProvider).addExpense(expense);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }
}

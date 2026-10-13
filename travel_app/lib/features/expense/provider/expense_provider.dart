import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../repository/expense_repository.dart';

final tripExpensesProvider = StreamProvider.family<List<ExpenseModel>, String>((ref, tripId) {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchExpenses(tripId);
});

final expenseSummaryProvider = Provider.family<Map<String, double>, String>((ref, tripId) {
  final expenses = ref.watch(tripExpensesProvider(tripId)).value ?? [];
  
  double total = 0;
  Map<ExpenseCategory, double> categoryBreakdown = {};
  
  for (var expense in expenses) {
    total += expense.amount;
    categoryBreakdown[expense.category] = (categoryBreakdown[expense.category] ?? 0) + expense.amount;
  }
  
  return {
    'total': total,
    ...categoryBreakdown.map((key, value) => MapEntry(key.name, value)),
  };
});

final expenseActionsProvider = Provider((ref) => ExpenseActions(ref));

class ExpenseActions {
  final Ref _ref;
  ExpenseActions(this._ref);

  Future<void> addExpense(ExpenseModel expense) async {
    await _ref.read(expenseRepositoryProvider).addExpense(expense);
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {
    await _ref.read(expenseRepositoryProvider).deleteExpense(tripId, expenseId);
  }
}

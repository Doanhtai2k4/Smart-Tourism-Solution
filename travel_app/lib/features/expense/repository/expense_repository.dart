import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';

final expenseRepositoryProvider = Provider((ref) => ExpenseRepository());

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ExpenseModel>> watchExpenses(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();
    });
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore
        .collection('trips')
        .doc(expense.tripId)
        .collection('expenses')
        .add(expense.toJson());
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _firestore
        .collection('trips')
        .doc(expense.tripId)
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toJson());
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {
    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }
}

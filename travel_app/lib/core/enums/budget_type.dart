import 'package:flutter/material.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';

enum BudgetType { total, perDay }

extension BudgetTypeExtension on BudgetType {
  String label(BuildContext context) {
    switch (this) {
      case BudgetType.total:
        return context.l10n.budget_total;
      case BudgetType.perDay:
        return context.l10n.budget_per_day;
    }
  }

  String get payload {
    switch (this) {
      case BudgetType.total:
        return 'total';
      case BudgetType.perDay:
        return 'per_day';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/features/addtrip/screens/widgets/selectable_chip.dart';
import 'package:travel_app/features/addtrip/screens/widgets/step_title.dart';

import '../../../../core/enums/budget_type.dart';
import 'budget_field.dart';
import 'date_field.dart';
import 'duration_chip.dart';
import 'input_label.dart';

class DateBudgetStep extends StatelessWidget {
  const DateBudgetStep({
    super.key,
    required this.startDateController,
    required this.endDateController,
    required this.budgetController,
    required this.startDate,
    required this.endDate,
    required this.selectedBudgetType,
    required this.onBudgetTypeChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController budgetController;
  final DateTime? startDate;
  final DateTime? endDate;
  final BudgetType selectedBudgetType;
  final ValueChanged<BudgetType> onBudgetTypeChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(
            icon: Icons.calendar_today_outlined,
            title: context.l10n.whenHowMuch,
            subtitle: context.l10n.whenHowMuchDescription,
          ),
          const SizedBox(height: 32),

          InputLabel(text: context.l10n.travelDates),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DateField(
                  controller: startDateController,
                  hintText: context.l10n.startDate,
                  onTap: () => _selectStartDate(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward,
                  color: iconColor?.withAlpha(128),
                ),
              ),
              Expanded(
                child: DateField(
                  controller: endDateController,
                  hintText: context.l10n.endDate,
                  onTap: () => _selectEndDate(context),
                ),
              ),
            ],
          ),

          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 12),
            DurationChip(days: endDate!.difference(startDate!).inDays + 1),
          ],

          const SizedBox(height: 32),

          InputLabel(text: context.l10n.budget),
          const SizedBox(height: 8),
          BudgetField(
            controller: budgetController,
          ),

          const SizedBox(height: 16),

          InputLabel(text: context.l10n.budgetType),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                BudgetType.values.map((type) {
                  return SelectableChip(
                    label: type.label(context),
                    icon:
                        type == BudgetType.total
                            ? Icons.account_balance_wallet_outlined
                            : Icons.person_outline,
                    isSelected: selectedBudgetType == type,
                    onTap: () => onBudgetTypeChanged(type),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (date != null) {
      onStartDateChanged(date);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseSelectStartDate)),
      );
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate!.add(const Duration(days: 1)),
      firstDate: startDate!,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (date != null) {
      onEndDateChanged(date);
    }
  }
}

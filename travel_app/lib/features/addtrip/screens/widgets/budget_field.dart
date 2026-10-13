import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_theme.dart';
import '../../../../core/utils.dart';

class BudgetField extends StatelessWidget {
  final TextEditingController controller;

  const BudgetField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final textTheme = context.text;
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        NumberInputFormatter(),
      ],
      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: cs.onSurface.withAlpha(102),
        ),
        prefixIcon: isVi
            ? null
            : Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  '\$',
                  style: textTheme.titleMedium?.copyWith(
                    color: cs.onSurface.withAlpha(153),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        suffixText: isVi ? 'VNĐ' : null,
        suffixStyle: isVi
            ? textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withAlpha(153),
                fontWeight: FontWeight.bold,
              )
            : null,
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

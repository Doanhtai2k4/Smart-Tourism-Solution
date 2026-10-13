import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onTap;

  const DateField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: theme.textTheme.bodyMedium,

      decoration: InputDecoration(
        hintText: hintText,

        suffixIcon: Icon(
          Icons.calendar_today_outlined,
          size: 20,
          color: theme.iconTheme.color,
        ),
      ),
    );
  }
}

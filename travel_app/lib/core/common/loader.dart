import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool withScaffold;
  final String? title;
  final VoidCallback? onBack;

  const Loader({
    super.key,
    this.withScaffold = false,
    this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = const Center(
      child: CircularProgressIndicator(),
    );

    if (!withScaffold) {
      return indicator;
    }

    return Scaffold(
      appBar: AppBar(
        leading: onBack != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: onBack,
        )
            : null,
        title: title != null ? Text(title!) : null,
      ),
      body: indicator,
    );
  }
}

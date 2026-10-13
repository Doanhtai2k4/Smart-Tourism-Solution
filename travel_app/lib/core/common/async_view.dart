import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_error_state.dart';
import 'empty_state.dart';
import 'loader.dart';

class AsyncView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final bool Function(T data)? isEmpty;

  const AsyncView({
    super.key,
    required this.value,
    required this.builder,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Loader(),
      error: (e, _) => AppErrorState(message: e.toString()),
      data: (data) {
        if (isEmpty != null && isEmpty!(data)) {
          return const EmptyState(
            icon: Icons.hourglass_empty,
            title: "Không có dữ liệu",
          );
        }
        return builder(data);
      },
    );
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/currency_service.dart';

part 'currency_provider.g.dart';

@riverpod
Future<Map<String, String>> currencies(Ref ref) async {
  return ref.watch(currencyServiceProvider).getCurrencies();
}

@riverpod
Future<double> conversion(Ref ref, {
  required String from,
  required String to,
  required double amount,
}) async {
  if (amount == 0) return 0;
  return ref.watch(currencyServiceProvider).convert(from, to, amount);
}

class CurrencyState {
  final String from;
  final String to;
  final double amount;

  CurrencyState({this.from = 'USD', this.to = 'VND', this.amount = 1.0});

  CurrencyState copyWith({String? from, String? to, double? amount}) {
    return CurrencyState(
      from: from ?? this.from,
      to: to ?? this.to,
      amount: amount ?? this.amount,
    );
  }
}

@riverpod
class CurrencyStateNotifier extends _$CurrencyStateNotifier {
  @override
  CurrencyState build() {
    return CurrencyState();
  }

  void updateFrom(String from) => state = state.copyWith(from: from);
  void updateTo(String to) => state = state.copyWith(to: to);
  void updateAmount(double amount) => state = state.copyWith(amount: amount);
  void swap() => state = state.copyWith(from: state.to, to: state.from);
}

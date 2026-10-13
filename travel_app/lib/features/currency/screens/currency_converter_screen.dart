import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_theme.dart';
import '../providers/currency_provider.dart';

class CurrencyConverterScreen extends ConsumerStatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  ConsumerState<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends ConsumerState<CurrencyConverterScreen> {
  final _amountController = TextEditingController(text: '1');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyStateProvider);
    final currenciesAsync = ref.watch(currenciesProvider);
    final resultAsync = ref.watch(conversionProvider(
      from: state.from,
      to: state.to,
      amount: state.amount,
    ));

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(
          "Chuyển đổi tiền tệ",
          style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInputSection(context, state),
            const SizedBox(height: 24),
            _buildSwapButton(context),
            const SizedBox(height: 24),
            _buildOutputSection(context, state, resultAsync),
            const SizedBox(height: 48),
            _buildCurrencySelectors(context, state, currenciesAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, CurrencyState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Số tiền từ ${state.from}",
            style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.beVietnamPro(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0.00',
            ),
            onChanged: (val) {
              final amount = double.tryParse(val) ?? 0;
              ref.read(currencyStateProvider.notifier).updateAmount(amount);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton(BuildContext context) {
    return GestureDetector(
      onTap: () => ref.read(currencyStateProvider.notifier).swap(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.swap_vert, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildOutputSection(BuildContext context, CurrencyState state, AsyncValue<double> resultAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kết quả sang ${state.to}",
            style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          resultAsync.when(
            data: (result) => Text(
              result.toStringAsFixed(2),
              style: GoogleFonts.beVietnamPro(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (err, _) => Text("Lỗi", style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelectors(BuildContext context, CurrencyState state, AsyncValue<Map<String, String>> currenciesAsync) {
    return currenciesAsync.when(
      data: (currencies) => Row(
        children: [
          Expanded(
            child: _buildSelector(
              context, 
              "Từ", 
              state.from, 
              currencies, 
              (val) => ref.read(currencyStateProvider.notifier).updateFrom(val!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSelector(
              context, 
              "Sang", 
              state.to, 
              currencies, 
              (val) => ref.read(currencyStateProvider.notifier).updateTo(val!),
            ),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSelector(BuildContext context, String label, String value, Map<String, String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.bodySmall),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: items.containsKey(value) ? value : items.keys.first,
              items: items.entries.map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

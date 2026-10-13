import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currencyServiceProvider = Provider((ref) => CurrencyService());

const Map<String, String> _currencyNames = {
  'USD': 'United States Dollar',
  'EUR': 'Euro',
  'VND': 'Vietnamese Dong',
  'JPY': 'Japanese Yen',
  'GBP': 'British Pound Sterling',
  'AUD': 'Australian Dollar',
  'CAD': 'Canadian Dollar',
  'CHF': 'Swiss Franc',
  'CNY': 'Chinese Yuan',
  'SEK': 'Swedish Krona',
  'NZD': 'New Zealand Dollar',
  'KRW': 'South Korean Won',
  'SGD': 'Singapore Dollar',
  'NOK': 'Norwegian Krone',
  'MXN': 'Mexican Peso',
  'INR': 'Indian Rupee',
  'RUB': 'Russian Ruble',
  'ZAR': 'South African Rand',
  'TRY': 'Turkish Lira',
  'BRL': 'Brazilian Real',
  'TWD': 'New Taiwan Dollar',
  'DKK': 'Danish Krone',
  'PLN': 'Polish Zloty',
  'THB': 'Thai Baht',
  'IDR': 'Indonesian Rupiah',
  'HUF': 'Hungarian Forint',
  'CZK': 'Czech Koruna',
  'ILS': 'Israeli New Shekel',
  'CLP': 'Chilean Peso',
  'PHP': 'Philippine Peso',
  'AED': 'United Arab Emirates Dirham',
  'COP': 'Colombian Peso',
  'SAR': 'Saudi Riyal',
  'MYR': 'Malaysian Ringgit',
  'RON': 'Romanian Leu',
};

class CurrencyService {
  final _dio = Dio(BaseOptions(
    baseUrl: 'https://open.er-api.com/v6/latest',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, dynamic>> getLatestRates(String base) async {
    try {
      final response = await _dio.get('/$base');
      return response.data['rates'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Không thể lấy tỷ giá: $e');
    }
  }

  Future<double> convert(String from, String to, double amount) async {
    if (from == to) return amount;
    try {
      final response = await _dio.get('/$from');
      final rates = response.data['rates'] as Map<String, dynamic>;
      final rate = (rates[to] as num).toDouble();
      return amount * rate;
    } catch (e) {
      throw Exception('Lỗi chuyển đổi: $e');
    }
  }

  Future<Map<String, String>> getCurrencies() async {
    try {
      final response = await _dio.get('/USD');
      final rates = response.data['rates'] as Map<String, dynamic>;
      final sortedCodes = rates.keys.toList()..sort();
      final Map<String, String> currencies = {};
      for (final code in sortedCodes) {
        currencies[code] = _currencyNames[code] ?? code;
      }
      return currencies;
    } catch (e) {
      throw Exception('Không thể lấy danh sách tiền tệ: $e');
    }
  }
}


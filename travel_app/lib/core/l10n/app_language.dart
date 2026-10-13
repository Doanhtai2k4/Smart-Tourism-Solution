import 'dart:ui';

class AppLanguage {
  final String label;
  final String flag;
  final Locale locale;

  const AppLanguage({
    required this.label,
    required this.flag,
    required this.locale,
  });
}

const supportedLanguages = [
  AppLanguage(
    label: 'Tiếng Việt',
    flag: '🇻🇳',
    locale: Locale('vi'),
  ),
  AppLanguage(
    label: 'English',
    flag: '🇺🇸',
    locale: Locale('en'),
  ),
];
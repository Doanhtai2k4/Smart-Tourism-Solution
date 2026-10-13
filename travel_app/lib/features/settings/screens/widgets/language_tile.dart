import 'package:flutter/material.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';

import '../../../../core/extensions/context_theme.dart';
import '../../../../core/l10n/app_language.dart';

class LanguageSelectorTile extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLanguageSelected;

  const LanguageSelectorTile({
    super.key,
    required this.currentLocale,
    required this.onLanguageSelected,
  });

  AppLanguage get _currentLanguage => supportedLanguages.firstWhere(
    (l) => l.locale.languageCode == currentLocale.languageCode,
    orElse: () => supportedLanguages.first,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLanguageBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.language_rounded,
                  color: colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.language,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.languageDescription,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurface.withAlpha(178),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    _currentLanguage.label,
                    style: text.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colors.onSurface.withAlpha(102),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------

  void _showLanguageBottomSheet(BuildContext context) {
    final colors = context.colors;
    final text = context.text;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.withAlpha(51),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        context.l10n.selectLanguage,
                        style: text.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: supportedLanguages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final lang = supportedLanguages[index];
                      final isSelected =
                          lang.locale.languageCode ==
                          currentLocale.languageCode;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onLanguageSelected(lang.locale);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? colors.primary.withAlpha(20)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? colors.primary.withAlpha(76)
                                        : colors.onSurface.withAlpha(31),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  lang.flag,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    lang.label,
                                    style: text.titleMedium?.copyWith(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                      color:
                                          isSelected
                                              ? colors.primary
                                              : colors.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: colors.onPrimary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }
}

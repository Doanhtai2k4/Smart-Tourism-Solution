import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/common/async_view.dart';
import 'package:travel_app/features/settings/provider/settings_provider.dart';
import 'package:travel_app/l10n/app_localizations.dart';

import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';
import 'firebase_options.dart';
import 'package:travel_app/core/services/ml_recommendation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'admin/screens/admin_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );



  // Force re-auth on cold start by clearing any persisted Firebase Auth session.
  await FirebaseAuth.instance.signOut();

  // Initialize ML Recommendation Service
  final container = ProviderContainer();
  final mlService = container.read(mlServiceProvider);
  await mlService.init();
  // Fire-and-forget background warm-up for Render server
  unawaited(mlService.warmUp());

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return MaterialApp(
        title: 'Trekko Admin',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        supportedLocales: const [Locale('vi'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('vi'),
        home: const AdminMainScreen(),
      );
    }

    final themeAsync = ref.watch(themeModeProvider);
    final localeAsync = ref.watch(languageProvider);
    final router = ref.watch(routerProvider);

    return AsyncView<Locale>(
      value: localeAsync,
      builder: (locale) {
        return AsyncView<ThemeMode>(
          value: themeAsync,
          builder: (themeMode) {
            return MaterialApp.router(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              routerConfig: router,
              supportedLocales: const [Locale('vi'), Locale('en')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
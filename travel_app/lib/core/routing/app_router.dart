import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/core/routing/route_builder.dart';

import '../../features/auth/provider/auth_providers.dart';
import '../../features/auth/provider/onboarding_provider.dart';
import 'app_redirect.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<bool>(false);

  ref.listen(userInfoProvider, (_, _) {
    refreshNotifier.value = !refreshNotifier.value;
  });

  ref.listen(onboardingProvider, (_, _) {
    refreshNotifier.value = !refreshNotifier.value;
  });

  final initialLocation =
      ref.read(firebaseAuthProvider).currentUser != null
          ? AppRoutes.home
          : AppRoutes.login;

  return GoRouter(
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: initialLocation,
    refreshListenable: refreshNotifier,
    routes: RouteBuilders.buildRoutes(),
    redirect: (context, state) => AppRedirect.handle(ref, state),
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(child: Text('Không tìm thấy trang: ${state.uri}')),
      );
    },
  );
});

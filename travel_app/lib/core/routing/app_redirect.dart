import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/provider/auth_providers.dart';
import '../../features/auth/provider/onboarding_provider.dart';
import 'app_routes.dart';

class AppRedirect {
  static String? handle(Ref ref, GoRouterState state) {
    final user = ref.read(userInfoProvider);
    final firebaseUser = ref.read(firebaseAuthProvider).currentUser;
    final isFirstTime = ref.read(onboardingProvider).asData?.value ?? true;
    final currentPath = state.uri.path;

    debugPrint('AppRedirect: path=$currentPath, fbUser=${firebaseUser?.uid}, isFirstTime=$isFirstTime');

    // 1. Force onboarding for first-time users
    if (isFirstTime && currentPath != AppRoutes.onboarding) {
      debugPrint('AppRedirect: First time user, redirecting to onboarding');
      return AppRoutes.onboarding;
    }

    // 2. If onboarding is done but user is still on onboarding page, move to login/home
    if (!isFirstTime && currentPath == AppRoutes.onboarding) {
      debugPrint('AppRedirect: Onboarding done, moving to auth/home');
      return firebaseUser != null ? AppRoutes.home : AppRoutes.login;
    }

    final isPublicRoute = {
      AppRoutes.login,
      AppRoutes.onboarding,
      AppRoutes.signIn,
      AppRoutes.signUp,
      AppRoutes.completeProfile,
    }.contains(currentPath);

    if (firebaseUser != null && user == null) {
      debugPrint('AppRedirect: Logged in to Firebase but userInfo null, allowing current path');
      return null;
    }

    if (user == null && currentPath == AppRoutes.signIn) {
      return AppRoutes.login;
    }

    if (user == null && !isPublicRoute) {
      debugPrint('AppRedirect: user null and private route, redirect to login');
      return AppRoutes.login;
    }

    // Logic for authenticated users
    if (user != null) {
      final isProfileIncomplete = user.dateOfBirth == null;
      
      if (isProfileIncomplete) {
        debugPrint('AppRedirect: Profile incomplete, isProfileIncomplete=$isProfileIncomplete');
        // If profile is incomplete, force them to stay on /complete-profile
        if (currentPath != AppRoutes.completeProfile) {
          debugPrint('AppRedirect: Redirecting to complete profile');
          return AppRoutes.completeProfile;
        }
        return null;
      }

      // If profile is complete and they just completed it, route to onboarding preferences
      if (currentPath == AppRoutes.completeProfile && !isProfileIncomplete) {
        debugPrint('AppRedirect: Profile complete, redirecting to onboarding preferences');
        return AppRoutes.onboardingPreferences;
      }

      // If profile is complete, don't allow them back to public/auth pages
      if (isPublicRoute) {
        debugPrint('AppRedirect: Profile complete, but on public page, redirecting home');
        return AppRoutes.home;
      }
    }

    debugPrint('AppRedirect: No redirect needed, allowing current path: $currentPath');
    return null;
  }
}

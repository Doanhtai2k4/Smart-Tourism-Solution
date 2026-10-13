import 'package:go_router/go_router.dart';

import '../../features/addtrip/screens/add_trip_page.dart';
import '../../features/auth/screens/complete_profile_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/signin_page.dart';
import '../../features/auth/screens/signup_page.dart';
import '../../features/auth/screens/onboarding_preferences_screen.dart';
import '../../features/discovery/screens/discovery_detail_page.dart';
import '../../features/discovery/screens/discovery_page.dart';
import '../../features/history/screen/trip_history.dart';
import '../../features/search/screens/search_page.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/profile_screen.dart';
import '../../features/settings/screens/notification_settings_screen.dart';
import '../../features/settings/screens/privacy_security_screen.dart';
import '../../features/settings/screens/help_support_screen.dart';
import '../../features/settings/screens/about_screen.dart';
import '../../features/trip/screen/home_page.dart';
import '../../features/notifications/screens/notification_screen.dart';


import '../../features/trip/screen/trip_detail_page.dart';
import '../../features/trip/screen/group_trips_page.dart';
import '../../features/chat/screen/chat_page.dart';
import '../../features/expense/screens/expense_list_screen.dart';
import '../../features/currency/screens/currency_converter_screen.dart';
import '../../features/vault/screens/document_list_screen.dart';
import '../../features/emergency/screens/emergency_info_screen.dart';
import '../../shared/models/destination_model.dart';
import '../../shared/models/travel_db_model.dart';
import '../navigation/app_scaffold.dart';
import 'app_routes.dart';

class RouteBuilders {
  static List<RouteBase> buildRoutes() {
    return [
      GoRoute(
        path: AppRoutes.onboarding,
        name: RouteNames.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: RouteNames.signIn,
        builder: (_, _) => SigninPage(),
      ),
      GoRoute(
        // Alias path for forced-login requirement.
        path: AppRoutes.login,
        name: RouteNames.login,
        builder: (_, _) => const SigninPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: RouteNames.signUp,
        builder: (_, _) => SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        name: RouteNames.completeProfile,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          final password = extra?['password'] as String? ?? '';
          return CompleteProfileScreen(email: email, password: password);
        },
      ),
      GoRoute(
        path: AppRoutes.onboardingPreferences,
        name: RouteNames.onboardingPreferences,
        builder: (_, _) => const OnboardingPreferencesScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.home,
            name: RouteNames.home,
            builder: (_, _) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.exploration,
            name: RouteNames.exploration,
            builder: (_, _) => const DiscoveryPage(),
          ),
          GoRoute(
            path: AppRoutes.history,
            name: RouteNames.history,
            builder: (_, _) => const TripHistory(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: RouteNames.settings,
            builder: (_, _) => const SettingsScreen(),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.planTrip,
        name: RouteNames.planTrip,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is String) {
            return AddTripPage(initialDestination: extra);
          } else if (extra is TravelDbModel) {
            return AddTripPage(existingTrip: extra);
          }
          return const AddTripPage();
        },
      ),
      GoRoute(
        path: AppRoutes.vault,
        name: RouteNames.vault,
        builder: (context, state) {
          final travelId = state.pathParameters['travelId']!;
          return DocumentListScreen(tripId: travelId);
        },
      ),
      GoRoute(
        path: AppRoutes.emergency,
        name: RouteNames.emergency,
        builder: (context, state) {
          final travelId = state.pathParameters['travelId']!;
          return EmergencyInfoScreen(tripId: travelId);
        },
      ),
      GoRoute(
        path: AppRoutes.tripDetail,
        name: RouteNames.trip,
        builder: (_, state) {
          final travelId = state.pathParameters['travelId']!;
          return TripDetailPage(travelId: travelId);
        },
      ),
      GoRoute(
        path: AppRoutes.tripChat,
        name: RouteNames.tripChat,
        builder: (_, state) {
          // We must pass a TravelDbModel to ChatPage, which we will fetch inside it
          // or pass as an extra. Let's pass it as an extra since we have it open.
          final trip = state.extra as TravelDbModel;
          return ChatPage(trip: trip);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        name: RouteNames.search,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final query = extra?['query'] as String?;
          return SearchPage(initialQuery: query);
        },
      ),
      GoRoute(
        path: AppRoutes.groupTrips,
        name: RouteNames.groupTrips,
        builder: (_, _) => const GroupTripsPage(),
      ),
      GoRoute(
        path: AppRoutes.discoveryDetail,
        name: RouteNames.discoveryDetail,
        builder: (context, state) {
          final destination = state.extra as DestinationModel;
          return DiscoveryDetailPage(destination: destination);
        },
      ),
      GoRoute(
        path: AppRoutes.expenses,
        name: RouteNames.expenses,
        builder: (context, state) {
          final travelId = state.pathParameters['travelId']!;
          return ExpenseListScreen(tripId: travelId);
        },
      ),
      GoRoute(
        path: AppRoutes.currencyConverter,
        name: RouteNames.currencyConverter,
        builder: (_, _) => const CurrencyConverterScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: RouteNames.profile,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        name: RouteNames.notificationSettings,
        builder: (_, _) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacySecurity,
        name: RouteNames.privacySecurity,
        builder: (_, _) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        name: RouteNames.helpSupport,
        builder: (_, _) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: RouteNames.about,
        builder: (_, _) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: RouteNames.notifications,
        builder: (_, _) => const NotificationScreen(),
      ),
    ];


  }
}

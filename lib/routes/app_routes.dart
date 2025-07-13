import 'package:flutter/material.dart';

import '../presentation/achievements_screen/achievements_screen.dart';
import '../presentation/chat_messages_screen/chat_messages_screen.dart';
import '../presentation/community_groups_screen/community_groups_screen.dart';
import '../presentation/direct_messages_screen/direct_messages_screen.dart';
import '../presentation/enhanced_interactive_map_screen/enhanced_interactive_map_screen.dart';
import '../presentation/events_screen/events_screen.dart';
import '../presentation/gps_tracking_screen/gps_tracking_screen.dart';
import '../presentation/interactive_map_screen/interactive_map_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/main_dashboard/main_dashboard.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/rest_points_screen/rest_points_screen.dart';
import '../presentation/route_history_screen/route_history_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  static const String registrationScreen = '/registration-screen';
  static const String mainDashboard = '/main-dashboard';
  static const String achievementsScreen = '/achievements-screen';
  static const String chatMessagesScreen = '/chat-messages-screen';
  static const String communityGroupsScreen = '/community-groups-screen';
  static const String directMessagesScreen = '/direct-messages-screen';
  static const String enhancedInteractiveMapScreen =
      '/enhanced-interactive-map-screen';
  static const String eventsScreen = '/events-screen';
  static const String gpsTrackingScreen = '/gps-tracking-screen';
  static const String interactiveMapScreen = '/interactive-map-screen';
  static const String optimizedBottomNavigationBar =
      '/optimized-bottom-navigation-bar';
  static const String profileScreen = '/profile-screen';
  static const String restPointsScreen = '/rest-points-screen';
  static const String routeHistoryScreen = '/route-history-screen';

  static Map<String, WidgetBuilder> get routes {
    return {
      splashScreen: (context) => const SplashScreen(),
      loginScreen: (context) => const LoginScreen(),
      registrationScreen: (context) => const RegistrationScreen(),
      mainDashboard: (context) => const MainDashboard(),
      achievementsScreen: (context) => const AchievementsScreen(),
      chatMessagesScreen: (context) => const ChatMessagesScreen(),
      communityGroupsScreen: (context) => const CommunityGroupsScreen(),
      directMessagesScreen: (context) => const DirectMessagesScreen(),
      enhancedInteractiveMapScreen: (context) =>
          const EnhancedInteractiveMapScreen(),
      eventsScreen: (context) => const EventsScreen(),
      gpsTrackingScreen: (context) => const GpsTrackingScreen(),
      interactiveMapScreen: (context) => const InteractiveMapScreen(),
      profileScreen: (context) => const ProfileScreen(),
      restPointsScreen: (context) => const RestPointsScreen(),
      routeHistoryScreen: (context) => const RouteHistoryScreen(),
    };
  }
}

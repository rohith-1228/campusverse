import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/demo_login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/organizer/organizer_dashboard_screen.dart';
import 'screens/splash/splash_screen.dart';

class CampusVerseApp extends StatelessWidget {
  const CampusVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const DemoLoginScreen(),
        '/home': (context) => const MainShell(initialIndex: 0),
        '/explore': (context) => const MainShell(initialIndex: 1),
        '/my-events': (context) => const MainShell(initialIndex: 2),
        '/profile': (context) => const MainShell(initialIndex: 3),
        '/notifications': (context) => const NotificationsScreen(),
        '/organizer': (context) => const OrganizerDashboardScreen(),
      },
    );
  }
}

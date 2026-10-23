import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusverse/app.dart';
import 'package:campusverse/core/constants/app_constants.dart';
import 'package:campusverse/models/student.dart';
import 'package:campusverse/providers/bookmark_provider.dart';
import 'package:campusverse/providers/event_provider.dart';
import 'package:campusverse/providers/notification_provider.dart';
import 'package:campusverse/providers/profile_provider.dart';
import 'package:campusverse/providers/registration_provider.dart';
import 'package:campusverse/providers/theme_provider.dart';
import 'package:campusverse/repositories/event_repository.dart';
import 'package:campusverse/repositories/registration_repository.dart';
import 'package:campusverse/services/api_service.dart';
import 'package:campusverse/services/local_storage_service.dart';
import 'package:campusverse/widgets/custom_bottom_navigation.dart';
import 'test_helpers/mock_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('CampusVerseApp boots up, displays branding and navigates correctly',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);

    // Save default demo student
    await storageService.saveStudent(Student.defaultDemoStudent);

    final apiService = ApiService();
    final eventRepo = EventRepository(
      apiService: apiService,
      storageService: storageService,
    );
    final regRepo = RegistrationRepository(storageService);

    // Standard test viewport
    await tester.binding.setSurfaceSize(const Size(800, 1200));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
          ChangeNotifierProvider(create: (_) => ProfileProvider(storageService)),
          ChangeNotifierProvider(
            create: (_) => EventProvider(
              repository: eventRepo,
              apiService: apiService,
              storageService: storageService,
            ),
          ),
          ChangeNotifierProvider(create: (_) => RegistrationProvider(regRepo)),
          ChangeNotifierProvider(create: (_) => BookmarkProvider(storageService)),
          ChangeNotifierProvider(create: (_) => NotificationProvider(storageService)),
        ],
        child: const CampusVerseApp(),
      ),
    );

    // Initial splash frame branding verification
    await tester.pump();
    expect(find.text(AppConstants.appTagline), findsOneWidget);

    // Settle timer navigation from splash to main shell
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    // Verify Discover tab is active by default
    expect(find.text('Discover'), findsOneWidget);

    // Tap Explore tab icon on bottom navigation bar
    final exploreNavTab = find.descendant(
      of: find.byType(CustomBottomNavigation),
      matching: find.byIcon(Icons.search_rounded),
    );
    expect(exploreNavTab, findsOneWidget);
    await tester.tap(exploreNavTab);
    await tester.pumpAndSettle();

    // Verify Explore screen and tab is now active
    expect(find.text('Explore Events'), findsOneWidget);
  });
}

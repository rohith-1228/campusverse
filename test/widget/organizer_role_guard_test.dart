import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusverse/providers/bookmark_provider.dart';
import 'package:campusverse/providers/event_provider.dart';
import 'package:campusverse/providers/notification_provider.dart';
import 'package:campusverse/providers/profile_provider.dart';
import 'package:campusverse/providers/registration_provider.dart';
import 'package:campusverse/repositories/event_repository.dart';
import 'package:campusverse/repositories/registration_repository.dart';
import 'package:campusverse/screens/organizer/organizer_dashboard_screen.dart';
import 'package:campusverse/screens/organizer/ticket_scanner_screen.dart';
import 'package:campusverse/services/api_service.dart';
import 'package:campusverse/services/local_storage_service.dart';
import '../test_helpers/mock_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  group('Organizer Role Guard and Navigation Tests', () {
    late LocalStorageService storageService;
    late ProfileProvider profileProvider;
    late EventProvider eventProvider;
    late RegistrationProvider regProvider;

    Future<Widget> buildTestApp({required Widget homeWidget}) async {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profileProvider),
          ChangeNotifierProvider.value(value: eventProvider),
          ChangeNotifierProvider.value(value: regProvider),
          ChangeNotifierProvider(create: (_) => BookmarkProvider(storageService)),
          ChangeNotifierProvider(create: (_) => NotificationProvider(storageService)),
        ],
        child: MaterialApp(
          home: homeWidget,
        ),
      );
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = LocalStorageService(prefs);
      profileProvider = ProfileProvider(storageService);

      final apiService = ApiService();
      final eventRepo = EventRepository(apiService: apiService, storageService: storageService);
      eventProvider = EventProvider(
        repository: eventRepo,
        apiService: apiService,
        storageService: storageService,
      );

      final regRepo = RegistrationRepository(storageService);
      regProvider = RegistrationProvider(regRepo);
    });

    testWidgets('denies student account and renders Access Restricted screen',
        (WidgetTester tester) async {
      // Ensure user role is student
      await storageService.saveUserRole('student');

      final app = await buildTestApp(
        homeWidget: const OrganizerDashboardScreen(),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Organizer Privilege Required'), findsOneWidget);
      expect(
        find.textContaining('Student accounts cannot create, edit, or delete campus events'),
        findsOneWidget,
      );
      expect(find.text('Go to Organizer Login'), findsOneWidget);
      expect(find.byIcon(Icons.gpp_bad_rounded), findsOneWidget);

      // Verify that administrative event management actions are NOT rendered
      expect(find.text('Open QR Gate Scanner'), findsNothing);
      expect(find.text('Create Event'), findsNothing);
    });

    testWidgets('allows organizer and renders administrative dashboard and stat cards',
        (WidgetTester tester) async {
      // Authenticate as organizer
      await profileProvider.loginOrganizerDemo();

      final app = await buildTestApp(
        homeWidget: const OrganizerDashboardScreen(),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.text('Organizer Dashboard'), findsOneWidget);
      expect(find.textContaining('CampusVerse Admin'), findsOneWidget);
      expect(find.text('Total Events'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Signups'), findsOneWidget);
      expect(find.text('Checked In'), findsOneWidget);
      expect(find.text('Open QR Gate Scanner'), findsOneWidget);
      expect(find.text('Create Event'), findsOneWidget);
      expect(find.textContaining('Managed Campus Events'), findsOneWidget);
    });

    testWidgets('denies student account access to TicketScannerScreen',
        (WidgetTester tester) async {
      // Ensure user role is student
      await storageService.saveUserRole('student');

      final app = await buildTestApp(
        homeWidget: const TicketScannerScreen(),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Organizer Privilege Required'), findsOneWidget);
      expect(
        find.textContaining('Student accounts cannot scan QR tickets or authorize gate admission'),
        findsOneWidget,
      );
      expect(find.text('Go to Organizer Login'), findsOneWidget);

      // Verify that scanner and manual lookup tabs are NOT rendered
      expect(find.text('Manual / Demo'), findsNothing);
      expect(find.text('Live Camera'), findsNothing);
    });

    testWidgets('ticket scanner manual lookup rejects non-existent ticket for organizer',
        (WidgetTester tester) async {
      await profileProvider.loginOrganizerDemo();

      final app = await buildTestApp(
        homeWidget: const TicketScannerScreen(),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Switch to the Manual / Demo Tab
      final manualTab = find.text('Manual / Demo');
      expect(manualTab, findsOneWidget);
      await tester.tap(manualTab);
      await tester.pumpAndSettle();

      expect(find.text('Enter Admission Ticket ID'), findsOneWidget);

      // Enter an invalid ticket code
      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);
      await tester.enterText(inputField, 'CAMPUSVERSE:TICKET:CV-FAKE-000');
      await tester.pumpAndSettle();

      // Tap Verify button
      final verifyButton = find.text('Verify');
      expect(verifyButton, findsOneWidget);
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // Expect Unrecognized Ticket warning badge
      expect(find.text('UNRECOGNIZED TICKET'), findsOneWidget);
      expect(find.textContaining('No registration record found'), findsOneWidget);
    });
  });
}

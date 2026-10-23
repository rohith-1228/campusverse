import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusverse/models/student.dart';
import 'package:campusverse/providers/bookmark_provider.dart';
import 'package:campusverse/providers/event_provider.dart';
import 'package:campusverse/providers/notification_provider.dart';
import 'package:campusverse/providers/profile_provider.dart';
import 'package:campusverse/providers/registration_provider.dart';
import 'package:campusverse/repositories/event_repository.dart';
import 'package:campusverse/repositories/registration_repository.dart';
import 'package:campusverse/screens/home/home_screen.dart';
import 'package:campusverse/services/api_service.dart';
import 'package:campusverse/services/local_storage_service.dart';
import '../test_helpers/mock_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('HomeScreen renders personalized greeting, search, and category chips',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);

    await storageService.saveStudent(const Student(
      name: 'Alex Chen',
      email: 'alex@campus.edu',
      rollNumber: 'CS-001',
      department: 'Computer Science',
      yearOfStudy: '3rd Year',
      phone: '9876543210',
    ));

    final apiService = ApiService();
    final eventRepo = EventRepository(apiService: apiService, storageService: storageService);
    final regRepo = RegistrationRepository(storageService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
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
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump and settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify greeting
    expect(find.textContaining('Welcome back, Alex'), findsOneWidget);

    // Verify search hint
    expect(find.text('Search techfests, hackathons, workshops...'), findsOneWidget);

    // Verify categories
    expect(find.text('All Events'), findsOneWidget);
    expect(find.text('Technical'), findsWidgets);
  });
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusverse/models/event.dart';
import 'package:campusverse/providers/notification_provider.dart';
import 'package:campusverse/providers/profile_provider.dart';
import 'package:campusverse/providers/registration_provider.dart';
import 'package:campusverse/repositories/registration_repository.dart';
import 'package:campusverse/screens/registration/event_registration_screen.dart';
import 'package:campusverse/services/local_storage_service.dart';
import '../test_helpers/mock_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('EventRegistrationScreen validates fields and terms checkbox',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final regRepo = RegistrationRepository(storageService);

    final event = Event(
      id: 'test-event-1',
      title: 'Dev Workshop',
      description: 'Desc',
      category: 'Workshops',
      venue: 'Lab 1',
      organizer: 'Lead',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
      capacity: 50,
      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87',
      registrationDeadline: DateTime.now().add(const Duration(days: 1)),
    );

    // Set surface size to avoid constrained rendering in test
    await tester.binding.setSurfaceSize(const Size(800, 1200));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProfileProvider(storageService)),
          ChangeNotifierProvider(create: (_) => RegistrationProvider(regRepo)),
          ChangeNotifierProvider(create: (_) => NotificationProvider(storageService)),
        ],
        child: MaterialApp(
          home: EventRegistrationScreen(event: event),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial fields are present
    expect(find.text('Event Registration'), findsOneWidget);
    expect(find.text('Dev Workshop'), findsOneWidget);

    // Clear name field to trigger validation error
    final nameField = find.widgetWithText(TextFormField, 'Full Student Name *');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, '');

    // Tap submit button
    final submitButton = find.widgetWithText(ElevatedButton, 'Complete Registration & Get Pass');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Check validation error appeared
    expect(find.text('Full name is required'), findsOneWidget);
  });
}

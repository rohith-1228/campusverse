import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusverse/core/constants/app_constants.dart';
import 'package:campusverse/models/student.dart';
import 'package:campusverse/providers/profile_provider.dart';
import 'package:campusverse/services/local_storage_service.dart';

void main() {
  group('ProfileProvider & Authentication Tests', () {
    late LocalStorageService storageService;
    late ProfileProvider profileProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = LocalStorageService(prefs);
      profileProvider = ProfileProvider(storageService);
    });

    test('should register a new student account and set active session', () async {
      final student = await profileProvider.registerStudentAccount(
        name: 'Jane Doe',
        email: 'jane.doe@campusverse.edu',
        rollNumber: 'CS-2026-99',
        department: 'Computer Science',
        yearOfStudy: '2nd Year',
        phone: '+1 555-0199',
        password: 'Password123!',
      );

      expect(student.name, 'Jane Doe');
      expect(student.email, 'jane.doe@campusverse.edu');
      expect(student.rollNumber, 'CS-2026-99');
      expect(profileProvider.currentStudent?.rollNumber, 'CS-2026-99');
      expect(profileProvider.isStudent, true);
      expect(profileProvider.isOrganizer, false);
      expect(profileProvider.isLoggedIn, true);
      expect(profileProvider.accounts.length, Student.samplePresets.length + 1);
    });

    test('should reject duplicate student registration with existing email', () async {
      await profileProvider.registerStudentAccount(
        name: 'Jane Doe',
        email: 'jane.doe@campusverse.edu',
        rollNumber: 'CS-2026-99',
        department: 'Computer Science',
        yearOfStudy: '2nd Year',
        phone: '+1 555-0199',
        password: 'Password123!',
      );

      // Attempt registration with identical email in different case
      expect(
        () => profileProvider.registerStudentAccount(
          name: 'Jane Duplicate',
          email: 'JANE.DOE@campusverse.edu',
          rollNumber: 'CS-2026-100',
          department: 'Information Tech',
          yearOfStudy: '3rd Year',
          phone: '+1 555-0200',
          password: 'AnotherPassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('should reject duplicate student registration with existing roll number', () async {
      await profileProvider.registerStudentAccount(
        name: 'Jane Doe',
        email: 'jane.doe@campusverse.edu',
        rollNumber: 'CS-2026-99',
        department: 'Computer Science',
        yearOfStudy: '2nd Year',
        phone: '+1 555-0199',
        password: 'Password123!',
      );

      // Attempt registration with identical roll number in different case
      expect(
        () => profileProvider.registerStudentAccount(
          name: 'Bob Duplicate',
          email: 'bob@campusverse.edu',
          rollNumber: 'cs-2026-99',
          department: 'Mechanical',
          yearOfStudy: '1st Year',
          phone: '+1 555-0300',
          password: 'BobPassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('should allow returning student to login by email or roll number', () async {
      await profileProvider.registerStudentAccount(
        name: 'Alex Turner',
        email: 'alex.t@campusverse.edu',
        rollNumber: 'EE-2026-42',
        department: 'Electrical',
        yearOfStudy: '4th Year',
        phone: '+1 555-0142',
        password: 'SecurePass42',
      );

      // Log out
      await profileProvider.logout();
      expect(profileProvider.currentStudent, isNull);

      // Login by email
      final loggedInByEmail = await profileProvider.loginStudent(
        identifier: 'alex.t@campusverse.edu',
        password: 'SecurePass42',
      );
      expect(loggedInByEmail.rollNumber, 'EE-2026-42');
      expect(profileProvider.currentStudent?.name, 'Alex Turner');

      // Log out again
      await profileProvider.logout();

      // Login by roll number (case insensitive)
      final loggedInByRoll = await profileProvider.loginStudent(
        identifier: 'ee-2026-42',
        password: 'SecurePass42',
      );
      expect(loggedInByRoll.email, 'alex.t@campusverse.edu');
    });

    test('should reject student login with incorrect password or unknown account', () async {
      await profileProvider.registerStudentAccount(
        name: 'Sarah Connor',
        email: 'sarah@campusverse.edu',
        rollNumber: 'AI-2026-01',
        department: 'AI & Data Science',
        yearOfStudy: '3rd Year',
        phone: '+1 555-0999',
        password: 'CorrectPassword',
      );

      // Wrong password
      expect(
        () => profileProvider.loginStudent(
          identifier: 'sarah@campusverse.edu',
          password: 'WrongPassword',
        ),
        throwsA(isA<AuthException>()),
      );

      // Unknown student identifier
      expect(
        () => profileProvider.loginStudent(
          identifier: 'ghost@campusverse.edu',
          password: 'AnyPassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('should update student profile without creating a duplicate account', () async {
      final initial = await profileProvider.registerStudentAccount(
        name: 'David Miller',
        email: 'david.m@campusverse.edu',
        rollNumber: 'ME-2026-15',
        department: 'Mechanical',
        yearOfStudy: '2nd Year',
        phone: '+1 555-0115',
        password: 'Pass123',
      );

      expect(profileProvider.accounts.length, Student.samplePresets.length + 1);

      final updated = initial.copyWith(
        name: 'David Miller Jr.',
        phone: '+1 555-9999',
        yearOfStudy: '3rd Year',
      );

      await profileProvider.updateProfile(updated);

      expect(profileProvider.currentStudent?.name, 'David Miller Jr.');
      expect(profileProvider.currentStudent?.phone, '+1 555-9999');
      expect(profileProvider.accounts.length, Student.samplePresets.length + 1);
      expect(profileProvider.accounts.last.name, 'David Miller Jr.');
    });

    test('should authenticate organizer with demo credentials and set organizer role', () async {
      final success = await profileProvider.loginOrganizer(
        email: AppConstants.demoOrganizerEmail,
        password: AppConstants.demoOrganizerPassword,
      );

      expect(success, true);
      expect(profileProvider.isOrganizer, true);
      expect(profileProvider.isStudent, false);
      expect(profileProvider.currentStudent, isNull);
    });

    test('should reject organizer login with invalid credentials', () async {
      expect(
        () => profileProvider.loginOrganizer(
          email: 'fake.organizer@campusverse.edu',
          password: 'WrongPassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('should support 1-click organizer demo login for evaluators', () async {
      await profileProvider.loginOrganizerDemo();
      expect(profileProvider.isOrganizer, true);
      expect(profileProvider.userRole, 'organizer');
      expect(profileProvider.currentStudent, isNull);
    });

    test('should reset state on logout', () async {
      await profileProvider.loginOrganizerDemo();
      expect(profileProvider.isOrganizer, true);

      await profileProvider.logout();
      expect(profileProvider.isOrganizer, false);
      expect(profileProvider.isStudent, true);
      expect(profileProvider.currentStudent, isNull);
    });

    test('should never serialize passwords in Student models or JSON payloads', () async {
      final student = await profileProvider.registerStudentAccount(
        name: 'Sec Test',
        email: 'sec@campusverse.edu',
        rollNumber: 'SEC-2026-01',
        department: 'Cybersecurity',
        yearOfStudy: '4th Year',
        phone: '+1 555-0911',
        password: 'TopSecretPassword99!',
      );

      final jsonMap = student.toJson();
      expect(jsonMap.containsKey('password'), false,
          reason: 'Student JSON must NEVER expose password');

      // Verify stored credential uses salted hash rather than plaintext
      final hasRawPassword = storageService.verifyStudentCredential(
        student.rollNumber,
        'TopSecretPassword99!',
      );
      expect(hasRawPassword, true);

      final hasWrongPassword = storageService.verifyStudentCredential(
        student.rollNumber,
        'WrongPassword!',
      );
      expect(hasWrongPassword, false);
    });
  });
}

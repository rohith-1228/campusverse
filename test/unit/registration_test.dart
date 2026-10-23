import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusverse/models/event.dart';
import 'package:campusverse/models/student.dart';
import 'package:campusverse/repositories/registration_repository.dart';
import 'package:campusverse/services/local_storage_service.dart';

void main() {
  group('Registration Repository & Duplicate Prevention', () {
    late LocalStorageService storageService;
    late RegistrationRepository repo;

    final testStudent = const Student(
      name: 'Test Student',
      email: 'test@campus.edu',
      rollNumber: 'CS-101',
      department: 'Computer Science',
      yearOfStudy: '3rd Year',
      phone: '9876543210',
    );

    final testEvent = Event(
      id: 'event-test-100',
      title: 'Dev Workshop',
      description: 'Desc',
      category: 'Workshops',
      venue: 'Lab A',
      organizer: 'Tech Club',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      endTime: DateTime.now().add(const Duration(days: 3, hours: 2)),
      capacity: 30,
      registeredCount: 5,
      imageUrl: 'url',
      registrationDeadline: DateTime.now().add(const Duration(days: 2)),
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = LocalStorageService(prefs);
      repo = RegistrationRepository(storageService);
    });

    test('should register a student successfully and generate valid pass details', () async {
      final reg = await repo.register(
        event: testEvent,
        student: testStudent,
        teamName: 'Innovators',
      );

      expect(reg.eventId, 'event-test-100');
      expect(reg.student.rollNumber, 'CS-101');
      expect(reg.status, 'confirmed');
      expect(reg.teamName, 'Innovators');
      expect(reg.registrationId.startsWith('CV-'), true);
      expect(reg.qrCodeData.contains('CS-101'), true);

      expect(repo.isRegistered('event-test-100', 'CS-101'), true);
    });

    test('should prevent duplicate registration for same student and event', () async {
      await repo.register(
        event: testEvent,
        student: testStudent,
      );

      expect(
        () => repo.register(
          event: testEvent,
          student: testStudent,
        ),
        throwsA(isA<RegistrationException>()),
      );
    });

    test('should cancel registration successfully', () async {
      final reg = await repo.register(
        event: testEvent,
        student: testStudent,
      );

      final cancelled = await repo.cancelRegistration(reg.registrationId);
      expect(cancelled, true);

      final current = repo.getRegistrationForEvent(testEvent.id, testStudent.rollNumber);
      expect(current, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusverse/models/event.dart';
import 'package:campusverse/models/student.dart';
import 'package:campusverse/repositories/registration_repository.dart';
import 'package:campusverse/services/local_storage_service.dart';

void main() {
  group('Ticket Generation, QR Verification & Gate Admission Tests', () {
    late LocalStorageService storageService;
    late RegistrationRepository repo;

    const studentA = Student(
      name: 'Alex Chen',
      email: 'alex.chen@campusverse.edu',
      rollNumber: 'CS-2024-001',
      department: 'Computer Science',
      yearOfStudy: '3rd Year',
      phone: '+1 555-0101',
    );

    const studentB = Student(
      name: 'Sophia Patel',
      email: 'sophia.patel@campusverse.edu',
      rollNumber: 'IT-2024-042',
      department: 'Information Tech',
      yearOfStudy: '2nd Year',
      phone: '+1 555-0142',
    );

    final event1 = Event(
      id: 'hackathon-2026',
      title: 'HackCampus 2026',
      description: 'Annual 24-Hour Collegiate Hackathon',
      category: 'Hackathons',
      venue: 'Innovation Hub, Hall A',
      organizer: 'Computer Science Society',
      dateTime: DateTime.now().add(const Duration(days: 5)),
      endTime: DateTime.now().add(const Duration(days: 6)),
      capacity: 100,
      registeredCount: 12,
      imageUrl: 'https://example.com/hackathon.jpg',
      registrationDeadline: DateTime.now().add(const Duration(days: 3)),
    );

    final event2 = Event(
      id: 'robotics-expo',
      title: 'RoboQuest Expo',
      description: 'Robotics and AI Showcase',
      category: 'Exhibitions',
      venue: 'Main Auditorium',
      organizer: 'Robotics Guild',
      dateTime: DateTime.now().add(const Duration(days: 7)),
      endTime: DateTime.now().add(const Duration(days: 7, hours: 4)),
      capacity: 80,
      registeredCount: 20,
      imageUrl: 'https://example.com/robotics.jpg',
      registrationDeadline: DateTime.now().add(const Duration(days: 5)),
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = LocalStorageService(prefs);
      repo = RegistrationRepository(storageService);
    });

    test('should generate a unique registration ID and ticket for student registration', () async {
      final reg1 = await repo.register(event: event1, student: studentA);
      final reg2 = await repo.register(event: event1, student: studentB);

      expect(reg1.registrationId.startsWith('CV-'), true);
      expect(reg2.registrationId.startsWith('CV-'), true);
      expect(reg1.registrationId != reg2.registrationId, true);
      expect(reg1.isCheckedIn, false);
      expect(reg1.checkedInAt, isNull);
      expect(reg1.isConfirmed, true);
    });

    test('should parse raw and prefixed QR payloads accurately', () {
      expect(
        repo.extractRegistrationId('CAMPUSVERSE:TICKET:CV-A1B2C3D4'),
        'CV-A1B2C3D4',
      );
      expect(
        repo.extractRegistrationId('CV-A1B2C3D4'),
        'CV-A1B2C3D4',
      );
      expect(
        repo.extractRegistrationId('  CAMPUSVERSE:TICKET:CV-9999  '),
        'CV-9999',
      );
      expect(
        repo.extractRegistrationId('   '),
        '',
      );
    });

    test('should verify a valid ticket accurately', () async {
      final reg = await repo.register(event: event1, student: studentA);

      final result = repo.verifyTicket(rawInput: reg.registrationId);
      expect(result.status, TicketVerificationStatus.valid);
      expect(result.isValid, true);
      expect(result.canCheckIn, true);
      expect(result.registration?.registrationId, reg.registrationId);
      expect(result.registration?.student.name, 'Alex Chen');
      expect(result.registration?.eventTitle, 'HackCampus 2026');
    });

    test('should support event-specific gate matching and detect mismatch', () async {
      final regEvent1 = await repo.register(event: event1, student: studentA);

      // Verify at the correct event gate
      final matchResult = repo.verifyTicket(
        rawInput: regEvent1.registrationId,
        targetEventId: 'hackathon-2026',
      );
      expect(matchResult.status, TicketVerificationStatus.valid);
      expect(matchResult.canCheckIn, true);

      // Verify at a different event gate
      final mismatchResult = repo.verifyTicket(
        rawInput: regEvent1.registrationId,
        targetEventId: 'robotics-expo',
      );
      expect(mismatchResult.status, TicketVerificationStatus.eventMismatch);
      expect(mismatchResult.canCheckIn, false);
      expect(mismatchResult.message.contains('HackCampus 2026'), true);
    });

    test('should reject unknown ticket codes', () {
      final result = repo.verifyTicket(rawInput: 'CV-NON-EXISTENT-TICKET');
      expect(result.status, TicketVerificationStatus.notFound);
      expect(result.isValid, false);
      expect(result.canCheckIn, false);
      expect(result.registration, isNull);
    });

    test('should reject cancelled tickets at the gate', () async {
      final reg = await repo.register(event: event1, student: studentA);
      await repo.cancelRegistration(reg.registrationId);

      final result = repo.verifyTicket(rawInput: reg.registrationId);
      expect(result.status, TicketVerificationStatus.cancelled);
      expect(result.canCheckIn, false);
      expect(result.message.contains('cancelled'), true);
    });

    test('should successfully check in valid ticket and prevent duplicate check-ins', () async {
      final reg = await repo.register(event: event1, student: studentA);

      // First check-in
      final checkInSuccess = await repo.checkInTicket(reg.registrationId);
      expect(checkInSuccess.isCheckedIn, true);
      expect(checkInSuccess.checkedInAt, isNotNull);
      expect(checkInSuccess.status, 'attended');

      // Second check-in attempt (duplicate entry)
      final duplicateResult = repo.verifyTicket(rawInput: reg.registrationId);
      expect(duplicateResult.status, TicketVerificationStatus.alreadyCheckedIn);
      expect(duplicateResult.canCheckIn, false);

      // Attempting checkInTicket again throws exception
      expect(
        () => repo.checkInTicket(reg.registrationId),
        throwsA(isA<RegistrationException>()),
      );
    });

    test('should persist check-in status across repository reload', () async {
      final reg = await repo.register(event: event1, student: studentA);
      await repo.checkInTicket(reg.registrationId);

      // Instantiate fresh repository pointing to the same storage service
      final newRepo = RegistrationRepository(storageService);
      final verified = newRepo.verifyTicket(rawInput: reg.registrationId);

      expect(verified.status, TicketVerificationStatus.alreadyCheckedIn);
      expect(verified.registration?.isCheckedIn, true);
      expect(verified.registration?.checkedInAt, isNotNull);
    });

    test('should isolate student registrations and filter by student roll number', () async {
      await repo.register(event: event1, student: studentA);
      await repo.register(event: event2, student: studentA);
      await repo.register(event: event1, student: studentB);

      final studentARegs = repo.getRegistrationsForStudent('CS-2024-001');
      final studentBRegs = repo.getRegistrationsForStudent('IT-2024-042');

      expect(studentARegs.length, 2);
      expect(studentARegs.every((r) => r.student.rollNumber == 'CS-2024-001'), true);

      expect(studentBRegs.length, 1);
      expect(studentBRegs.first.student.rollNumber, 'IT-2024-042');
    });
  });
}

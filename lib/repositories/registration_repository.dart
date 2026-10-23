import 'dart:math';
import '../models/event.dart';
import '../models/registration.dart';
import '../models/student.dart';
import '../services/local_storage_service.dart';

class RegistrationException implements Exception {
  final String message;
  RegistrationException(this.message);

  @override
  String toString() => message;
}

class RegistrationRepository {
  final LocalStorageService _storageService;

  RegistrationRepository(this._storageService);

  List<Registration> getRegistrations() {
    return _storageService.getRegistrations();
  }

  bool isRegistered(String eventId, String rollNumber) {
    final list = _storageService.getRegistrations();
    return list.any((r) =>
        r.eventId == eventId &&
        r.student.rollNumber.toLowerCase() == rollNumber.toLowerCase() &&
        r.status != 'cancelled');
  }

  Registration? getRegistrationForEvent(String eventId, String rollNumber) {
    final list = _storageService.getRegistrations();
    try {
      return list.firstWhere((r) =>
          r.eventId == eventId &&
          r.student.rollNumber.toLowerCase() == rollNumber.toLowerCase() &&
          r.status != 'cancelled');
    } catch (_) {
      return null;
    }
  }

  Future<Registration> register({
    required Event event,
    required Student student,
    String? teamName,
  }) async {
    // Check duplicate
    if (isRegistered(event.id, student.rollNumber)) {
      throw RegistrationException(
        'Student with Roll Number ${student.rollNumber} is already registered for "${event.title}". Duplicate registrations are not allowed.',
      );
    }

    if (event.isFull) {
      throw RegistrationException(
        'Sorry, registration for "${event.title}" is full (${event.capacity} seats reached).',
      );
    }

    final randId = 1000 + Random().nextInt(9000);
    final regId = 'CV-${DateTime.now().year}-$randId';
    final qrData =
        'CAMPUSVERSE://VERIFY?regId=$regId&event=${Uri.encodeComponent(event.title)}&student=${Uri.encodeComponent(student.name)}&roll=${student.rollNumber}&ts=${DateTime.now().millisecondsSinceEpoch}';

    final registration = Registration(
      registrationId: regId,
      eventId: event.id,
      eventTitle: event.title,
      eventVenue: event.venue,
      eventDate: event.dateTime,
      student: student,
      teamName: teamName,
      registeredAt: DateTime.now(),
      status: 'confirmed',
      qrCodeData: qrData,
    );

    final list = _storageService.getRegistrations();
    list.insert(0, registration);
    await _storageService.saveRegistrations(list);

    return registration;
  }

  Future<bool> cancelRegistration(String registrationId) async {
    final list = _storageService.getRegistrations();
    final index = list.indexWhere((r) => r.registrationId == registrationId);
    if (index != -1) {
      list[index] = list[index].copyWith(status: 'cancelled');
      await _storageService.saveRegistrations(list);
      return true;
    }
    return false;
  }
}

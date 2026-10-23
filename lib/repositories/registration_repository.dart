import 'package:uuid/uuid.dart';
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

enum TicketVerificationStatus {
  valid,
  alreadyCheckedIn,
  cancelled,
  eventMismatch,
  notFound,
  invalidFormat,
}

class TicketVerificationResult {
  final TicketVerificationStatus status;
  final String message;
  final Registration? registration;
  final bool canCheckIn;

  const TicketVerificationResult({
    required this.status,
    required this.message,
    this.registration,
    required this.canCheckIn,
  });

  bool get isValid => status == TicketVerificationStatus.valid;
}

class RegistrationRepository {
  final LocalStorageService _storageService;

  RegistrationRepository(this._storageService);

  List<Registration> getRegistrations() {
    return _storageService.getRegistrations();
  }

  /// Get active or all registrations specifically for a student roll number
  List<Registration> getRegistrationsForStudent(String rollNumber) {
    final list = _storageService.getRegistrations();
    final normRoll = rollNumber.trim().toLowerCase();
    return list.where((r) =>
        r.student.rollNumber.trim().toLowerCase() == normRoll &&
        r.status != 'cancelled').toList();
  }

  /// Get registrations for a specific event (organizer view)
  List<Registration> getRegistrationsForEvent(String eventId) {
    final list = _storageService.getRegistrations();
    return list.where((r) => r.eventId == eventId && r.status != 'cancelled').toList();
  }

  /// Find registration by unique ID
  Registration? getRegistrationById(String registrationId) {
    final list = _storageService.getRegistrations();
    final normId = registrationId.trim().toUpperCase();
    return list.where((r) => r.registrationId.trim().toUpperCase() == normId).firstOrNull;
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

  /// Register student for an event with unique ID and standard QR payload
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

    final list = _storageService.getRegistrations();

    // Generate collision-resistant unique registration identifier
    String regId;
    do {
      final shortUuid = const Uuid().v4().substring(0, 8).toUpperCase();
      regId = 'CV-${DateTime.now().year}-$shortUuid';
    } while (list.any((r) => r.registrationId.toUpperCase() == regId));

    // Compact, standard verification payload
    final qrData = 'CAMPUSVERSE:TICKET:$regId';

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
      isCheckedIn: false,
      checkedInAt: null,
      qrCodeData: qrData,
    );

    list.insert(0, registration);
    await _storageService.saveRegistrations(list);

    return registration;
  }

  /// Cancel registration
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

  /// Extract Registration ID from scanned QR string or manual input
  String extractRegistrationId(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '';

    // Format 1: CAMPUSVERSE:TICKET:<regId>
    if (text.startsWith('CAMPUSVERSE:TICKET:')) {
      return text.substring('CAMPUSVERSE:TICKET:'.length).trim().toUpperCase();
    }

    // Format 2: CAMPUSVERSE://VERIFY?regId=<regId>...
    if (text.contains('regId=')) {
      try {
        final uri = Uri.parse(text);
        final id = uri.queryParameters['regId'];
        if (id != null && id.isNotEmpty) return id.trim().toUpperCase();
      } catch (_) {}
    }

    // Format 3: Direct Registration ID (e.g. CV-2026-1234)
    return text.toUpperCase();
  }

  /// Full verification of a ticket for admission
  TicketVerificationResult verifyTicket({
    required String rawInput,
    String? targetEventId,
  }) {
    final regId = extractRegistrationId(rawInput);
    if (regId.isEmpty) {
      return const TicketVerificationResult(
        status: TicketVerificationStatus.invalidFormat,
        message: 'Invalid ticket data or empty QR code.',
        canCheckIn: false,
      );
    }

    final registration = getRegistrationById(regId);
    if (registration == null) {
      return TicketVerificationResult(
        status: TicketVerificationStatus.notFound,
        message: 'No registration record found for ID: $regId.',
        canCheckIn: false,
      );
    }

    if (registration.isCancelled) {
      return TicketVerificationResult(
        status: TicketVerificationStatus.cancelled,
        message: 'This registration pass was cancelled and is invalid for entry.',
        registration: registration,
        canCheckIn: false,
      );
    }

    if (registration.isAttended || registration.isCheckedIn) {
      final timeStr = registration.checkedInAt != null
          ? 'at ${registration.checkedInAt!.hour.toString().padLeft(2, '0')}:${registration.checkedInAt!.minute.toString().padLeft(2, '0')}'
          : '';
      return TicketVerificationResult(
        status: TicketVerificationStatus.alreadyCheckedIn,
        message: 'Ticket already checked in $timeStr! Repeated entry rejected.',
        registration: registration,
        canCheckIn: false,
      );
    }

    if (targetEventId != null &&
        targetEventId.isNotEmpty &&
        registration.eventId != targetEventId) {
      return TicketVerificationResult(
        status: TicketVerificationStatus.eventMismatch,
        message: 'Ticket is registered for "${registration.eventTitle}", which does not match the selected event check-in desk.',
        registration: registration,
        canCheckIn: false,
      );
    }

    return TicketVerificationResult(
      status: TicketVerificationStatus.valid,
      message: 'Verified admission pass for ${registration.student.name} (${registration.student.rollNumber}).',
      registration: registration,
      canCheckIn: true,
    );
  }

  /// Mark ticket as checked in and persist
  Future<Registration> checkInTicket(String registrationId) async {
    final list = _storageService.getRegistrations();
    final normId = registrationId.trim().toUpperCase();
    final index = list.indexWhere((r) => r.registrationId.trim().toUpperCase() == normId);

    if (index == -1) {
      throw RegistrationException('Registration not found: $registrationId');
    }

    final reg = list[index];
    if (reg.isCancelled) {
      throw RegistrationException('Cannot check in cancelled registration');
    }
    if (reg.isCheckedIn || reg.status == 'attended') {
      throw RegistrationException('Ticket already checked in earlier');
    }

    final now = DateTime.now();
    final updated = reg.copyWith(
      status: 'attended',
      isCheckedIn: true,
      checkedInAt: now,
    );

    list[index] = updated;
    await _storageService.saveRegistrations(list);
    return updated;
  }
}

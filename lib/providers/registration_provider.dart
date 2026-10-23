import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/registration.dart';
import '../models/student.dart';
import '../repositories/registration_repository.dart';

class RegistrationProvider extends ChangeNotifier {
  final RegistrationRepository _repository;
  List<Registration> _registrations = [];
  bool _isLoading = false;
  String? _errorMessage;

  RegistrationProvider(this._repository) {
    _loadRegistrations();
  }

  List<Registration> get registrations => _registrations;

  List<Registration> get activeRegistrations =>
      _registrations.where((r) => r.isConfirmed || r.isCheckedIn).toList();

  int get count => activeRegistrations.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _loadRegistrations() {
    _registrations = _repository.getRegistrations();
    notifyListeners();
  }

  /// Get registrations strictly for the signed-in student
  List<Registration> getRegistrationsForStudent(String rollNumber) {
    return _repository.getRegistrationsForStudent(rollNumber);
  }

  /// Get registrations for an event (organizer management)
  List<Registration> getRegistrationsForEvent(String eventId) {
    return _repository.getRegistrationsForEvent(eventId);
  }

  bool isRegistered(String eventId, String rollNumber) {
    return _repository.isRegistered(eventId, rollNumber);
  }

  Registration? getRegistration(String eventId, String rollNumber) {
    return _repository.getRegistrationForEvent(eventId, rollNumber);
  }

  Registration? getRegistrationById(String registrationId) {
    return _repository.getRegistrationById(registrationId);
  }

  /// Ticket verification
  TicketVerificationResult verifyTicket({
    required String rawInput,
    String? targetEventId,
  }) {
    return _repository.verifyTicket(
      rawInput: rawInput,
      targetEventId: targetEventId,
    );
  }

  /// Organizer check-in
  Future<Registration> checkInTicket(String registrationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reg = await _repository.checkInTicket(registrationId);
      _loadRegistrations();
      _isLoading = false;
      notifyListeners();
      return reg;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Registration> registerStudent({
    required Event event,
    required Student student,
    String? teamName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reg = await _repository.register(
        event: event,
        student: student,
        teamName: teamName,
      );
      _loadRegistrations();
      _isLoading = false;
      notifyListeners();
      return reg;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> cancelRegistration(String registrationId) async {
    _isLoading = true;
    notifyListeners();
    final success = await _repository.cancelRegistration(registrationId);
    _loadRegistrations();
    _isLoading = false;
    notifyListeners();
    return success;
  }
}

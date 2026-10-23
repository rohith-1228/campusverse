import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/student.dart';
import '../services/local_storage_service.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class ProfileProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  Student? _currentStudent;
  String _userRole = 'student'; // 'student' or 'organizer'
  List<Student> _accounts = [];

  ProfileProvider(this._storageService) {
    _loadProfile();
  }

  Student? get currentStudent => _currentStudent;
  String get userRole => _userRole;
  bool get isOrganizer => _userRole == 'organizer';
  bool get isStudent => _userRole == 'student';
  bool get isLoggedIn => isOrganizer || _currentStudent != null;
  List<Student> get accounts => _accounts;

  void _loadProfile() {
    _accounts = _storageService.getStudentAccounts();
    _userRole = _storageService.getUserRole();

    final sessionRoll = _storageService.getSessionRollNumber();
    if (sessionRoll != null && sessionRoll.isNotEmpty) {
      _currentStudent = _accounts.where(
        (a) => a.rollNumber.trim().toLowerCase() == sessionRoll.toLowerCase(),
      ).firstOrNull;
    } else {
      _currentStudent = _storageService.getStudent();
    }
    notifyListeners();
  }

  /// Register a brand new student account with validation and duplicate prevention.
  /// Passwords are never stored on the Student profile model.
  Future<Student> registerStudentAccount({
    required String name,
    required String email,
    required String rollNumber,
    required String department,
    required String yearOfStudy,
    required String phone,
    required String password,
    String? avatarUrl,
  }) async {
    final normEmail = email.trim().toLowerCase();
    final normRoll = rollNumber.trim().toLowerCase();

    // Check duplicate email
    final emailExists = _accounts.any(
      (a) => a.email.trim().toLowerCase() == normEmail,
    );
    if (emailExists) {
      throw AuthException(
        'A student account with college email "$email" already exists.',
      );
    }

    // Check duplicate roll number
    final rollExists = _accounts.any(
      (a) => a.rollNumber.trim().toLowerCase() == normRoll,
    );
    if (rollExists) {
      throw AuthException(
        'A student account with roll number "$rollNumber" is already registered.',
      );
    }

    // Create pure profile model WITHOUT password
    final newStudent = Student(
      name: name.trim(),
      email: email.trim(),
      rollNumber: rollNumber.trim(),
      department: department,
      yearOfStudy: yearOfStudy,
      phone: phone.trim(),
      avatarUrl: avatarUrl ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    );

    // Save salted password hash in isolated credentials store
    await _storageService.saveStudentCredential(rollNumber, password);

    _accounts.add(newStudent);
    await _storageService.saveStudentAccounts(_accounts);

    // Set active student session
    _currentStudent = newStudent;
    _userRole = 'student';
    await _storageService.saveStudent(newStudent);
    await _storageService.saveSessionRollNumber(rollNumber);
    await _storageService.saveUserRole('student');

    notifyListeners();
    return newStudent;
  }

  /// Login returning student by Email or University Roll Number
  Future<Student> loginStudent({
    required String identifier,
    required String password,
  }) async {
    final normIdentifier = identifier.trim().toLowerCase();
    final account = _accounts.where((a) {
      return a.email.trim().toLowerCase() == normIdentifier ||
          a.rollNumber.trim().toLowerCase() == normIdentifier;
    }).firstOrNull;

    if (account == null) {
      throw AuthException(
        'No student account found for "$identifier". Please register or choose a sample profile.',
      );
    }

    // Verify password against salted credentials store (never plaintext in student model)
    final isValid = _storageService.verifyStudentCredential(account.rollNumber, password);
    if (!isValid) {
      throw AuthException(
        'Incorrect password. Please verify and try again.',
      );
    }

    _currentStudent = account;
    _userRole = 'student';
    await _storageService.saveStudent(account);
    await _storageService.saveSessionRollNumber(account.rollNumber);
    await _storageService.saveUserRole('student');

    notifyListeners();
    return account;
  }

  /// Direct quick-login for sample student presets (e.g. Alex Chen, Sophia Patel)
  Future<void> login(Student student) async {
    _currentStudent = student;
    _userRole = 'student';
    await _storageService.registerOrUpdateStudentAccount(student);
    _accounts = _storageService.getStudentAccounts();
    await _storageService.saveStudent(student);
    await _storageService.saveSessionRollNumber(student.rollNumber);
    await _storageService.saveUserRole('student');
    notifyListeners();
  }

  /// Organizer authentication with academic demo credentials
  Future<bool> loginOrganizer({
    required String email,
    required String password,
  }) async {
    final normEmail = email.trim().toLowerCase();
    if (normEmail == AppConstants.demoOrganizerEmail.toLowerCase() &&
        password == AppConstants.demoOrganizerPassword) {
      _userRole = 'organizer';
      _currentStudent = null; // Organizers are administrative roles, not student profiles
      await _storageService.saveUserRole('organizer');
      await _storageService.clearStudent();
      await _storageService.clearSessionRollNumber();
      notifyListeners();
      return true;
    } else {
      throw AuthException(
        'Invalid organizer credentials. For academic evaluation, use: ${AppConstants.demoOrganizerEmail} / ${AppConstants.demoOrganizerPassword}',
      );
    }
  }

  /// Explicit demo organizer login for academic evaluators
  Future<void> loginOrganizerDemo() async {
    _userRole = 'organizer';
    _currentStudent = null;
    await _storageService.saveUserRole('organizer');
    await _storageService.clearStudent();
    await _storageService.clearSessionRollNumber();
    notifyListeners();
  }

  /// Update existing student profile without creating duplicates
  Future<void> updateProfile(Student updatedStudent) async {
    _currentStudent = updatedStudent;
    await _storageService.saveStudent(updatedStudent);
    await _storageService.registerOrUpdateStudentAccount(updatedStudent);
    _accounts = _storageService.getStudentAccounts();
    notifyListeners();
  }

  /// Full logout clearing active user session and credentials from memory
  Future<void> logout() async {
    _currentStudent = null;
    _userRole = 'student';
    await _storageService.clearStudent();
    await _storageService.clearSessionRollNumber();
    await _storageService.clearUserRole();
    notifyListeners();
  }
}

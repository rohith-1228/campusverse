import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/local_storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  Student? _currentStudent;

  ProfileProvider(this._storageService) {
    _loadProfile();
  }

  Student? get currentStudent => _currentStudent;
  bool get isLoggedIn => _currentStudent != null;

  void _loadProfile() {
    _currentStudent = _storageService.getStudent();
    notifyListeners();
  }

  Future<void> login(Student student) async {
    _currentStudent = student;
    await _storageService.saveStudent(student);
    notifyListeners();
  }

  Future<void> updateProfile(Student updatedStudent) async {
    _currentStudent = updatedStudent;
    await _storageService.saveStudent(updatedStudent);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentStudent = null;
    await _storageService.clearStudent();
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/app_notification.dart';
import '../models/event.dart';
import '../models/registration.dart';
import '../models/student.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // ---------------- STUDENT PROFILE & ACCOUNTS ----------------
  Future<bool> saveStudent(Student student) async {
    final jsonStr = jsonEncode(student.toJson());
    return _prefs.setString(AppConstants.keyStudentProfile, jsonStr);
  }

  Student? getStudent() {
    final jsonStr = _prefs.getString(AppConstants.keyStudentProfile);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Student.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> clearStudent() async {
    return _prefs.remove(AppConstants.keyStudentProfile);
  }

  Future<bool> saveStudentAccounts(List<Student> accounts) async {
    final list = accounts.map((s) => s.toJson()).toList();
    return _prefs.setString(AppConstants.keyStudentAccounts, jsonEncode(list));
  }

  List<Student> getStudentAccounts() {
    final jsonStr = _prefs.getString(AppConstants.keyStudentAccounts);
    if (jsonStr == null || jsonStr.isEmpty) {
      // Return default presets if none registered yet
      return List<Student>.from(Student.samplePresets);
    }
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      final list = decoded
          .map((item) => Student.fromJson(item as Map<String, dynamic>))
          .toList();
      return list.isNotEmpty ? list : List<Student>.from(Student.samplePresets);
    } catch (_) {
      return List<Student>.from(Student.samplePresets);
    }
  }

  Future<bool> registerOrUpdateStudentAccount(Student student) async {
    final accounts = getStudentAccounts();
    final normalizedEmail = student.email.trim().toLowerCase();
    final normalizedRoll = student.rollNumber.trim().toLowerCase();

    final existingIndex = accounts.indexWhere((a) =>
        a.email.trim().toLowerCase() == normalizedEmail ||
        a.rollNumber.trim().toLowerCase() == normalizedRoll);

    if (existingIndex != -1) {
      accounts[existingIndex] = student;
    } else {
      accounts.add(student);
    }
    return saveStudentAccounts(accounts);
  }

  // ---------------- USER ROLE ----------------
  Future<bool> saveUserRole(String role) async {
    return _prefs.setString(AppConstants.keyUserRole, role);
  }

  String getUserRole() {
    return _prefs.getString(AppConstants.keyUserRole) ?? 'student';
  }

  Future<bool> clearUserRole() async {
    return _prefs.remove(AppConstants.keyUserRole);
  }

  // ---------------- REGISTRATIONS ----------------
  Future<bool> saveRegistrations(List<Registration> registrations) async {
    final list = registrations.map((r) => r.toJson()).toList();
    return _prefs.setString(AppConstants.keyRegistrations, jsonEncode(list));
  }

  List<Registration> getRegistrations() {
    final jsonStr = _prefs.getString(AppConstants.keyRegistrations);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded
          .map((item) => Registration.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------- BOOKMARKS ----------------
  Future<bool> saveBookmarks(Set<String> bookmarkIds) async {
    return _prefs.setStringList(AppConstants.keyBookmarks, bookmarkIds.toList());
  }

  Set<String> getBookmarks() {
    final list = _prefs.getStringList(AppConstants.keyBookmarks);
    return list?.toSet() ?? {};
  }

  // ---------------- NOTIFICATIONS ----------------
  Future<bool> saveNotifications(List<AppNotification> notifications) async {
    final list = notifications.map((n) => n.toJson()).toList();
    return _prefs.setString(AppConstants.keyNotifications, jsonEncode(list));
  }

  List<AppNotification> getNotifications() {
    final jsonStr = _prefs.getString(AppConstants.keyNotifications);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------- CUSTOM ORGANIZER EVENTS ----------------
  Future<bool> saveCustomEvents(List<Event> events) async {
    final list = events.map((e) => e.toJson()).toList();
    return _prefs.setString(AppConstants.keyCustomEvents, jsonEncode(list));
  }

  List<Event> getCustomEvents() {
    final jsonStr = _prefs.getString(AppConstants.keyCustomEvents);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded
          .map((item) => Event.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------- THEME & PREFERENCES ----------------
  Future<bool> saveThemeIsDark(bool isDark) async {
    return _prefs.setBool(AppConstants.keyThemeIsDark, isDark);
  }

  bool? getThemeIsDark() {
    return _prefs.getBool(AppConstants.keyThemeIsDark);
  }

  Future<bool> saveUseApiBackend(bool useApi) async {
    return _prefs.setBool(AppConstants.keyUseApiBackend, useApi);
  }

  bool getUseApiBackend() {
    return _prefs.getBool(AppConstants.keyUseApiBackend) ?? false;
  }

  Future<void> resetAllData() async {
    await _prefs.clear();
  }
}

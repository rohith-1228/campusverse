import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/local_storage_service.dart';

class NotificationProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  List<AppNotification> _notifications = [];

  NotificationProvider(this._storageService) {
    _loadNotifications();
  }

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _loadNotifications() {
    final list = _storageService.getNotifications();
    if (list.isEmpty) {
      // Seed initial demo notifications
      final now = DateTime.now();
      _notifications = [
        AppNotification(
          id: 'n-1',
          title: 'Welcome to CampusVerse! 🚀',
          message:
              'Discover campus events, register instantly, and unlock your personalized digital admission pass.',
          timestamp: now.subtract(const Duration(hours: 2)),
          isRead: false,
          type: 'success',
        ),
        AppNotification(
          id: 'n-2',
          title: 'Registration Deadline Approaching ⏳',
          message:
              'Campus TechFest 2026 registration closes in 48 hours. Secure your seat before it fills up!',
          timestamp: now.subtract(const Duration(hours: 6)),
          isRead: false,
          type: 'reminder',
        ),
        AppNotification(
          id: 'n-3',
          title: 'Venue Update: AI Summit 📍',
          message:
              'The AI Innovation Summit has been relocated to Turing Computer Lab & Seminar Hall 4 for extra workstation seating.',
          timestamp: now.subtract(const Duration(days: 1)),
          isRead: true,
          type: 'update',
        ),
      ];
      _storageService.saveNotifications(_notifications);
    } else {
      _notifications = list;
    }
    notifyListeners();
  }

  Future<void> addNotification({
    required String title,
    required String message,
    String type = 'update',
  }) async {
    final newNotif = AppNotification(
      id: 'n-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
    );
    _notifications.insert(0, newNotif);
    notifyListeners();
    await _storageService.saveNotifications(_notifications);
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      await _storageService.saveNotifications(_notifications);
    }
  }

  Future<void> markAllAsRead() async {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    await _storageService.saveNotifications(_notifications);
  }
}

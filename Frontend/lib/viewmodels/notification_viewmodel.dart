import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/database_service.dart';
import '../services/firebase_messaging_service.dart';

class NotificationViewModel extends ChangeNotifier with WidgetsBindingObserver {
  final List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  final DatabaseService _dbService = DatabaseService();
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  NotificationViewModel() {
    WidgetsBinding.instance.addObserver(this);
    loadNotifications();
    _listenToFCM();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadNotifications();
    }
  }

  void _listenToFCM() {
    _fcmSubscription = FirebaseMessagingService().onMessageStream.listen((
      message,
    ) {
      if (message.notification != null) {
        // We only add the notification to the internal list for UI update
        // because it is ALREADY saved to the DB by FirebaseMessagingService
        final notification = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': message.notification!.title ?? 'Notification',
          'message': message.notification!.body ?? '',
          'type': message.data['type']?.toString() ?? 'info',
          'isRead': false,
          'createdAt': DateTime.now(),
        };

        _notifications.insert(0, notification);
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fcmSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedNotifications = await _dbService.getNotifications();
      _notifications.clear();
      _notifications.addAll(savedNotifications);
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount =>
      _notifications.where((n) => n['isRead'] == false).length;

  Future<void> showNotification({
    required String title,
    required String message,
    String? type,
    Duration? duration,
    bool saveToDb = true,
  }) async {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type ?? 'info',
      'isRead': false,
      'createdAt': DateTime.now(),
    };

    _notifications.insert(0, notification);

    if (saveToDb) {
      await _dbService.insertNotification(notification);
    }

    notifyListeners();

    if (duration != null) {
      await Future.delayed(duration);
      if (_notifications.contains(notification)) {
        removeNotification(notification['id'] as String);
      }
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
        await _dbService.updateNotificationReadStatus(notificationId, true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> removeNotification(String notificationId) async {
    try {
      _notifications.removeWhere((n) => n['id'] == notificationId);
      await _dbService.deleteNotification(notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing notification: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      _notifications.clear();
      await _dbService.clearAllNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
      await _dbService.markAllNotificationsAsRead();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> showBudgetAlert(String categoryName, double percent) async {
    if (percent >= 100) {
      await showNotification(
        title: 'Budget Exceeded',
        message: '$categoryName budget has been exceeded',
        type: 'error',
      );
    } else if (percent >= 80) {
      await showNotification(
        title: 'Budget Warning',
        message: '$categoryName budget is ${percent.toStringAsFixed(0)}% spent',
        type: 'warning',
      );
    }
  }

  Future<void> showTransactionSuccess(String action) async {
    await showNotification(
      title: 'Success',
      message: 'Transaction $action successfully',
      type: 'success',
    );
  }

  Future<void> showError(String message) async {
    await showNotification(title: 'Error', message: message, type: 'error');
  }
}

import 'package:flutter/foundation.dart';

class NotificationViewModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];
  final bool _isLoading = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount =>
      _notifications.where((n) => n['isRead'] == false).length;

  Future<void> showNotification({
    required String title,
    required String message,
    String? type,
    Duration? duration,
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
    notifyListeners();

    if (duration != null) {
      await Future.delayed(duration);
      removeNotification(notification['id'] as String);
    }
  }

  void markAsRead(String notificationId) {
    try {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void removeNotification(String notificationId) {
    try {
      _notifications.removeWhere((n) => n['id'] == notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing notification: $e');
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  Future<void> showBudgetAlert(String categoryName, double percent) async {
    if (percent >= 100) {
      await showNotification(
        title: 'Budget Exceeded',
        message: '$categoryName budget has been exceeded',
        type: 'error',
        duration: const Duration(seconds: 5),
      );
    } else if (percent >= 80) {
      await showNotification(
        title: 'Budget Warning',
        message: '$categoryName budget is ${percent.toStringAsFixed(0)}% spent',
        type: 'warning',
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> showTransactionSuccess(String action) async {
    await showNotification(
      title: 'Success',
      message: 'Transaction $action successfully',
      type: 'success',
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> showError(String message) async {
    await showNotification(
      title: 'Error',
      message: message,
      type: 'error',
      duration: const Duration(seconds: 5),
    );
  }
}

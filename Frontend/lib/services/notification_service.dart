import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static const String _channelId = 'finora_channel';
  static const String _channelName = 'Finora Notifications';
  static const String _channelDescription =
      'Notifications for budget alerts and reminders';

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings: initSettings);

    _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  Future<void> showBudgetAlert({
    required String categoryName,
    required double spent,
    required double limit,
  }) async {
    final percentage = (spent / limit * 100).toStringAsFixed(0);

    if (spent >= limit) {
      await showNotification(
        id: 1,
        title: 'Budget Exceeded',
        body: '$categoryName budget (Rp $limit) exceeded with Rp $spent spent',
        payload: 'budget_exceeded',
      );
    } else if (spent >= limit * 0.8) {
      await showNotification(
        id: 1,
        title: 'Budget Warning',
        body:
            '$categoryName budget is $percentage% spent (Rp $spent / Rp $limit)',
        payload: 'budget_warning',
      );
    }
  }

  Future<void> showTransactionNotification(
    String action, {
    required double amount,
    required String category,
  }) async {
    await showNotification(
      id: 2,
      title: 'Transaction $action',
      body: '$action Rp $amount in $category',
      payload: 'transaction_$action',
    );
  }

  Future<void> showSavingGoalReminder({
    required String goalName,
    required double remaining,
  }) async {
    await showNotification(
      id: 3,
      title: 'Saving Goal Reminder',
      body: '$goalName: Rp $remaining remaining to reach target',
      payload: 'saving_reminder',
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

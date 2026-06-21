import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'database_service.dart';

// Top-level plugin instance — accessible from background isolate
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const _channelId = 'finora_channel';
const _channelName = 'Finora Notifications';
const _channelDesc = 'Budget alerts, transaction updates, saving reminders';

/// Must be top-level for background isolate
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Already initialized or platform issue
  }

  await _showLocalNotification(message);

  // Save to database in background
  if (message.notification != null) {
    try {
      final dbService = DatabaseService();
      await dbService.insertNotification({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': message.notification!.title ?? 'Notification',
        'message': message.notification!.body ?? '',
        'type': message.data['type']?.toString() ?? 'info',
        'isRead': false,
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      // Error in background - ignore/log
    }
  }
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  const androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDesc,
    importance: Importance.max,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  // v20.1.0: all parameters are named
  await _localNotifications.show(
    id: notification.hashCode,
    title: notification.title,
    body: notification.body,
    notificationDetails: details,
    payload: jsonEncode(message.data),
  );
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _deviceToken;
  bool _isInitialized = false;

  // Simpan subscription agar bisa di-cancel sebelum re-register
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<String>? _onTokenRefreshSubscription;

  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessageStream => _messageStreamController.stream;

  String? get deviceToken => _deviceToken;

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  /// Inisialisasi plugin notifikasi lokal — panggil satu kali di main()
  static Future<void> initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // v20.1.0: initialize takes positional InitializationSettings
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Buat Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.max,
          ),
        );
  }

  /// Panggil setelah user berhasil login dengan userId yang sesungguhnya.
  /// Aman dipanggil berkali-kali — listener lama akan di-cancel terlebih dahulu.
  Future<void> initialize({required String userId}) async {
    // Jika sudah diinisialisasi untuk userId yang sama, skip
    if (_isInitialized) {
      debugPrint("FCM already initialized, skipping duplicate initialize() call");
      return;
    }

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    _deviceToken = await _messaging.getToken();
    if (_deviceToken != null) {
      await _registerToken(userId: userId, token: _deviceToken!);
    }

    // Cancel listener lama sebelum daftar yang baru
    await _onTokenRefreshSubscription?.cancel();
    _onTokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) {
      _deviceToken = newToken;
      _registerToken(userId: userId, token: newToken);
    });

    // Cancel listener foreground lama
    await _onMessageSubscription?.cancel();
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((message) async {
      _showLocalNotification(message);

      // Simpan ke database
      if (message.notification != null) {
        try {
          final dbService = DatabaseService();
          await dbService.insertNotification({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'title': message.notification!.title ?? 'Notification',
            'message': message.notification!.body ?? '',
            'type': message.data['type']?.toString() ?? 'info',
            'isRead': false,
            'createdAt': DateTime.now(),
          });
        } catch (e) {
          debugPrint("Error saving foreground notification: $e");
        }
      }

      _messageStreamController.add(message);
    });

    // Background tap — onMessageOpenedApp adalah broadcast stream, tidak perlu cancel
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    _isInitialized = true;
  }

  Future<void> _registerToken({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/fcm/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'fcmToken': token,
          'deviceName': kIsWeb
              ? 'web'
              : Platform.isAndroid
              ? 'android'
              : 'ios',
          'deviceInfo': kIsWeb ? 'web' : Platform.operatingSystemVersion,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("FCM Token registered successfully for user: $userId");
      } else {
        debugPrint(
          "FCM Registration failed with status: ${response.statusCode}",
        );
        debugPrint("Response: ${response.body}");
      }
    } catch (e) {
      debugPrint("FCM Registration error: $e");
      // Gagal registrasi — tidak kritis, akan retry saat token refresh
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    switch (message.data['type']) {
      case 'budget_alert':
      case 'transaction_update':
      case 'saving_reminder':
        // Navigasi bisa ditambahkan di sini
        break;
    }
  }

  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _deviceToken = null;
  }

  /// Reset state inisialisasi — panggil saat logout agar login berikutnya
  /// dapat memanggil initialize() dari awal dan mendaftarkan listener baru.
  void resetInitialized() {
    _onMessageSubscription?.cancel();
    _onMessageSubscription = null;
    _onTokenRefreshSubscription?.cancel();
    _onTokenRefreshSubscription = null;
    _isInitialized = false;
    _deviceToken = null;
  }
}

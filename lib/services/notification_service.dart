import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // Request permission for notifications
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Create notification channels
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'login_channel',
            'Login Notifications',
            importance: Importance.high,
            enableVibration: true,
          ),
        );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            enableVibration: true,
          ),
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _handleNotificationTap(response);
      },
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: message.data.toString(),
      ));
    });

    // Get initial FCM token and save it
    await saveNewToken();

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      saveNewToken();
    });
  }

  Future<void> saveNewToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('Cannot save token: No user logged in');
        return;
      }

      final token = await _firebaseMessaging.getToken();
      if (token == null) {
        print('Cannot save token: Failed to get FCM token');
        return;
      }

      print('Got FCM token: $token');

      // Dapatkan dokumen user saat ini
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      // Dapatkan array token yang ada (jika ada)
      List<String> existingTokens = [];
      if (userDoc.exists && userDoc.data()!.containsKey('fcmTokens')) {
        existingTokens = List<String>.from(userDoc.data()!['fcmTokens']);
      }

      // Cek apakah token sudah ada
      if (!existingTokens.contains(token)) {
        existingTokens.add(token);
        
        // Update dokumen dengan array token yang baru
        await _firestore.collection('users').doc(user.uid).set({
          'fcmTokens': existingTokens,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        print('FCM Token saved successfully. Total tokens: ${existingTokens.length}');
      } else {
        print('Token already exists in database');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  Future<void> removeCurrentToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final token = await _firebaseMessaging.getToken();
      if (token == null) return;

      // Hapus token saat ini dari array
      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });

      // Hapus token dari device
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      print('Error removing FCM token: $e');
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      // Handle notification tap based on payload
      // Contoh: navigasi ke halaman tertentu
      final data = response.payload!;
      if (data.contains('todoId')) {
        // Navigate to specific todo
        // Get.toNamed('/todo/detail', arguments: {'id': todoId});
      }
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  // Fungsi untuk menampilkan notifikasi login berhasil
  Future<void> showLoginSuccessNotification(String userName) async {
    try {
      print('Attempting to show login notification for user: $userName');
      
      await _flutterLocalNotificationsPlugin.show(
        0,
        'Login Berhasil',
        'Selamat datang kembali, $userName!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'login_channel',
            'Login Notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            channelShowBadge: true,
            enableVibration: true,
            enableLights: true,
          ),
        ),
      );
      
      print('Login notification shown successfully');
    } catch (e) {
      print('Error showing login notification: $e');
    }
  }
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inisialisasi Firebase untuk background handler
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}
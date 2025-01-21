import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null, // null = default app icon
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableVibration: true,
          playSound: true,
        ),
      ],
    );

    // Request notification permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Request FCM permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle FCM background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle FCM foreground messages
    FirebaseMessaging.onMessage.listen(_handleFCMMessage);

    // Handle when app is opened from notification
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        // Handle notification tap
        if (receivedAction.payload?['type'] == 'login_success') {
          Get.toNamed('/todo'); // Sesuaikan dengan route yang diinginkan
        }
      },
    );

    // Get initial FCM token and save it
    await saveNewToken();

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      saveNewToken();
    });
  }

  Future<void> _handleFCMMessage(RemoteMessage message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.hashCode,
        channelKey: 'basic_channel',
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: message.data.map((key, value) => MapEntry(key, value?.toString())),
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // Fungsi untuk menampilkan notifikasi login berhasil
  Future<void> showLoginSuccessNotification(String userName) async {
    try {
      print('Attempting to show login notification for user: $userName');
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'basic_channel',
          title: 'Login Berhasil! 🎉',
          body: 'Selamat datang kembali, $userName!',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Social,
          wakeUpScreen: true,
          payload: {'type': 'login_success'},
        ),
      );
      
      print('Login notification shown successfully');
    } catch (e) {
      print('Error showing login notification: $e');
    }
  }

  // Token management methods
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

      print('FCM Token: $token');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      List<String> existingTokens = [];
      if (userDoc.exists && userDoc.data()!.containsKey('fcmTokens')) {
        existingTokens = List<String>.from(userDoc.data()!['fcmTokens']);
      }

      if (!existingTokens.contains(token)) {
        existingTokens.add(token);
        await _firestore.collection('users').doc(user.uid).set({
          'fcmTokens': existingTokens,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('FCM Token saved successfully. Total tokens: ${existingTokens.length}');
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

      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });

      await _firebaseMessaging.deleteToken();
    } catch (e) {
      print('Error removing FCM token: $e');
    }
  }
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  // Show notification using Awesome Notifications
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: message.hashCode,
      channelKey: 'basic_channel',
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
      notificationLayout: NotificationLayout.Default,
    ),
  );
}
import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lesson3/controller/firestore_controller.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  BuildContext? context;

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init(BuildContext context) async {
    this.context = context;

    if (Platform.isIOS) {
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('User granted permission: ${settings.authorizationStatus}');
    }

    await firebaseMessaging.getToken().then((token) {
      FirestoreController.addFirebaseMessagingToken(token!);
    });

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOs,
    );

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: selectNotification);

    // get messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        showNotification(message);
        // showBigPictureNotification(message)  ;
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("On Message Opened App");
      print(message.data);
      _serializeAndNavigate(message, context);
    });

    _initialized = true;
  }

  void showNotification(RemoteMessage message) async {
    var android = AndroidNotificationDetails(
      message.messageId!,
      'Android Channel',
      channelDescription: 'FCM Notification',
      priority: Priority.high,
      importance: Importance.max,
      styleInformation: BigTextStyleInformation(message.notification!.body!),
      enableVibration: true,
      enableLights: true,
    );

    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin.show(
      Random.secure().nextInt(100),
      message.notification!.title,
      message.notification!.body,
      platform,
      payload: message.data.toString(),
    );
  }

  void _serializeAndNavigate(RemoteMessage message, BuildContext context) {
    var notificationData = message.data;
    var view = notificationData['view'];

    if (view != null) {
      Navigator.pushNamed(context, view);
    }
  }

  void selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
      // await Navigator.pushNamed(context!, 'update');
    }
  }
}

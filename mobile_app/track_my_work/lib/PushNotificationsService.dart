import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class PushNotificationManager {
  final FirebaseMessaging _fcm;
  final Function onNotificationPressed;
  final Function onNotificationShown;
  final Function onBackgroundNotification;

  String _token;

  PushNotificationManager(
      this._fcm,
      this.onNotificationPressed,
      this.onNotificationShown,
      this.onBackgroundNotification,
      );

  Future<PushNotificationManager> initialise() async {

    if (Platform.isIOS) {
      _fcm.requestPermission();
    }

    // If you want to test the push notification locally,
    // you need to get the token and input to the Firebase console
    // https://console.firebase.google.com/project/YOUR_PROJECT_ID/notification/compose

    _token = await _fcm.getToken();
    _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true
    );

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      // TODO: handle the received notifications
    } else {
      print('User declined or has not accepted permission');
    }

    print("FirebaseMessaging token: $_token");
    // var response = await request.putFcmToken(user.id, token, await user.authProvider.getIdToken());
    // print(response.body);
    // print(response.request.url);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification!');
      print(message.notification.title);
      print(message.notification.body);
      print(message.data);
      print(message.contentAvailable);
      onNotificationShown(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notification!' + message.notification.title);
      print(message.notification.title);
      print(message.notification.body);
      print(message.data);
      onNotificationShown(message);
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) {
      print('Notification!' + message.notification.title);
      print(message.notification.title);
      print(message.notification.body);
      print(message.data);
      onBackgroundNotification();
      return;
    });

    return this;
  }

  Future<String> getToken() async {
    return await _fcm.getToken();
  }

}
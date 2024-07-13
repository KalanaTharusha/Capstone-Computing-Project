import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../firebase_options.dart';
import '../main.dart';

class FcmService {
  Future<void> initFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print(
          'User declined permission, Please enable permission from settings in order for FCM to work.');
    }

    if (kIsWeb) {
      await messaging.deleteToken();
      getToken();
    } else {
      Platform.isIOS ? checkAPNSAndGetToken() : getToken();
    }

    messaging.onTokenRefresh.listen((fcmToken) async {
      await updateToken(fcmToken);
      await storage.write(key: "fcmToken", value: fcmToken);
    }).onError((err) {});
  }

  getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      final fcmToken = kIsWeb
          ? await messaging.getToken(
              vapidKey:
                  "BLPjse_xfiFNzrSVTVsfxjQygq41wgi0V1g6YCiUvtzGNNSOw0SemzE5as5-Iay_c9yncibD2FXiVdwgqgJRAp4")
          : await messaging.getToken();

      await storage.write(key: "fcmToken", value: fcmToken);
    } catch (e) {
      print(e);
    }
  }

  checkAPNSAndGetToken() async {
    // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      getToken();
    }
  }

  registerToken({int attempt = 0}) async {
    String? userId = await storage.read(key: 'userId');
    String? fcmtoken = await storage.read(key: 'fcmToken');
    String? jwt = await storage.read(key: 'jwt');

    if (fcmtoken == null && attempt < 5) {
      print('FCM Token not found, getting new token');
      await getToken();
      registerToken(attempt: attempt + 1);
      return;
    } else if (fcmtoken == null && attempt >= 5) {
      print('Error while acquiring FCM token, please try again later.');
      return;
    }

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/fcm/register';

    try {
      await http
          .post(Uri.parse(url),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer ${jwt.toString()}',
              },
              body: jsonEncode(<String, String>{
                'userId': userId.toString(),
                'fcmToken': fcmtoken.toString(),
              }))
          .then((response) {
        if (response.statusCode == 200) {
          print('FCM Registered');
        } else {
          print('Request unsucessful ' + response.body);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  updateToken(String token) async {
    String? jwt = await storage.read(key: 'jwt');
    String? oldToken = await storage.read(key: 'fcmToken');

    if (oldToken == null) {
      print('Old FCM Token not found, registering new token');
      await registerToken();
      return;
    }

    final url =
        '${dotenv.env[kIsWeb || Platform.isIOS ? 'BASE_URL_W' : 'BASE_URL_M']}/api/fcm/update';

    try {
      await http
          .patch(Uri.parse(url),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer ${jwt.toString()}',
              },
              body: jsonEncode(<String, String>{
                'oldFcmToken': oldToken.toString(),
                'newFcmToken': token,
              }))
          .then((response) {
        if (response.statusCode == 200) {
          print('FCM token Updated');
        } else {
          print('Request unsucessful ' + response.body);
        }
      });
    } catch (e) {
      print(e);
    }
  }
}

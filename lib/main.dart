import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasteexpert/pages/authentication/login.dart';
import 'package:wasteexpert/pages/home.dart';
import 'package:wasteexpert/pages/main_page.dart';
import 'package:wasteexpert/pages/notifications/notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await Firebase.initializeApp();
  FirebaseMessaging.instance.getToken().then((value) {
    print("get Token: $value");
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print(message);
    Navigator.pushNamed(navigatorKey.currentState!.context, '/push-page',
        arguments: {"message": json.encode(message.data)});
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      Navigator.pushNamed(navigatorKey.currentState!.context, '/push-page',
          arguments: {"message": json.encode(message.data)});
    }
  });

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");
  runApp(MyApp(
    token: token,
  ));
}



class MyApp extends StatelessWidget {
  final String? token; // Token can be null
  const MyApp({@required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 123, 83, 193)),
        useMaterial3: true,
      ),
      home: (token != null && !JwtDecoder.isExpired(token!))
          ? HomePage(token: token!)
          : const Login(),
      navigatorKey: navigatorKey,
      // routes: {
      //   '/push-page': ((context) => const Notifications()),
      //   '/': ((context) => HomePage(token: token!))
      // },
    );
  }
}

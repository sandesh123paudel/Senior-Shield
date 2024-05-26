import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:get/get.dart';
import 'package:seniorshield/constants/colors.dart';
import 'package:seniorshield/services/local_notifications.dart';
import 'package:seniorshield/views/home_screen/home.dart';
import 'package:seniorshield/views/splash_screen/splash1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/apis.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest_all.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebase();
  tz.initializeTimeZones();
  await NotificationHeleper.init();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isNewUser = prefs.getBool('isNewUser') ?? true;
  if (isNewUser) {
    prefs.setBool('isNewUser', false);
  } else {
    // Check if the user is authenticated before calling getSelfInfo
    if (APIs.auth.currentUser != null) {
      await APIs.getSelfInfo();
    }
  }

  SystemChannels.lifecycle.setMessageHandler((message) {
    if (APIs.auth.currentUser != null) {
      if (message!.contains('pause')) {
        APIs.updateActiveStatus(false);
      }
      if (message.contains('resume')) {
        APIs.updateActiveStatus(true);
      }
    }
    return Future.value(message);
  });

  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({required this.isLoggedIn, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Senior Shield',
      theme: ThemeData(
        scaffoldBackgroundColor: kDefaultIconLightColor,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        timePickerTheme: TimePickerThemeData(
          confirmButtonStyle: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(kDefaultIconLightColor),
            backgroundColor: MaterialStateProperty.all(kPrimaryColor),
            overlayColor: MaterialStateProperty.all(kPrimaryColor),
          ),
          cancelButtonStyle: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(kDefaultIconLightColor),
            backgroundColor: MaterialStateProperty.all(kPrimaryColor),
            overlayColor: MaterialStateProperty.all(kPrimaryColor),
          ),
          backgroundColor: kDefaultIconLightColor,
          hourMinuteColor: kPrimaryColor,
          dialHandColor: kPrimaryColor,
          dialBackgroundColor: Colors.white,
          entryModeIconColor: kPrimaryColor,
          hourMinuteTextColor: kDefaultIconLightColor,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: kPrimaryColor),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? Home() : Splash1(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'seniorshield',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    enableSound: true,
    allowBubbles: true,
    name: 'SeniorShield',
  );

  log('\nNotification Channel Result: $result');
}

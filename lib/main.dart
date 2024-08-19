import 'package:MediansSchoolDriver/Pages/HomePage.dart';
import 'package:MediansSchoolDriver/Pages/LoginPage.dart';
import 'package:MediansSchoolDriver/Pages/StudentPage.dart';
import 'package:MediansSchoolDriver/Pages/SettingsPage.dart';
import 'package:MediansSchoolDriver/controllers/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:MediansSchoolDriver/controllers/locale.dart';
import 'package:MediansSchoolDriver/Pages/GetStarted.dart';
import 'package:MediansSchoolDriver/Pages/EventPage.dart';
import 'package:MediansSchoolDriver/Pages/SplashScreenPage.dart';
import 'package:MediansSchoolDriver/Pages/NotificationsPage.dart';
import 'package:localstorage/localstorage.dart';


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = Get.put(LocaleController());
  await localeController.loadSavedLocale();
  Get.put(PreferencesSetting());
  runApp( MyApp());
}

ThemeData? themeData;

class MyApp extends StatelessWidget {

  final LocaleController localeController = Get.find<LocaleController>();
  final PreferencesSetting preferences = Get.find<PreferencesSetting>();

  final LocalStorage storage = LocalStorage('tokens.json');

  MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      transitionDuration: const Duration(seconds: 2),
      title: 'Medians',
      locale: localeController.selectedLocale.value,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), 
      routes: {
        '/get_started':(p0) => GetStartedApp(),
        '/login':(p0) => Login(),
        '/home':(p0) => HomePage(),
        '/event':(p0) => EventPage(),
        '/setting':(p0) => SettingsPage(),
        '/student':(p0) => StudentPage(),
        '/notifications':(p0) => NotificationsPage(),
      }
    );
  }

  
}

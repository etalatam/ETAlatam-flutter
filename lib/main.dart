import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/splash_screen_page.dart';
import 'package:eta_school_app/Pages/home_screen.dart';
import 'package:eta_school_app/controllers/preferences.dart';
import 'package:eta_school_app/providers/theme_provider.dart';
import 'package:eta_school_app/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/controllers/locale.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'shared/emitterio/emitter_service.dart';
import 'shared/fcm/notification_service.dart';
import 'shared/location/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar StorageService antes que cualquier otro servicio
  await StorageService.instance.init();
  print('[main] StorageService inicializado');

  final locationService = LocationService.instance;
  print('Main location service instance: ${locationService.instanceId}');

  await Firebase.initializeApp();
  final localeController = Get.put(LocaleController());

  await localeController.loadSavedLocale();
  Get.put(PreferencesSetting());

  MapboxOptions.setAccessToken(
      "sk.eyJ1IjoiZWxpZ2FiYXkiLCJhIjoiY20xMm1nYTA4MHV1cjJscXlocXA0MW5zciJ9.N3pZgESYISIcM3dlWrdgTQ");
 
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => locationService),
        ChangeNotifierProvider(create: (context) => EmitterService.instance),
        ChangeNotifierProvider(
            create: (context) => NotificationService.instance),
      ],
      child: MyApp(),
    ),
  );
}

ThemeData? themeData;

class MyApp extends StatelessWidget {
  final LocaleController localeController = Get.find<LocaleController>();
  final PreferencesSetting preferences = Get.find<PreferencesSetting>();
  final LocalStorage storage = LocalStorage('tokens.json');

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GetMaterialApp(
          // transitionDuration: const Duration(seconds: 2), // agrega la duracion de la transición
          title: 'ETA',
          locale: localeController.selectedLocale.value,
          debugShowCheckedModeBanner: false,
          theme: ThemeProvider.lightTheme(),
          darkTheme: ThemeProvider.darkTheme(),
          themeMode: themeProvider.themeMode,
          initialRoute: '/splash',
          getPages: [
            GetPage(
              name: '/splash',
              page: () {
                return SplashScreen();
              },
              children: [
                GetPage(
                  name: '/home/:page',
                  page: () {
                    return HomeScreen();
                  },
                ),
                GetPage(
                  name: '/login',
                  page: () {
                    return Login();
                  },
                ),
              ],
            ),
            GetPage(
              name: '/',
              page: () => Container(), // No se renderizará esta página
              middlewares: [
                RedirectMiddleware(),
              ],
            ),
          ],
        );
      },
    );
  }
}

class RedirectMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Redirecciona a '/home/0' cuando se accede a '/'
    return RouteSettings(name: '/splash');
  }
}

import 'dart:async';

import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/gets_started.dart';
import 'package:eta_school_app/Pages/home_screen.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 2), () => logInCheck());
    super.initState();
  }

  logInCheck() async {
    final check = await storage.getItem('token');
    if (check != null) {
      Get.offAll(() => HomeScreen());
    } else {
      final started = await preferences.getBool('started');
      Get.off(() => started != null ? Login() : GetStartedApp());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: activeTheme.main_bg,
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image(
              // image: AssetImage("assets/slides/slide3.png"),
              image: AssetImage("assets/logo.png"),
            ),
          ),
        ],
      ),
    );
  }
}

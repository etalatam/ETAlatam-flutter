import 'package:MediansSchoolDriver/Pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:MediansSchoolDriver/controllers/page_controller.dart' as p;
import 'package:MediansSchoolDriver/Pages/HelpPage.dart';
import 'package:MediansSchoolDriver/Pages/SettingsPage.dart';
import 'package:MediansSchoolDriver/Pages/map/map_view.dart';
import 'package:MediansSchoolDriver/shared/widgets/custom_bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';

  final p.PageController _pageController = Get.put(p.PageController());

  final viewRoutes = const <Widget>[
    SettingsPage(),
    HomePage(),
    // MapView(),
    SendMessagePage(),
  ];

  @override
  Widget build(BuildContext context) {
    print(
        " _pageController.currentIndex.value: ${_pageController.currentIndex.value}");
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: _pageController.currentIndex.value,
            children: viewRoutes,
          )),
      bottomNavigationBar: CustomBottonNavigation(),
    );
  }
}

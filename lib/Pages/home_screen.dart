import 'dart:js';

import 'package:MediansSchoolDriver/Pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:MediansSchoolDriver/controllers/page_controller.dart' as p;
import 'package:MediansSchoolDriver/Pages/HelpPage.dart';
import 'package:MediansSchoolDriver/Pages/SettingsPage.dart';
import 'package:MediansSchoolDriver/Pages/map/map_view.dart';
import 'package:MediansSchoolDriver/shared/widgets/custom_bottom_navigation.dart';

import '../components/WillPopScopeWidget.dart';

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
    return WillPopScopeWidget(
      onWillPop: _handlePop,
      child: Scaffold(
      body: Obx(() => IndexedStack(
            index: _pageController.currentIndex.value,
            children: viewRoutes,
          )),
      bottomNavigationBar: CustomBottonNavigation(),
    ));
  }

  Future<bool> _handlePop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you shure?'),
        content: Text('Do you whan exit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              // if (isAndroid) {
                // SystemNavigator.pop();
              // }
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}

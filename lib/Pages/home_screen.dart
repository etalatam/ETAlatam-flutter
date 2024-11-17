
import 'package:eta_school_app/Pages/home_page.dart';
import 'package:eta_school_app/Pages/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/controllers/page_controller.dart' as p;
import 'package:eta_school_app/Pages/help_page.dart';
import 'package:eta_school_app/Pages/settings_page.dart';
import 'package:eta_school_app/shared/widgets/custom_bottom_navigation.dart';


class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';

  final p.PageController _pageController = Get.put(p.PageController());

  final viewRoutes = const <Widget>[
    SettingsPage(),
    HomePage(),
    // MapView(),
    NotificationsPage(),
    SendMessagePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // return WillPopScopeWidget(
    //   onWillPop: _hwandlePop,
      // child: 
      return Scaffold(
      body: Obx(() => IndexedStack(
            index: _pageController.currentIndex.value,
            children: viewRoutes,
          )),
      bottomNavigationBar: CustomBottonNavigation(),
    // )
    );
  }

  // Future<bool> _handlePop() async {
  //   return await showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Are you shure?'),
  //       content: Text('Do you whan exit?'),
  //       actions: <Widget>[
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: Text('No'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(true);
  //             // if (isAndroid) {
  //               // SystemNavigator.pop();
  //             // }
  //           },
  //           child: Text('Yes'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

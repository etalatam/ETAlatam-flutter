
import 'package:eta_school_app/Pages/driver_home.dart';
import 'package:eta_school_app/Pages/guardians_home.dart';
import 'package:eta_school_app/Pages/notifications_page.dart';
import 'package:eta_school_app/Pages/students_home.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/controllers/page_controller.dart' as p;
import 'package:eta_school_app/Pages/help_page.dart';
import 'package:eta_school_app/Pages/settings_page.dart';
import 'package:eta_school_app/shared/widgets/custom_bottom_navigation.dart';

class HomeScreen extends StatelessWidget {

  final p.PageController _pageController = Get.put(p.PageController());

  final Map<String, List<Widget>> widgetMap = {
    "eta.drivers": [
      SettingsPage(),
      DriverHome(),
      NotificationsPage(),
      SendMessagePage()
    ],
    "eta.students": [
      SettingsPage(),
      StudentsHome(),
      NotificationsPage(),
      SendMessagePage()
    ],
    "eta.guardians": [
      SettingsPage(),
      GuardiansHome(),
      NotificationsPage(),
      SendMessagePage()
    ]
  };

  final List<Widget> defaultWidgets = [
    SettingsPage(),
    NotificationsPage(),
  ];

  List<Widget>? getWidgetsByKey(String key) {
    return widgetMap[key];
  }

  Future<String> fetchStoredValue() async {
    return await storage.getItem('user_relation_name');
  }

  @override
  Widget build(BuildContext context)  {
      return FutureBuilder<String?>(
        future: fetchStoredValue(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final userRelationName = snapshot.data!;

            return Scaffold(
              bottomNavigationBar: CustomBottonNavigation(),
              body: Obx(() => IndexedStack(
                    index: _pageController.currentIndex.value,
                    children: getWidgetsByKey(userRelationName) ?? defaultWidgets,
                  )),
            );
          }
        },
    );
  }
}

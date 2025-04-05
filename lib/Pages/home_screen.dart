import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/Pages/attendance_page.dart';
import 'package:eta_school_app/Pages/driver_home.dart';
import 'package:eta_school_app/Pages/guardians_home.dart';
import 'package:eta_school_app/Pages/monitor_home.dart';
import 'package:eta_school_app/Pages/no_active_trip_page.dart';
import 'package:eta_school_app/Pages/notifications_page.dart';
import 'package:eta_school_app/Pages/students_home.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/controllers/page_controller.dart' as p;
import 'package:eta_school_app/Pages/help_page.dart';
import 'package:eta_school_app/Pages/settings_page.dart';
import 'package:eta_school_app/shared/widgets/custom_bottom_navigation.dart';

import '../components/loader.dart';

class HomeScreen extends StatelessWidget {
  final p.PageController _pageController = Get.put(p.PageController());
  final HttpService _httpService = HttpService();

    Map<String, List<Widget>> _buildWidgetMap() {
    return {
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
      ],
      "eta.monitor": [
        SettingsPage(),
        _buildMonitorHome(), // Ahora accesible
        NotificationsPage(),
        SendMessagePage()
      ]
    };
  }
  final List<Widget> defaultWidgets = [
    SettingsPage(),
    NotificationsPage(),
  ];

  List<Widget>? getWidgetsByKey(String key) {
    return _buildWidgetMap()[key];
  }

  Future<Map<String, dynamic>> fetchStoredValue() async {
    final relationName = await storage.getItem('relation_name');
    final isMonitor = await storage.getItem('monitor');
    return {
      'relation_name': relationName,
      'monitor': isMonitor,
    };
  }

  Future<List<TripModel>> _loadTripRunning() async {
    try {
      final trips = await _httpService.getMonitorActiveTrips();
      return trips;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchStoredValue(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          String userRelationName = snapshot.data!['relation_name']!;
          final isMonitor = snapshot.data!['monitor'] ?? false;
          if(isMonitor && userRelationName=='eta.employees'){
            userRelationName = 'eta.monitor';
          }
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

  
  Widget _buildMonitorHome() {
    return FutureBuilder<List<TripModel>>(
      future: _loadTripRunning(), // Función que verifica el viaje activo
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Loader());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar el viaje'));
        } else if (snapshot.data!.isNotEmpty) {
          return MonitorHome(trip: snapshot.data![0]); // AttendancePage(trip: snapshot.data![0]); // Mostrar lista de asistencia
        } else {
          return NoActiveTripPage(); // Mostrar mensaje "No hay viaje activo"
        }
      },
    );
  }
}

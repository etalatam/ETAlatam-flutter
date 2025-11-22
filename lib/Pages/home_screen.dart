import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/Pages/attendance_page.dart';
import 'package:eta_school_app/Pages/driver_home.dart';
import 'package:eta_school_app/Pages/guardians_home.dart';
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/monitor_home.dart';
import 'package:eta_school_app/Pages/no_active_trip_page.dart';
import 'package:eta_school_app/Pages/notifications_page.dart';
import 'package:eta_school_app/Pages/students_home.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/controllers/page_controller.dart' as p;
import 'package:eta_school_app/Pages/support_messages_unified_page.dart';
import 'package:eta_school_app/Pages/settings_page.dart';
import 'package:eta_school_app/shared/widgets/custom_bottom_navigation.dart';

import '../components/loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final p.PageController _pageController = Get.put(p.PageController());
  final HttpService _httpService = HttpService();
  bool _syncCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkAndSyncNotifications();
  }

  /// Verificar y sincronizar notificaciones al iniciar la app
  Future<void> _checkAndSyncNotifications() async {
    try {
      final token = await storage.getItem('token');
      if (token != null && !_syncCompleted) {
        print("[HomeScreen] Verificando sincronización de notificaciones");

        // Sincronizar grupos si hay cambios
        await NotificationService.instance.syncGroups();

        setState(() {
          _syncCompleted = true;
        });

        print("[HomeScreen] Sincronización de notificaciones completada");
      }
    } catch (e) {
      print("[HomeScreen] Error en sincronización: $e");
    }
  }

    Map<String, List<Widget>> _buildWidgetMap() {
    return {
      "eta.drivers": [
        SettingsPage(),
        DriverHome(),
        NotificationsPage(),
        SupportMessagesUnifiedPage()
      ],
      "eta.students": [
        SettingsPage(),
        StudentsHome(),
        NotificationsPage(),
        SupportMessagesUnifiedPage()
      ],
      "eta.guardians": [
        SettingsPage(),
        GuardiansHome(),
        NotificationsPage(),
        SupportMessagesUnifiedPage()
      ],
      "eta.monitor": [
        SettingsPage(),
        _buildMonitorHome(), // Ahora accesible
        NotificationsPage(),
        SupportMessagesUnifiedPage()
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

  Future<Map<String, dynamic>> _fetchStoredValue() async {
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
      future: _fetchStoredValue(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          // Validar que relation_name existe antes de usar el operador !
          final relationName = snapshot.data!['relation_name'];
          if (relationName == null) {
            print('[HomeScreen] Error: relation_name is null, redirecting to login');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAll(() => Login());
            });
            return Center(child: CircularProgressIndicator());
          }

          String userRelationName = relationName;
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

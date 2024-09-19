import 'dart:async';
import 'package:MediansSchoolDriver/Models/RouteModel.dart';
import 'package:MediansSchoolDriver/Pages/HelpPage.dart';
import 'package:MediansSchoolDriver/Pages/LoginPage.dart';
import 'package:MediansSchoolDriver/Pages/TripPage.dart';
import 'package:MediansSchoolDriver/Pages/map/map_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:MediansSchoolDriver/Models/DriverModel.dart';
import 'package:MediansSchoolDriver/Models/TripModel.dart';
import 'package:MediansSchoolDriver/components/loader.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/components/Widgets.dart';
import 'package:MediansSchoolDriver/Models/EventModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with MediansWidgets, MediansTheme, WidgetsBindingObserver {
  final widgets = MediansWidgets;

  late GoogleMapController mapController;

  bool hasActiveTrip = false;

  DriverModel driverModel = DriverModel(driver_id: 0, first_name: '');
  TripModel? activeTrip;

  Location location = Location();

  bool showLoader = true;

  List<EventModel> eventsList = [];
  List<RouteModel> routesList = [];
  List<TripModel> oldTripsList = [];

  @override
  Widget build(BuildContext context) {
    activeTheme =
        storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();

    return showLoader
        ? Loader()
        : Material(
            type: MaterialType.transparency,
            child: Scaffold(
              body: Container()));
  }

  /// Create trip
  createTrip(routeId, vehicleId) async {
    setState(() {
      showLoader = true;
    });
    final driverId = await storage.getItem('driver_id');
    TripModel? createdTrip =
        await httpService.create_trip(driverId, routeId, vehicleId);

    if (createdTrip.trip_id != 0) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TripPage(trip: createdTrip)),
      );

      loadDriver();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is going to the background
      // Perform actions or handle behavior when the app loses focus
    } else if (state == AppLifecycleState.resumed) {
      // App is back to the foreground
      // Perform actions when the app comes back to the foreground
    }
  }

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    setState(() {
      showLoader = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      loadDriver();
    });
  }

  openPage(context, page) {
    setState(() => openNewPage(context, page));
  }

  ///
  /// Load devices through API
  ///
  loadDriver() async {
    Timer(const Duration(seconds: 2), () async {
      final check = await storage.getItem('driver_id');

      if (check == null) {
        Get.offAll(Login());
        return;
      }

      await storage.getItem('darkmode');
      setState(() {
        darkMode = storage.getItem('darkmode') == true ? true : false;
        showLoader = false;
      });
    });

    final eventsQuery = await httpService.getEvents();
    setState(() {
      eventsList = eventsQuery;
    });

    final driverId = await storage.getItem('driver_id');
    final driverQuery = await httpService.getDriver(driverId);
    setState(() {
      driverModel = driverQuery;
    });

    final routesQuery = await httpService.getRoutes();
    setState(() {
      routesList = routesQuery;
    });

    TripModel? activeTrip_ = await httpService.getActiveTrip();
    setState(() {
      activeTrip = activeTrip_;
      hasActiveTrip = (activeTrip_.trip_id != 0) ? true : false;
    });

    List<TripModel>? oldTrips = await httpService.getTrips(0);

    setState(() {
      oldTripsList = oldTrips;
    });
  }

  openTrip(TripModel trip) {
    Get.to(TripPage(trip: trip));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadDriver();
  }
}

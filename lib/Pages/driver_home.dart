import 'dart:async';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/trip_page.dart';
import 'package:eta_school_app/Pages/providers/location_service_provider.dart';
import 'package:eta_school_app/components/active_trip.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Models/driver_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/home_route_block.dart';
import 'package:eta_school_app/Models/EventModel.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome>
    with ETAWidgets, MediansTheme, WidgetsBindingObserver {
  final widgets = ETAWidgets;

  // late GoogleMapController mapController;

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
    return showLoader
        ? Loader()
        : Material(
            type: MaterialType.transparency,
            child: Scaffold(
                body: RefreshIndicator(
                    triggerMode: RefreshIndicatorTriggerMode.onEdge,
                    onRefresh: _refreshData,
                    child: Stack(
                      children: [
                        Container(
                            color: activeTheme.main_bg,
                            height: MediaQuery.of(context).size.height,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: 40),
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Stack(children: <Widget>[
                                Container(
                                  color: activeTheme.main_bg,
                                  margin: const EdgeInsets.only(top: 120),
                                  child: Column(children: [
                                    /// Has Active Trip
                                    !hasActiveTrip
                                        ? Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            margin: const EdgeInsets.fromLTRB(
                                                25, 0, 25, 10),
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              color: Color.fromARGB(
                                                  255, 228, 201, 119),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              shadows: [
                                                BoxShadow(
                                                  color: activeTheme.main_color
                                                      .withOpacity(.3),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 1),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                            ),
                                            child: Text(
                                                lang.translate(
                                                    "Does not have active trips"),
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 112, 88, 16),
                                                  fontSize:
                                                      activeTheme.h5.fontSize,
                                                  fontFamily:
                                                      activeTheme.h6.fontFamily,
                                                  fontWeight:
                                                      activeTheme.h6.fontWeight,
                                                )))
                                        : ActiveTrip(
                                            openTripCallback, activeTrip),

                                    ETAWidgets.svgTitle("assets/svg/route.svg",
                                        lang.translate("Routes")),

                                    const SizedBox(height: 10),

                                    /// Available Routes
                                    SizedBox(
                                        height: 260,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: routesList
                                                .length, // Replace with the total number of items
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        routesList.length < 2
                                                            ? 20
                                                            : 0),
                                                width: routesList.length < 2
                                                    ? MediaQuery.of(context)
                                                        .size
                                                        .width
                                                    : 400,
                                                // height: 400,
                                                child: HomeRouteBlock(
                                                    route: routesList[index],
                                                    callback: createTrip),
                                              );
                                            })),

                                    ETAWidgets.svgTitle("assets/svg/bus.svg",
                                        lang.translate('trips_history')),

                                    /// Last Trips
                                    oldTripsList.isEmpty
                                        ? const Center()
                                        : SizedBox(
                                            height: 238,
                                            child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: oldTripsList
                                                    .length, // Replace with the total number of items
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return GestureDetector(
                                                      onTap: () {
                                                        openNewPage(
                                                            context,
                                                            TripPage(
                                                              trip:
                                                                  oldTripsList[
                                                                      index],
                                                              navigationMode:
                                                                  "support",
                                                              showBus: false,
                                                              showStudents:
                                                                  false,
                                                            ));
                                                      },
                                                      child: ETAWidgets
                                                          .homeTripBlock(
                                                              context,
                                                              oldTripsList[
                                                                  index]));
                                                })),
                                    // const SizedBox(
                                    //   height: 30,
                                    // ),

                                    // Container(
                                    //   padding: const EdgeInsets.all(20),
                                    //   child: Text(
                                    //   "${lang.translate('Events and News')}",
                                    //   style: activeTheme.h3,
                                    //   textAlign: TextAlign.start,
                                    // )),

                                    /// Events carousel
                                    // Container(
                                    //   width: MediaQuery.of(context).size.width,
                                    //   alignment: Alignment.center,
                                    //   child:  ETAWidgets.eventCarousel(eventsList, context),
                                    // ),

                                    /// Help / Support Block
                                    // ETAWidgets.homeHelpBlock(),
                                  ]),
                                ),
                              ]),
                            )),
                        Positioned(left: 0, right: 0, top: 0, child: Header()),
                      ],
                    ))));
  }

  /// Create trip
  createTrip(RouteModel route) async {
    TripModel? trip;

    setState(() {
      showLoader = true;
    });

    try {
      trip = await httpService.startTrip(route);
      if (trip.trip_id != 0) {
        await locationServiceProvider.startLocationService();
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TripPage(
                    trip: trip,
                    navigationMode: "support",
                    showBus: false,
                    showStudents: false,
                  )),
        );
        loadResources();
      }
    } catch (e) {
      print(e.toString());
      var msg = e.toString().split('/');
      setState(() {
        showLoader = false;
      });
      showSuccessDialog(context, "${lang.translate('Error')} (${msg[1]})",
          lang.translate(msg[0]), null);
    }
  }

  void tracking() async {}

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

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      loadResources();
    });
  }

  openPage(context, page) {
    setState(() => openNewPage(context, page));
  }

  notificationSubcribe(String topic) {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      messaging.subscribeToTopic(topic);
    } catch (e) {
      print("DriverHome.notificationSubcribe.error: ${e.toString()}");
    }
  }

  ///
  /// Load resources through API
  ///
  loadResources() async {
    final check = await storage.getItem('id_usu');

    if (check == null) {
      Get.offAll(Login());
      return;
    }

    await locationServiceProvider.init();

    await storage.getItem('darkmode');
    setState(() {
      darkMode = storage.getItem('darkmode') == true ? true : false;
      showLoader = false;
    });

    final driverQuery = await httpService.getDriver();
    setState(() {
      driverModel = driverQuery;
    });

    final routesQuery = await httpService.getRoutes();
    List<String> routeTopics = [];
    for (var route in routesQuery) {
      notificationSubcribe("route-${route.route_id}");
      routeTopics.add("route-${route.route_id}");
    }
    storage.setItem('route-topics', routeTopics.toString());

    setState(() {
      routesList = routesQuery;
    });

    List<TripModel>? oldTrips = await httpService.getDriverTrips(0);
    setState(() {
      oldTripsList = oldTrips;
    });

    TripModel? activeTripWrapper = await httpService.getActiveTrip();
    setState(() {
      activeTrip = activeTripWrapper;
      hasActiveTrip = (activeTripWrapper.trip_id != 0) ? true : false;
    });

    if (hasActiveTrip) {
      await locationServiceProvider.startLocationService();
    }
  }

  openTripCallback(TripModel wrapper) {
    Get.to(TripPage(
      trip: wrapper,
      navigationMode: "support",
      showBus: false,
      showStudents: false,
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadResources();
  }
}

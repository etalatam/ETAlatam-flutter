import 'dart:async';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/trip_page.dart';
import 'package:eta_school_app/Pages/providers/location_service_provider.dart';
import 'package:eta_school_app/components/active_trip.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/components/header.dart';

class StudentsHome extends StatefulWidget {
  const StudentsHome({super.key});

  @override
  State<StudentsHome> createState() => _StudentsHomeState();
}

class _StudentsHomeState extends State<StudentsHome>
    with ETAWidgets, MediansTheme, WidgetsBindingObserver {
  final widgets = ETAWidgets;

  bool hasActiveTrip = false;

  // DriverModel driverModel = DriverModel(driver_id: 0, first_name: '');
  StudentModel student = StudentModel(student_id: 0, parent_id: 0);

  TripModel? activeTrip;

  Location location = Location();

  bool showLoader = true;

  // List<EventModel> eventsList = [];
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
                                    // Row(children:[ Container(
                                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                                    //   child: Text(
                                    //   "${lang.translate('welcome')}  ${driverModel.first_name!}",
                                    //   style: activeTheme.h4,
                                    //   textAlign: TextAlign.start,
                                    // ))]),

                                    /// Driver profile
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     openNewPage(context, ProfilePage());
                                    //   },
                                    //   child: profileInfoBlock(driverModel, context),
                                    // ),

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
                                        : ActiveTrip(openTrip, activeTrip),

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

                        // Positioned(
                        //   left: 0,
                        //   right: 0,
                        //   top: 0,
                        //   child: Header()
                        // ),
                        // Positioned(
                        //   bottom: 20,
                        //   left: 20,
                        //   right: 20,
                        //   child: BottomMenu('home', openNewPage)
                        // )
                      ],
                    ))));
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

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      loadResources();
    });
  }

  openPage(context, page) {
    setState(() => openNewPage(context, page));
  }

  ///
  /// Load resources through API
  ///
  loadResources() async {
    final studentId = await storage.getItem('relation_id');
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

    final studentQuery = await httpService.getStudent();
    setState(() {
      student = studentQuery;
    });

    List<TripModel>? oldTrips = await httpService.getStudentTrips(studentId);
    setState(() {
      oldTripsList = oldTrips;
    });

    TripModel? activeTrip_ = await httpService.getActiveTrip();
    setState(() {
      activeTrip = activeTrip_;
      hasActiveTrip = (activeTrip_.trip_id != 0) ? true : false;
    });

    if (hasActiveTrip) {
      await locationServiceProvider.startLocationService();

      String routeTopics = "";
      notificationSubcribe("route-${activeTrip?.route_id}");
      routeTopics += "route-${activeTrip?.route_id}";
      storage.setItem('route-topics', routeTopics);
    }
  }

  notificationSubcribe(String topic) {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      messaging.subscribeToTopic(topic);
    } catch (e) {
      print("StudentsHome.notificationSubcribe.error: ${e.toString()}");
    }
  }

  openTrip(TripModel trip) {
    Get.to(TripPage(
      trip: trip,
      showBus: true,
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

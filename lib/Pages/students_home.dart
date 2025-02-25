import 'dart:async';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/providers/notification_provider.dart';
import 'package:eta_school_app/Pages/trip_page.dart';
import 'package:eta_school_app/Pages/providers/location_service_provider.dart';
import 'package:eta_school_app/components/active_trip.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class StudentsHome extends StatefulWidget {
  const StudentsHome({super.key});

  @override
  State<StudentsHome> createState() => _StudentsHomeState();
}

class _StudentsHomeState extends State<StudentsHome>
    with ETAWidgets, MediansTheme {
  final widgets = ETAWidgets;

  bool hasActiveTrip = false;

  // DriverModel driverModel = DriverModel(driver_id: 0, first_name: '');
  StudentModel student =
      StudentModel(student_id: 0, parent_id: 0, pickup_points: []);

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
                    child: VisibilityDetector(
                          key: Key('student_home_key'),
                          onVisibilityChanged: (info) {
                            if (info.visibleFraction > 0) {
                              loadResources();
                            }
                          }, 
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
                                        : Consumer<EmitterService>(builder:
                                            (context, emitterService, child) {
                                            try {
                                              final jsonMessage =
                                                  emitterService.jsonMessage();
                                              final String type =
                                                  jsonMessage['event_type'];

                                              if (type == "end-trip") {
                                                setState(() {
                                                  loadResources();
                                                });
                                              }
                                            } catch (e) {
                                              print(e);
                                            }

                                            return ActiveTrip(
                                                openTripcallback, activeTrip);
                                          }),
                                    ETAWidgets.svgTitle("assets/svg/route.svg",
                                        lang.translate('trips_history')),

                                    /// Last Trips
                                    oldTripsList.isEmpty
                                        ? const Center()
                                        : SizedBox(
                                            height: 260,
                                            child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: oldTripsList.length,
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
                                                                  false,
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
                    )))));
  }

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    setState(() {
      showLoader = true;
    });

    loadResources();
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

    try {
      final studentQuery = await httpService.getStudent();
      if(mounted){
        setState(() {
          student = studentQuery;
        });
      }else{
        student = studentQuery;
      }
    } catch (e) {
      print("[StudentPage.loadResources.getstudents.error] $e");
    }

    try {
      List<TripModel>? oldTrips = await httpService.getStudentTrips(studentId);
      setState(() {
        oldTripsList = oldTrips;
      });
    } catch (e) {
      print("[StudentPage.loadResources.getstudents.error] $e");
    }

    try {
      TripModel? activeTrip_ = await httpService.getActiveTrip();
      if(mounted){
        setState(() {
          activeTrip = activeTrip_;
          hasActiveTrip = (activeTrip_.trip_id != 0) ? true : false;
        });
      }else{
        activeTrip = activeTrip_;
        hasActiveTrip = (activeTrip_.trip_id != 0) ? true : false;
      }

      if (hasActiveTrip) {
        activeTrip?.subscribeToTripTracking();
      }

      locationServiceProvider.startLocationService();
    } catch (e) {
      print("[StudentPage.loadResources.getActiveTrip.error] $e");
    }

    try {
      List<RouteModel> routes = await httpService.getStudentRoutes();
      for (var route in routes) {
        String routeTopic = "route-${route.route_id}-student";

        notificationServiceProvider.subscribeToTopic(routeTopic);

        for (var pickupPoint in student.pickup_points) {
          var pickupPointTopic =
              "route-${route.route_id}-pickup_point-${pickupPoint.pickup_id}";
          notificationServiceProvider.subscribeToTopic(pickupPointTopic);
        }
      }

    } catch (e) {
      print("[StudentPage.loadResources.getActiveTrip.error] $e");
    }

    if(mounted){
      setState(() {
        showLoader = false;
      });
    }
  }

  openTripcallback(TripModel trip_) {
    Get.to(TripPage(
      trip: trip_,
      navigationMode: false,
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

    showLoader = true;

    Provider.of<NotificationService>(context, listen: false)
        .addListener(onPushMessage);

    loadResources();    
  }

  onPushMessage() {
    loadResources();
  }
}

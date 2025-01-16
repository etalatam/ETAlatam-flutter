import 'dart:async';
import 'package:eta_school_app/Pages/student_page.dart';
import 'package:eta_school_app/Pages/trip_page.dart';
import 'package:eta_school_app/components/active_trip.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Models/parent_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/loader.dart';

class GuardiansHome extends StatefulWidget {
  @override
  State<GuardiansHome> createState() => _GuardiansHomeState();
}

class _GuardiansHomeState extends State<GuardiansHome>
    with ETAWidgets, MediansTheme, WidgetsBindingObserver {
  final widgets = ETAWidgets;

  late GoogleMapController mapController;

  ParentModel? parentModel =
      ParentModel(parentId: 0, firstName: '', contactNumber: "", students: []);

  bool showLoader = true;

  List<TripModel> oldTripsList = [];

  List<TripModel> activeTrips = [];

  @override
  Widget build(BuildContext context) {
    activeTheme =
        storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();
    return showLoader
        ? Loader()
        : Material(
            type: MaterialType.transparency,
            child: Scaffold(
                body: RefreshIndicator(
                    triggerMode: RefreshIndicatorTriggerMode.onEdge,
                    onRefresh:
                        _refreshData, // Function to be called on pull-to-refresh
                    child: Stack(
                      children: [
                        Container(
                            color: activeTheme.main_bg,
                            height: MediaQuery.of(context).size.height,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: 100),
                              physics: AlwaysScrollableScrollPhysics(),
                              child: Stack(children: <Widget>[
                                Container(
                                  color: activeTheme.main_bg,
                                  margin: EdgeInsets.only(top: 120),
                                  child: Column(children: [
                                    activeTrips.isEmpty
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
                                        : SizedBox(
                                            height: 150,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: activeTrips.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return SizedBox(
                                                      width: 400,
                                                      child: ActiveTrip(
                                                          openTrip,
                                                          activeTrips[index])
                                                      // child: Text("Maldito"),
                                                      );
                                                })),

                                    ETAWidgets.svgTitle(
                                        "assets/svg/school.svg",
                                        lang.translate(
                                            "List of your added children")),

                                    SizedBox(height: 10),

                                    /// Students list
                                    parentModel!.students.isEmpty
                                        ? Center()
                                        : SizedBox(
                                            height: 230,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: parentModel!.students
                                                  .length, // Replace with the total number of items
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                /// Student block
                                                return GestureDetector(
                                                    onTap: () {
                                                      openNewPage(
                                                          context,
                                                          StudentPage(
                                                              student: parentModel!
                                                                      .students[
                                                                  index]));
                                                    },
                                                    child: ETAWidgets
                                                        .homeStudentBlock(
                                                            context,
                                                            parentModel!
                                                                    .students[
                                                                index]));
                                              },
                                            ),
                                          ),

                                    SizedBox(
                                      height: 10,
                                    ),

                                    ETAWidgets.svgTitle("assets/svg/route.svg",
                                        lang.translate('trips_history')),

                                    /// Old trips
                                    SizedBox(
                                        height: 250,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: oldTripsList
                                                .length, // Replace with the total number of items
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return GestureDetector(
                                                  onTap: () {
                                                    openNewPage(
                                                        context,
                                                        TripPage(
                                                          trip: oldTripsList[
                                                              index],
                                                          showBus: false,
                                                          showStudents: false,
                                                        ));
                                                  },
                                                  child:
                                                      ETAWidgets.homeTripBlock(
                                                          context,
                                                          oldTripsList[index]));
                                            })),
                                  ]),
                                ),
                              ]),
                            )),
                        Positioned(left: 0, right: 0, top: 0, child: Header()),
                      ],
                    ))));
  }

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    setState(() {
      showLoader = true;
    });

    await Future.delayed(Duration(seconds: 2));
    setState(() {
      loadParent();
    });
  }

  notificationSubcribe(String topic) {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      messaging.subscribeToTopic(topic);
    } catch (e) {
      print("GuardianHome.notificationSubcribe.error: ${e.toString()}");
    }
  }

  loadParent() async {
    Timer(Duration(seconds: 2), () async {
      await storage.getItem('darkmode');
      setState(() {
        darkMode = storage.getItem('darkmode') == true ? true : false;
        showLoader = false;
      });
    });

    final parentQuery = await httpService.getParent();
    setState(() {
      parentModel = parentQuery;
    });

    final List<TripModel> trips = (await httpService.getGuardianTrips("true"));
    List<String> routeTopics = [];
    for (var trip in trips) {
      notificationSubcribe("route-${trip.route_id}");
      routeTopics.add("route-${trip.route_id}");
      trip.subscribeToTripTracking();
    }
    storage.setItem('route-topics', routeTopics.toString());

    setState(() {
      activeTrips = trips;
    });

    final List<TripModel> oldTrips =
        (await httpService.getGuardianTrips("false"));
    setState(() {
      oldTripsList = oldTrips;
    });
  }

  openTrip(trip) {
    Get.to(TripPage(
      trip: trip,
      showBus: true,
      showStudents: true,
    ));
  }

  @override
  void initState() {
    super.initState();
    loadParent();
  }
}

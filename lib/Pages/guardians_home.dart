import 'dart:async';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/Pages/providers/notification_provider.dart';
import 'package:eta_school_app/Pages/student_page.dart';
import 'package:eta_school_app/Pages/trip_page.dart';
import 'package:eta_school_app/components/active_trip.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Models/parent_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:provider/provider.dart';

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
                                        ? ETAWidgets.infoMessage(lang.translate(
                                            "Does not have active trips"))
                                        : SizedBox(
                                            height: 150,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: activeTrips.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return Consumer<EmitterService>(builder:(context, emitterService, child) {
                                                    try {
                                                      final jsonMessage = emitterService.jsonMessage();
                                                      final String type = jsonMessage['event_type'];

                                                      if(type == "end-trip"){
                                                        setState(() {
                                                          loadParent();
                                                        });
                                                      }
                                                    } catch (e) {
                                                      print(e);
                                                    }

                                                    return SizedBox(
                                                        width: 400,
                                                        child: ActiveTrip(
                                                            openTrip,
                                                            activeTrips[index])
                                                        );
                                                  });
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
                                                          navigationMode: false,
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

  loadParent() async {
    setState(() {
      showLoader = true;
    });

    final parentQuery = await httpService.getParent();
    setState(() {
      parentModel = parentQuery;
      showLoader = false;
    });

    for (var student in parentModel!.students) {
      student.subscribeToStudentTracking();
    }

    final List<TripModel> trips = (await httpService.getGuardianTrips("true"));
    for (var trip in trips) {
      trip.subscribeToTripTracking();
    }

    final List<RouteModel> routes = await httpService.getGuardianRoutes();

    for (var route in routes) {
      var routeTopic = "route-${route.route_id}";
      var routeTopicGuardian = "$routeTopic-guardian";
      
      notificationServiceProvider.subscribeToTopic(routeTopicGuardian);

      for (var student in parentModel!.students) {
        var topic = "$routeTopic-student-${student.student_id}";
        print("sdssd: ${student.pickup_points}");
        notificationServiceProvider.subscribeToTopic(topic);        
        for (var pickupPoint in student.pickup_points) {
          var topic = "$routeTopic-pickup_point-${pickupPoint.pickup_id}";
          notificationServiceProvider.subscribeToTopic(topic);
        }
      }
    }

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
      navigationMode: false,
      showBus: true,
      showStudents: true,
    ));
  }

  @override
  void initState() {
    super.initState();

    loadParent();

    if(mounted){      
      Provider.of<NotificationService>(context, listen: false)
          .addListener(onPushMessage);
    }
  }

  @override
  void dispose() {
    // Break references to this State object here
    super.dispose();
  }

  onPushMessage() {
    if(mounted){
      setState(() {
        loadParent();
      });
    }
  }
}

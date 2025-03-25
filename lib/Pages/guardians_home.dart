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
import 'package:visibility_detector/visibility_detector.dart';

class GuardiansHome extends StatefulWidget {
  @override
  State<GuardiansHome> createState() => _GuardiansHomeState();
}

class _GuardiansHomeState extends State<GuardiansHome>
    with ETAWidgets, MediansTheme {
  final widgets = ETAWidgets;

  late GoogleMapController mapController;

  ParentModel? parentModel =
      ParentModel(parentId: 0, firstName: '', contactNumber: "", students: []);

  bool showLoader = true;

  List<TripModel> oldTripsList = [];

  List<TripModel> activeTrips = [];

  EmitterService? _emitterServiceProvider;

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
                    child: VisibilityDetector(
                          key: Key('guardians_home_key'),
                          onVisibilityChanged: (info) {
                            if (info.visibleFraction > 0) {
                              loadParent();
                            }
                          }, 
                      child:Stack(
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
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Consumer<
                                                          EmitterService>(
                                                      builder: (context,
                                                          emitterService,
                                                          child) {
                                                    try {
                                                      final jsonMessage =
                                                          emitterService
                                                              .jsonMessage();
                                                      final String type =
                                                          jsonMessage[
                                                              'event_type'];

                                                      if (type == "end-trip") {
                                                        setState(() {
                                                          loadParent();
                                                        });
                                                      }
                                                    } catch (e) {
                                                      // print("[guardianHome] $e");
                                                    }

                                                    return SizedBox(
                                                        width: 400,
                                                        child: ActiveTrip(
                                                            openTrip,
                                                            activeTrips[
                                                                index]));
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
                    )))));
  }

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    if(mounted){
      setState(() {
        showLoader = true;
      });
    }

    loadParent();
  }

  loadParent() async {
    print("[GuardianHome.loadParent]");

    try {
      final parentQuery = await httpService.getParent();
      if(mounted){
        setState(() {
          parentModel = parentQuery;
          showLoader = false;
        });
      }else{
        parentModel = parentQuery;
        showLoader = false;
      }
        
      for (var student in parentModel!.students) {
        student.subscribeToStudentTracking();
      }
    } catch (e) {
      print("[GuardianHome.loadParent] error loading parent info : $e");
    }

    try {
      final List<TripModel> trips = (await httpService.getGuardianTrips("true"));
      for (var trip in trips) {
        trip.subscribeToTripTracking(_emitterServiceProvider);
      }

      if(mounted){
        setState(() {
          activeTrips = trips;
        });
      }else{
        activeTrips = trips;
      }
    } catch (e) {
      print("[GuardianHome.loadParent] error loading active trips : $e");
    }

    try {
      final List<RouteModel> routes = await httpService.getGuardianRoutes();

      for (var route in routes) {
        var routeTopic = "route-${route.route_id}";
        var routeTopicGuardian = "$routeTopic-guardian";

        notificationServiceProvider.subscribeToTopic(routeTopicGuardian);

        for (var student in parentModel!.students) {
          var topic = "$routeTopic-student-${student.student_id}";          
          notificationServiceProvider.subscribeToTopic(topic);
          for (var pickupPoint in student.pickup_points) {
            var topic = "$routeTopic-pickup_point-${pickupPoint.pickup_id}";
            notificationServiceProvider.subscribeToTopic(topic);
          }
        }
      }      
    } catch (e) {
      print("[GuardianHome.loadParent] error  subscribing to topics : $e");
    }

    try {
      final List<TripModel> oldTrips =
        (await httpService.getGuardianTrips("false"));

      if(mounted){
        setState(() {
          oldTripsList = oldTrips;
        });
      }else{
        oldTripsList = oldTrips;
      }
    } catch (e) {
      print("[GuardianHome.loadParent] error  loading olds trips : $e");
    }
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

    showLoader = true;

    Provider.of<NotificationService>(context, listen: false)
          .addListener(onPushMessage);

    _emitterServiceProvider =
        Provider.of<EmitterService>(context, listen: false);

    if(!_emitterServiceProvider!.isConnected()){
      _emitterServiceProvider?.connect();
    }

    loadParent();
  }

  @override
  void dispose() {
    // Break references to this State object here
    super.dispose();
  }

  onPushMessage() {
    loadParent();
  }
}

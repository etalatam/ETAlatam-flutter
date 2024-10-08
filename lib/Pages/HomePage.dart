import 'dart:async';
import 'package:MediansSchoolDriver/Models/RouteModel.dart';
import 'package:MediansSchoolDriver/Pages/LoginPage.dart';
// import 'package:MediansSchoolDriver/Pages/ProfilePage.dart';
import 'package:MediansSchoolDriver/Pages/TripPage.dart';
import 'package:MediansSchoolDriver/components/ActiveTrip.dart';
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
import 'package:MediansSchoolDriver/components/header.dart';
// import 'package:MediansSchoolDriver/components/bottom_menu.dart';
import 'package:MediansSchoolDriver/components/HomeRouteBlock.dart';
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
    // activeTheme = storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();
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
                              padding: const EdgeInsets.only(bottom: 100),
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
                                        ? const Center()
                                        : ActiveTrip(openTrip, activeTrip),

                                    MediansWidgets.svgTitle(
                                        "assets/svg/fire.svg",
                                        lang.translate("Routes")),

                                    const SizedBox(height: 10),

                                    /// Available Routes
                                    SizedBox(
                                        height: 300,
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

                                    MediansWidgets.svgTitle(
                                        "assets/svg/bus.svg",
                                        lang.translate('trips_history')),

                                    /// Last Trips
                                    oldTripsList.isEmpty
                                        ? const Center()
                                        : SizedBox(
                                            height: 300,
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
                                                                        index]));
                                                      },
                                                      child: MediansWidgets
                                                          .homeTripBlock(
                                                              context,
                                                              oldTripsList[
                                                                  index]));
                                                })),
                                    const SizedBox(
                                      height: 30,
                                    ),

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
                                    //   child:  MediansWidgets.eventCarousel(eventsList, context),
                                    // ),

                                    /// Help / Support Block
                                    // MediansWidgets.homeHelpBlock(),
                                  ]),
                                ),
                              ]),
                            )),
                        Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            child: Header(lang.translate('sitename'))),

                        // Positioned(
                        //   left: 0,
                        //   right: 0,
                        //   top: 0,
                        //   child: Header(lang.translate('sitename'))
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

  /// Create trip
  createTrip(routeId, vehicleId) async {
    TripModel? createdTrip;

    setState(() {
      showLoader = true;
    });
    final driverId = await storage.getItem('driver_id');
    try {
      createdTrip = await httpService.create_trip(driverId, routeId, vehicleId);
      if (createdTrip.trip_id != 0) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TripPage(trip: createdTrip)),
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
          lang.translate(msg[0]), () {
        Get.back();
      });
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

    // final eventsQuery = await httpService.getEvents();
    // setState(()  {
    //     eventsList = eventsQuery;
    // });

    final driverId = await storage.getItem('driver_id');
    final driverQuery = await httpService.getDriver(driverId);
    setState(() {
      driverModel = driverQuery;
    });

    final routesQuery = await httpService.getRoutes();
    setState(() {
      routesList = routesQuery;
    });

    List<TripModel>? oldTrips = await httpService.getTrips(0);
    setState(() {
      oldTripsList = oldTrips;
    });

    TripModel? activeTrip_ = await httpService.getActiveTrip();
    setState(() {
      activeTrip = activeTrip_;
      hasActiveTrip = (activeTrip_.trip_id != 0) ? true : false;
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
    loadResources();
  }
}

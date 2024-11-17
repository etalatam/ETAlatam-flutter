import 'dart:async';
import 'package:eta_school_app/Models/RouteModel.dart';
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/trip_page.dart';
import 'package:eta_school_app/Pages/providers/location_service_provider.dart';
import 'package:eta_school_app/components/active_trip.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Models/DriverModel.dart';
import 'package:eta_school_app/Models/TripModel.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/Helpers.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/home_route_block.dart';
import 'package:eta_school_app/Models/EventModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with MediansWidgets, MediansTheme, WidgetsBindingObserver {

  final widgets = MediansWidgets;

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

                                    MediansWidgets.svgTitle(
                                        "assets/svg/fire.svg",
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

                                    MediansWidgets.svgTitle(
                                        "assets/svg/bus.svg",
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
                                                                        index]));
                                                      },
                                                      child: MediansWidgets
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
    TripModel? trip;

    setState(() {
      showLoader = true;
    });
    final driverId = await storage.getItem('driver_id');
    try {
      trip = await httpService.startTrip(routeId);
      if (trip.trip_id != 0) {
        await locationServiceProvider.startLocationService();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TripPage(trip: trip)),
        );
        loadResources();
      }
    } catch (e) {
      print(e.toString());
      var msg = e.toString().split('/');
      setState(() {
        showLoader = false;
      });
      showSuccessDialog(context, 
        "${lang.translate('Error')} (${msg[1]})",
        lang.translate(msg[0]), 
        null
      );
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

  ///
  /// Load resources through API
  ///
  loadResources() async {
    final check = await storage.getItem('driver_id');

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

      if(hasActiveTrip){
        await locationServiceProvider.startLocationService();
      }

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
    configureFirebaseMessaging();
    loadResources();
    
  }

  configureFirebaseMessaging () async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Solicitar permisos en iOS
      messaging.requestPermission();

      // Obtener el token de FCM
      messaging.getToken().then((token) {
        print("[FCM] Token: $token");
      });

      // Manejar mensajes en segundo plano
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Manejar mensajes cuando la app está en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('[FCM] Got a message whilst in the foreground!');
        print('[FCM] Message data: ${message.data}');
        if (message.notification != null) {
          print('[FCM] Message also contained a notification: ${message.notification}');
        }
      });

      
      final userId = await storage.getItem('id_usu');
      messaging.subscribeToTopic('all-notifications');
      messaging.subscribeToTopic("user-$userId");
    } catch (e) {
      print("[FCM] ${e.toString()}");
    }

  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async { 
    print('Handling a background message: ${message.messageId}'); 
  }  
}
import 'dart:async';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/Pages/trip_page.dart';
import 'package:eta_school_app/components/active_trip.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:eta_school_app/shared/location/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Models/driver_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/home_route_block.dart';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> with ETAWidgets, MediansTheme {
  final widgets = ETAWidgets;

  // late GoogleMapController mapController;

  bool hasActiveTrip = false;

  DriverModel driverModel = DriverModel(driver_id: 0, first_name: '');

  TripModel? activeTrip;

  bool showLoader = false;

  List<EventModel> eventsList = [];
  List<RouteModel> todateRoutesList = [];
  List<TripModel> oldTripsList = [];
  bool _isFirstLoad = true;

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
                        key: Key('driver_home_key'),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction > 0 && _isFirstLoad) {
                            _isFirstLoad = false;
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
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Stack(children: <Widget>[
                                    Container(
                                      color: activeTheme.main_bg,
                                      margin: const EdgeInsets.only(top: 120),
                                      child: Column(children: [
                                        /// Has Active Trip
                                        !hasActiveTrip
                                            ? ETAWidgets.infoMessage(
                                                lang.translate(
                                                    "Does not have active trips"))
                                            : ActiveTrip(
                                                openTripCallback, activeTrip),

                                        ETAWidgets.svgTitle(
                                            "assets/svg/route.svg",
                                            lang.translate("Routes")),

                                        const SizedBox(height: 10),

                                        /// Available Routes
                                        todateRoutesList.isEmpty
                                            ? ETAWidgets.infoMessage(
                                                lang.translate(
                                                    "Does not have next route"))
                                            : SizedBox(
                                                height: 260,
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: todateRoutesList
                                                        .length, // Replace with the total number of items
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                                todateRoutesList
                                                                            .length <
                                                                        2
                                                                    ? 20
                                                                    : 0),
                                                        width: todateRoutesList
                                                                    .length <
                                                                2
                                                            ? MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width
                                                            : 400,
                                                        // height: 400,
                                                        child: HomeRouteBlock(
                                                          route:
                                                              todateRoutesList[
                                                                  index],
                                                          callback: createTrip,
                                                          hasActiveTrip:
                                                              hasActiveTrip,
                                                        ),
                                                      );
                                                    })),

                                        ETAWidgets.svgTitle(
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
                                                                          index],
                                                                  navigationMode:
                                                                      false,
                                                                  showBus:
                                                                      false,
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
                            Positioned(
                                left: 0, right: 0, top: 0, child: Header()),
                          ],
                        )))));
  }

  /// Create trip
  createTrip(RouteModel route) async {
    TripModel? trip;

    if (!mounted) return;
    setState(() {
      showLoader = true;
    });

    try {
      trip = await httpService.startTrip(route);
      if (trip.trip_id != 0) {
        if (trip.school_id != null) {
          await storage.setItem('driver_school_id', trip.school_id);
        }
        await storage.setItem('has_active_trip', 'true');
        await LocationService.instance.init();
        await LocationService.instance.startLocationService(
            calculateDistance: true);
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TripPage(
                    trip: trip,
                    navigationMode: trip?.trip_status == 'Running',
                    showBus: false,
                    showStudents: false,
                  )),
        );
        loadResources();
      }
    } catch (e) {
      print("[DriverHome.createTrip.error] ${e.toString()}");

      if (!mounted) return;
      setState(() {
        showLoader = false;
      });

      String errorTitle = lang.translate('Error');
      String errorMessage = lang.translate('error_starting_trip');

      var errorString = e.toString();
      if (errorString.contains('/')) {
        var parts = errorString.split('/');
        if (parts.length >= 2) {
          errorTitle = "${lang.translate('Error')} (${parts[1]})";
          var translatedMsg = lang.translate(parts[0]);
          if (translatedMsg != parts[0]) {
            errorMessage = translatedMsg;
          }
        }
      }

      showSuccessDialog(context, errorTitle, errorMessage, null);
    }
  }

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      showLoader = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      loadResources();
    });
  }

  openPage(context, page) {
    if (!mounted) return;
    setState(() => openNewPage(context, page));
  }

  ///
  /// Load resources through API
  ///
  loadResources() async {
    if (!mounted) return;

    final check = await storage.getItem('id_usu');
    if (check == null || !mounted) return;

    try {
      final driverQuery = await httpService.getDriver();
      if (mounted) {
        setState(() {
          driverModel = driverQuery;
        });
      }
    } catch (e) {
      print("[DriverHome.loadrResources.getdriverinfo.error] $e");
    }

    try {
      // Primero intentar obtener las rutas de hoy
      var todateRoutes = await httpService.todayRoutes();
      
      // Si no hay rutas para hoy, obtener todas las rutas disponibles
      if (todateRoutes.isEmpty) {
        print("[DriverHome] No routes for today, fetching all available routes");
        todateRoutes = await httpService.getRoutes();
      }
      
      for (var route in todateRoutes) {
        var routeDriverTopic = "route-${route.route_id}-driver";
        NotificationService.instance.subscribeToTopic(routeDriverTopic);
      }
      
      if (mounted) {
        setState(() {
          todateRoutesList = todateRoutes;
        });
      } else {
        todateRoutesList = todateRoutes;
      }
    } catch (e) {
      print("[DriverHome.loadrResources.todayRoutes.error] $e");
    }

    try {
      List<TripModel>? oldTrips = await httpService.getDriverTrips(0);
      if (mounted) {
        setState(() {
          oldTripsList = oldTrips;
        });
      } else {
        oldTripsList = oldTrips;
      }
    } catch (e) {
      print("[DriverHome.loadrResources.getDriverTrips.error] $e");
    }

    try {
      TripModel? activeTripWrapper = await httpService.getActiveTrip();
      final bool hadActiveTrip = hasActiveTrip;
      
      if (mounted) {
        setState(() {
          activeTrip = activeTripWrapper;
          hasActiveTrip = (activeTripWrapper.trip_id != 0) ? true : false;
        });
      } else {
        activeTrip = activeTripWrapper;
        hasActiveTrip = (activeTripWrapper.trip_id != 0) ? true : false;
      }
      
      if (hasActiveTrip && activeTrip != null) {
        // Iniciar tracking si hay viaje activo
        // Nota: No verificamos isTracking - startLocationService() maneja reintentos internamente
        print("[DriverHome.loadResources] Viaje activo detectado (ID: ${activeTrip!.trip_id}), asegurando tracking");
        await LocationService.instance.init();
        await LocationService.instance.startLocationService(calculateDistance: true);
      } else if (hadActiveTrip && !hasActiveTrip) {
        // Detener tracking si el viaje finalizó
        print("[DriverHome.loadResources] Viaje finalizado, deteniendo tracking");
        await LocationService.instance.stopLocationService();
      }
    } catch (e) {
      print("[DriverHome.loadrResources.getActiveTrip.error] $e");
    } finally {
      if (mounted) {
        setState(() {
          showLoader = false;
        });
      }
      NotificationService.instance.setTopicsReady();
    }
  }

  openTripCallback(TripModel wrapper) {
    Get.to(TripPage(
      trip: wrapper,
      navigationMode: wrapper.trip_status == 'Running',
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

    // showLoader = true;

    // Comentado: esto causaba refresh innecesario del chat cuando llegaba push notification
    // El chat ahora se actualiza en tiempo real via Emitter, no necesita refresh por FCM
    // Provider.of<NotificationService>(context, listen: false)
    //     .addListener(onPushMessage);

    loadResources();
  }

  // Comentado: esto causaba refresh innecesario del chat cuando llegaba push notification
  // El chat ahora se actualiza en tiempo real via Emitter, no necesita refresh por FCM
  // onPushMessage() {
  //   loadResources();
  // }
}

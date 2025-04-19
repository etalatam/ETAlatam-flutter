import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eta_school_app/Pages/map/mapbox_utils.dart';
import 'package:eta_school_app/Pages/providers/emitter_service_provider.dart';
import 'package:eta_school_app/Pages/providers/notification_provider.dart';
import 'package:eta_school_app/components/pulsating_circle.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:eta_school_app/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Pages/attendance_page.dart';
import 'package:eta_school_app/Pages/providers/location_service_provider.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/tripReportPage.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/components/button_text_icon.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:ui' as ui;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'map/map_wiew.dart';

class TripPage extends StatefulWidget {
  const TripPage(
      {super.key,
      this.trip,
      required this.navigationMode,
      required this.showBus,
      required this.showStudents});

  final TripModel? trip;

  final bool navigationMode;

  final bool showBus;

  final bool showStudents;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage>
    with ETAWidgets, MediansTheme
    implements OnPointAnnotationClickListener {
  bool showLoader = false;

  String activeTab = 'pickup';

  TripModel trip = TripModel(trip_id: 0);

  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  bool showTripReportModal = false;

  MapboxMap? _mapboxMapController;

  String relationName = '';

  PointAnnotationManager? annotationManager;

  // Map<String, PointAnnotation> annotationsMap = {};
  PointAnnotation? busPointAnnotation;

  bool waitingBusPosition = true;

  ScreenCoordinate busPulsatingCircleCoordinate = ScreenCoordinate( x: 0, y: 0);

  bool connectivityNone = false;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  EmitterService? _emitterServiceProvider;

  late NotificationService _notificationService;

  String tripDuration = "";

  double tripDistance = 0;
  
  final numberFormat = NumberFormat("#.##");

  Map<String, dynamic>? _lastPositionPayload;
  
  ScreenCoordinate  busModelCoordinate = ScreenCoordinate( x: 0, y: 0);
  
  double busHeading = 270;
  
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final int busColor = trip.bus_color != null ? _convertColor(trip.bus_color!) : Colors.blue.value;
    
    return Material(
        child: showLoader
            ? Loader()
            : Scaffold(
                body: VisibilityDetector(
                  key: Key('student_home_key'),
                  onVisibilityChanged: (info) {
                      _isVisible = info.visibleFraction > 0;
                    if (info.visibleFraction > 0) {
                      loadTrip();
                    }else{
                      cleanResources();
                    }
                  },
                  child: Stack(children: <Widget>[
                    // Column(children: [
                    // // if(widget.showBus && !hasBusPosition )
                    //   SizedBox(
                    //     height: 15,
                    //     child: LinearProgressIndicator(
                    //       color: Colors.white,
                    //       semanticsLabel: "Esperando ubicación del bus...",
                    //     ),
                    //   ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.40,
                      child: MapWiew(
                        navigationMode: widget.navigationMode,
                        onMapReady: (MapboxMap mapboxMap) async {
                          _mapboxMapController = mapboxMap;

                          // Asegurar que el annotationManager esté creado
                          if (annotationManager == null) {
                            final value = await mapboxMap.annotations.createPointAnnotationManager();
                            annotationManager = value;
                            annotationManager?.addOnPointAnnotationClickListener(this);
                          }

                          mapboxMap.setOnMapMoveListener((context) {
                            if (_lastPositionPayload != null) {
                              final Position position = Position(
                                double.parse("${_lastPositionPayload?['longitude']}"),
                                double.parse("${_lastPositionPayload?['latitude']}")
                              );
                              _updateBusModelCoordinates(Point(coordinates: position));
                            }
                          });
                        },
                        onStyleLoadedListener: (MapboxMap mapboxMap) async {
                          // 1. Elimina capas existentes
                          if (await mapboxMap.style.styleSourceExists("trip_source")) {
                            mapboxMap.style.removeStyleLayer("line_layer");
                            mapboxMap.style.removeStyleSource("trip_source");
                          }

                          // 2. Agrega línea primero
                          showTripGeoJson(mapboxMap); // LineLayer

                          // 3. Espera 100ms
                          await Future.delayed(Duration(milliseconds: 100));
                          
                          // 4. Agrega marcadores
                          showPickupLocations(mapboxMap); // PointAnnotation
                        }
                      ),
                    ),

                    if (connectivityNone)
                      Positioned(
                        // left: 0,
                        top: 40,
                        child: SizedBox(
                            height: 50,
                            width: 300,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: AnimatedContainer(
                                    duration: Duration(seconds: 1),
                                    curve: Curves.fastOutSlowIn,
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                              20), // Cambia el valor para ajustar el radio
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.wifi_off,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text('No hay conexión a Internet',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    if (trip.trip_status == 'Running')
                      Positioned(
                        top: 40,
                        right: 10,
                        child: Consumer<EmitterService>(
                            builder: (context, emitterService, child) {
                          return Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: emitterService.isConnected()
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          );
                        }),
                      ),

                    // Positioned(
                    //   left: 0,
                    //   top: 0,
                    //   child: SizedBox(
                    //     height: 10,
                    //     child:
                    //       waitingBusPosition ?
                    //       LinearProgressIndicator() :
                    //       Center()
                    //   ),
                    //   ),
                    if(busPulsatingCircleCoordinate.x.toDouble() > 0)
                      Positioned(
                        left: busPulsatingCircleCoordinate.x.toDouble() - 25,
                        top: busPulsatingCircleCoordinate.y.toDouble() - 25,
                        child: Consumer<EmitterService>(builder: (context, emitterService, child) {
                          return PulsatingCircle(
                            color: emitterService.isConnected() ? Colors.green :  Colors.red
                          );
                        })
                    ),

                    if(busModelCoordinate.x.toDouble() > 0 && annotationManager != null)
                    Positioned(
                      left: busModelCoordinate.x.toDouble() - 35,
                      top: busModelCoordinate.y.toDouble() - 35,
                      child:SizedBox(
                        width: 40,
                        height: 40,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(busColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage('assets/bus_color.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        )
                      )
                      
                      /* SizedBox(
                        width: 60,
                        height: 60,
                        child: IgnorePointer(
                          child: ModelViewer(
                            src: 'assets/bus.glb', // Ruta al modelo 3D
                            //src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
                            alt: 'Autobús 3D',
                            ar: false, // Habilita AR (si es compatible)
                            backgroundColor: Colors.transparent,
                            autoRotate: false, // Rota el modelo automáticamente
                            cameraControls: false, // Permite controlar la cámara
                            disableZoom: true,
                            disablePan: true,
                            disableTap: true,
                            orientation: "0deg 0deg ${busHeading.toStringAsFixed(1)}deg",
                            interactionPrompt: InteractionPrompt.none,
                          ))
                        )*/
                      ),

                    DraggableScrollableSheet(
                      snapAnimationDuration: const Duration(seconds: 1),
                      initialChildSize: isLandscape ? 0.3 : (trip.trip_status == 'Running' ? 0.5 : 0.29),
                      minChildSize: isLandscape ? 0.2 : 0.29,
                      maxChildSize: 1,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Stack(children: [
                          Container(
                            margin: const EdgeInsets.only(top: 0),
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: activeTheme.main_bg,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(0.0, -3.0),
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Stack(children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                height: 1,
                                color: activeTheme.main_color.withOpacity(.2),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(20),
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            "${lang.translate('Trip')} #${trip.trip_id} ${trip.route?.route_name}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: activeTheme.h6,
                                          ),
                                        ),
                                        Row(children: [
                                          SvgPicture.asset(
                                            "assets/svg/bus.svg",
                                            width: 15,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            trip.vehicle?.plate_number ?? '',
                                          )
                                        ]),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (trip.trip_status == "Running")
                                      Row(
                                        // textDirection: TextDirection.LTR,
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(height: 10),
                                          Icon(Icons.access_time, size: 20),
                                          Text(tripDuration),
                                          const SizedBox(width: 10),
                                          Icon(Icons.route, size: 20),
                                          Text(tripDistance > 1000
                                              ? '${numberFormat.format(tripDistance)} KM'
                                              : '${numberFormat.format(tripDistance)} m'),
                                          const SizedBox(width: 10),
                                          (trip.pickup_locations != null)
                                              ? Icon(Icons.pin_drop_outlined,
                                                  size: 20)
                                              : const Center(),
                                          (trip.pickup_locations != null)
                                              ? Text(
                                                  '${trip.visitedLocation()}/${trip.pickup_locations!.length.toString()} ',
                                                )
                                              : const Center(),
                                          if (trip.trip_status == 'Completed' &&
                                              relationName
                                                  .contains('eta.drivers'))
                                            GestureDetector(
                                                onTap: (() {
                                                  openNewPage(
                                                      context,
                                                      AttendancePage(
                                                          trip: trip));
                                                }),
                                                child: Center(
                                                    child: ButtonTextIcon(
                                                        '',
                                                        Icon(
                                                          Icons.list,
                                                          color: activeTheme
                                                              .buttonBG,
                                                        ),
                                                        activeTheme
                                                            .buttonColor))),
                                        ],
                                      ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 1,
                                      color: activeTheme.main_color
                                          .withOpacity(.3),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    trip.trip_status == 'Completed'
                                        ? ETAWidgets.tripInfoRow(trip)
                                        : const Center(),
                                    Row(children: [
                                      if (trip.trip_status == 'Running' &&
                                          relationName.contains('eta.drivers'))
                                        GestureDetector(
                                            onTap: showLoader
                                                ? null
                                                : (() {
                                                    endTrip();
                                                  }),
                                            child: Center(
                                                child: ButtonTextIcon(
                                                    lang.translate('End trip'),
                                                    Icon(
                                                      Icons.route,
                                                      color: activeTheme
                                                          .buttonColor,
                                                    ),
                                                    showLoader
                                                        ? Colors.grey
                                                        : Colors.red))),
                                      if (trip.trip_status == 'Running')
                                        const SizedBox(
                                          width: 20,
                                        ),
                                      if (trip.trip_status == 'Running' &&
                                          relationName.contains('eta.drivers'))
                                        GestureDetector(
                                            onTap: (() {
                                              openNewPage(context,
                                                  AttendancePage(trip: trip));
                                            }),
                                            child: Center(
                                                child: ButtonTextIcon(
                                                    lang.translate(
                                                        'Attendance'),
                                                    Icon(
                                                      Icons.list,
                                                      color: activeTheme
                                                          .buttonColor,
                                                    ),
                                                    Color.fromARGB(
                                                        255, 226, 187, 32)))),
                                    ]),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    for (var i = 0;
                                        i < trip.pickup_locations!.length;
                                        i++)
                                      activeTab == 'pickup'
                                          ? Row(children: [
                                              tripUser(
                                                  trip.pickup_locations![i]),
                                            ])
                                          : const Center(),
                                  ],
                                ),
                              )
                            ]),
                          )
                        ]);
                      },
                    ),
                    showTripReportModal
                        ? TripReport(trip: trip)
                        : const Center(),
                  ]),
                  // ])
                ),
              ));
  }

  CoordinateBounds getCoordinateBounds(List<Position> points) {
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = -double.infinity;
    double maxLng = -double.infinity;

    for (var point in points) {
      minLat = min(minLat, point.lat as double);
      minLng = min(minLng, point.lng as double);
      maxLat = max(maxLat, point.lat as double);
      maxLng = max(maxLng, point.lng as double);
    }

    print('[TripPage.getCoordinateBounds] $minLng, $minLat');
    print('[TripPage.getCoordinateBounds] $maxLng, $maxLat');

    return CoordinateBounds(
      southwest: Point(coordinates: Position(minLng, minLat)),
      northeast: Point(coordinates: Position(maxLng, maxLat)),
      infiniteBounds: true,
    );
  }

  Widget tripUser(TripPickupLocation pickupLocation) {
    // print('[TripPage.tripUser.pickupLocation]');
    return GestureDetector(
      onTap: () {
        _mapboxMapController?.setCamera(CameraOptions(
            zoom: 18,
            center: Point(
                coordinates: Position(pickupLocation.location!.longitude as num,
                    pickupLocation.location!.latitude as num))));
      },
      child: Row(children: [
        const SizedBox(
          width: 10,
        ),
        Column(
          children: [
            SizedBox(
              width: 20,
              height: 10,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pickupLocation.status != 'waiting'
                        ? Colors.green
                        : Colors.grey),
              ),
            ),
            Container(
              width: 3.0,
              height: 120.0,
              color: pickupLocation.status != 'waiting'
                  ? Colors.green
                  : Colors.grey,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 300,
              child: Text(
                '${pickupLocation.location?.location_name}',
                style: activeTheme.h5,
                softWrap: true,
                maxLines: 2,
              ),
            ),
            SizedBox(
                width: 300,
                child: Text(
                  '${pickupLocation.location?.address}',
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: activeTheme.smallText.fontSize,
                      color: activeTheme.smallText.color),
                )),
          ],
        )
      ]),
    );
  }

  endTrip() async {
    if (mounted) {
      setState(() {
        showLoader = true;
      });
    }

    try {
      await trip.endTrip();
      setState(() {
        showLoader = false;
        showTripReportModal = true;
      });
    } catch (e) {
      print("[TripPage.endTrip.error] ${e.toString()}");
      var msg = e.toString().split('/');
      setState(() {
        showLoader = false;
      });
      showSuccessDialog(context, "${lang.translate('Error')} (${msg[1]})",
          lang.translate(msg[0]), () {
        Get.back();
      });
    }

    try {
      locationServiceProvider.stopLocationService();
      cleanResources();
    } catch (e) {
      print(e);
    }
  }

  loadTrip() async {
    print("[TripPage.loadTrip] ");
    try {
      if (trip.trip_status == "Running") {
        print("[TripPage.loadTrip][trip.trip_status] ${trip.trip_status}");
        Wakelock.enable();

        initConnectivity();
        _connectivitySubscription =
            _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

        _emitterServiceProvider =
            Provider.of<EmitterService>(context, listen: false);
        _emitterServiceProvider?.addListener(onEmitterMessage);
        _emitterServiceProvider?.startTimer(false);
        trip.subscribeToTripEvents(_emitterServiceProvider);
        trip.subscribeToTripTracking(_emitterServiceProvider);

        _notificationService =
            Provider.of<NotificationService>(context, listen: false);
        _notificationService.addListener(onPushMessage);
      }
    } catch (e) {
      print("[TripPage.loadTrip] $e");
    }

    try {
      if (relationName.isEmpty) {
        final LocalStorage storage = LocalStorage('tokens.json');
        relationName = await storage.getItem('relation_name');
        print("[TipPage.loadTrip.relationName] $relationName");
      }
    } catch (e) {
      print("[TripPage.loadTrip.relationName.error] $e");
    }

    try {
      TripModel? trip_ = await httpService.getTrip(widget.trip?.trip_id);
      print("[TripPage.loadTrip][getTrip] ${trip.trip_status}");
      if (trip_.trip_id != 0) {
        setState(() {
          trip = trip_;
          showLoader = false;
          print(
              "[TripPage.loadTrip][trip_.lastPositionPayload] ${trip_.lastPositionPayload}");
          processTrackingMessage(trip_.lastPositionPayload);
        });
      }
    } catch (e) {
      print("[TripPage.loadTrip.error] $e");
    }
  }

  void cleanResources() {
    try {
      _emitterServiceProvider?.removeListener(onEmitterMessage);
      _notificationService.removeListener(onPushMessage);
      _connectivitySubscription.cancel();
      Wakelock.disable();
      
      // Limpiar el mapa
      annotationManager?.deleteAll();
      annotationManager = null;
      busPointAnnotation = null;
      
      // Desuscribirse de eventos
      if (trip.trip_status == "Running") {
        trip.unSubscribeToTripTracking(_emitterServiceProvider);
        trip.unSubscribeToTripEvents(_emitterServiceProvider);        
      }
    } catch (e) {
      print("Error cleaning resources: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    cleanResources();
  }

  @override
  void initState() {
    super.initState();

    trip = widget.trip!;
    _lastPositionPayload = trip.lastPositionPayload;

    loadTrip();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status ${e.toString()}');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    setState(() {
      connectivityNone =
          results.any((result) => result == ConnectivityResult.none);
    });
    // ignore: avoid_print
    print('connectivityNone: $connectivityNone');
  }

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    // _showInfoWindow(annotation);
  }

  // void _showInfoWindow(PointAnnotation annotation) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return Container(
  //         padding: EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Información del Marker',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             SizedBox(height: 8.0),
  //             Text('ID: ${annotation.id}'),
  //             Text('Coordenadas:'),
  //             // Puedes agregar más información aquí
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void showTripGeoJson(MapboxMap mapboxMap) async {
    print("[TripPage.showTripGeoJson]");

    Map<String, dynamic> data = trip.geoJson!;
    int lineColorValue = Colors.blue.value;
    if (trip.route_attributes != null && trip.route_attributes!["lineColor"] != null) {
      lineColorValue = _convertColor(trip.route_attributes!["lineColor"]);
    }

    await mapboxMap.style
        .addSource(GeoJsonSource(id: "trip_source", data: jsonEncode(data)));

    await mapboxMap.style.addLayer(LineLayer(
        id: "line_layer",
        sourceId: "trip_source",
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineColor: lineColorValue,
        lineBlur: 1.0,
        lineDasharray: [1.0, 2.0],
        lineWidth: 6.0,
        lineSortKey: 0));
  }

  int _convertColor(String colorStr) {
    colorStr = colorStr.trim();
    if (colorStr.toLowerCase().startsWith('rgba')) {
      final regExp = RegExp(
        r'rgba\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*([\d.]+)\s*\)',
      );
      final match = regExp.firstMatch(colorStr);

      if (match != null) {
        int r = int.parse(match.group(1)!);
        int g = int.parse(match.group(2)!);
        int b = int.parse(match.group(3)!);
        double a = double.parse(match.group(4)!);

        int alpha = (a * 255).round() & 0xFF;
        return (alpha << 24) | (r << 16) | (g << 8) | b;
      } 
    }else if (colorStr.toLowerCase().startsWith('rgb')) {
        final regExp = RegExp(r'rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)');
        final match = regExp.firstMatch(colorStr);

        if (match != null) {
          int r = int.parse(match.group(1)!);
          int g = int.parse(match.group(2)!);
          int b = int.parse(match.group(3)!);
          return (0xFF << 24) | (r << 16) | (g << 8) | b;
        }
    } else {
        colorStr = colorStr.toUpperCase().replaceAll('#', '');

        if (colorStr.length == 3) {
          colorStr = colorStr.split('').map((c) => c + c).join('');
        }

        if (colorStr.length == 6) {
          colorStr = 'FF$colorStr';
        }
        return int.parse(colorStr, radix: 16);
    }
    return 0xFF000000;
  }
  //hay que probar
  Future<Uint8List> createCircleMarkerImage({
    required Color circleColor,
    required IconData icon,
    double size = 160,
    Color iconColor = Colors.white,
    double iconSize = 80,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()..color = circleColor;
    final center = Offset(size / 2, size / 2);

    canvas.drawCircle(center, size / 2, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          color: iconColor,
          package: icon.fontPackage,
        ),
      ),
      textDirection: ui.TextDirection.ltr,  
    )..layout();

    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  IconData _getIconByType(String iconName) {
    if (iconName.isEmpty) return FontAwesomeIcons.locationDot;
    
    String normalizedName = iconName.toLowerCase().trim();

    switch (normalizedName) {
      case 'pickup-point':
        return FontAwesomeIcons.personShelter;
      case 'school':
        return FontAwesomeIcons.school;
      case 'parking':
        return FontAwesomeIcons.squareParking;
      case 'waypoint':
        return FontAwesomeIcons.mapPin;
      default:
        return FontAwesomeIcons.locationDot;
    }
  }


  void showPickupLocations(MapboxMap mapboxMap) async {
    print("[TripPage.showPickupLocations]");
    
    List<Position> points = [];

    for (var pickupPoint in trip.pickup_locations!) {
      if (pickupPoint.location == null) continue;
      
      final position = Position(
        pickupPoint.location!.longitude as double,
        pickupPoint.location!.latitude as double
      );
      
      final Uint8List customMarker = await createCircleMarkerImage(
        circleColor: Colors.green,  
        icon: _getIconByType(pickupPoint.location?.point_type ?? ''),  
        size: 130, 
        iconColor: Colors.white,  
        iconSize: 70,  
      );
      
      final point = PointAnnotationOptions(
        textField: "${pickupPoint.location?.location_name}",
        textOffset: [0.0, -1.5],
        textColor: Colors.black.value,
        textLineHeight: 1,
        textSize: 15,
        iconSize: 0.9,  
        iconOffset: [0.0, -5.0],
        symbolSortKey: 1,
        geometry: Point(coordinates: position),
        image: customMarker
      );  
      
      annotationManager?.create(point);
      points.add(position);
    }

    try {
      tripDuration = Utils.formatElapsedTime(trip.dt!);
    } catch (e) {
      print("[TripPage.initState.formatElapsedTime.error] $e");
    }

    if (trip.lastPositionPayload != null &&
        relationName != "eta.drivers" &&
        trip.trip_status == "Running") {
      print(
          "[TripPage.initState] lastPositionPayload ${trip.lastPositionPayload}");
      final Position position = trip.lastPosition()!;
      final label = formatUnixEpoch(trip.lastPositionPayload['time'].toInt());

      _updateIcon(position, 'eta.drivers', trip.driver_id!, label); // aqui es la cosa
      mapboxMap.setCamera(CameraOptions(zoom: 18, pitch: 70));
    } else {
      final coordinateBounds = getCoordinateBounds(points);
      mapboxMap.setCamera(CameraOptions(
          center: coordinateBounds.southwest, zoom: 18, pitch: 45));
    }
  }

  _updatePulsatingCircle(Point point) async{
    final coordinate = await _mapboxMapController?.pixelForCoordinate(point);
    print("[_updatePulsatingCircle] ${coordinate?.x}");
    setState(() {
      busPulsatingCircleCoordinate = coordinate!;
    });

      Timer(Duration(seconds: 1), () {
        setState(() {
          busPulsatingCircleCoordinate.x = 0;
        });
      });
  }

  Future<void> _updateBusModelCoordinates(Point point) async {
    try {
      final coordinate = await _mapboxMapController?.pixelForCoordinate(point);
      if (coordinate == null || !mounted) return;

      // Obtener el estado actual de la cámara
      final cameraState = await _mapboxMapController?.getCameraState();
      final mapBearing = cameraState?.bearing ?? 0;
      
      // Heading real del bus desde GPS (norte verdadero)
      final busTrueHeading = _lastPositionPayload?['heading']?.toDouble() ?? 270;
      
      // Calcular el heading visual ajustado
      // Restamos el bearing del mapa para compensar la rotación de la cámara
      final adjustedHeading = (busTrueHeading - mapBearing + 360) % 360;

      if (mounted) {
        setState(() {
          busModelCoordinate = coordinate;
          busHeading = adjustedHeading;
        });
      }
    } catch (e) {
      print("Error en _updateBusModelCoordinates: $e");
    }
  }

    Future<void> _updateIcon(Position position, String relationName,
        int relationId, String label) async {
      String key = "$relationName.$relationId";
      print(
          "[TripPage._updateIcon] [relationName] $relationName [relationId] $relationId");

      if(key.isEmpty){
        return;
      }

      // is the trip driver?
      if (relationName != "eta.drivers") {
        return;
      }
      if (trip.driver_id != relationId) {
        print(
            "[TripPage._updateIcon] is not the driver of this trip [${trip.driver_id}  $relationId]");
        return;
      }

      try {
        // If the annotation doesn't exist, create it
        if (busPointAnnotation == null) {
          print("[TripPage._updateIcon] creating new point annotation");
          final ByteData bytes = await rootBundle.load('assets/blank.png');
          final Uint8List imageData = bytes.buffer.asUint8List();

          busPointAnnotation = await annotationManager?.create(PointAnnotationOptions(
            geometry: Point(coordinates: position),
            image: imageData,
            textField: label,
            textOffset: [0.0, -2.8],
            textColor: Colors.black.value,
          ));
        } 
        // If it exists, update it
        else if (annotationManager != null) {
          print("[TripPage._updateIcon] updating existing point annotation");
          busPointAnnotation?.geometry = Point(coordinates: position);
          busPointAnnotation?.textField = label;
          await annotationManager?.update(busPointAnnotation!);
        }

        if (relationName.indexOf("drivers") > 1) {
          _mapboxMapController?.setCamera(CameraOptions(
            center: Point(coordinates: position),
            zoom: 18,
            pitch: 70
          ));
        }
        _updateBusModelCoordinates(Point(coordinates: position));
      } catch (e) {
        print("[TripPage._updateIcon] error: ${e.toString()}");
        // If update fails, recreate the annotation
        busPointAnnotation = null;
        _updateIcon(position, relationName, relationId, label);
      }
    }
  //  void _animateIcon(LatLng start, LatLng end) {
  //   const int animationDuration = 1000; // Duración en milisegundos
  //   const int frameRate = 60; // Frames por segundo
  //   final int totalFrames = (animationDuration / (1000 / frameRate)).round();

  //   double latDiff = end.latitude - start.latitude;
  //   double lonDiff = end.longitude - start.longitude;

  //   Timer.periodic(Duration(milliseconds: (1000 / frameRate).round()), (timer) {
  //     double t = timer.tick / totalFrames;
  //     if (t > 1.0) {
  //       t = 1.0;
  //       timer.cancel();
  //     }
  //     double latitude = start.latitude + latDiff * t;
  //     double longitude = start.longitude + lonDiff * t;
  //     _mapboxMapController.updateSymbol(
  //       _symbol!,
  //       SymbolOptions(
  //         geometry: LatLng(latitude, longitude),
  //       ),
  //     );
  //   });
  // }

  void onEmitterMessage() async {

    if (!_isVisible) return; // No procesar si no está visible

    final String message = _emitterServiceProvider!.lastMessage();

    if (mounted) {
      setState(() {
        tripDuration = Utils.formatElapsedTime(trip.dt!);
      });
    }

    try {
      if(!widget.navigationMode){
        processTrackingMessage(jsonDecode(message));
      }
    } catch (e) {
      await proccessTripEventMessage(message);
    }
  }

  void processTrackingMessage(Map<String, dynamic> tracking) async {
    print("[processTrackingMessage] $tracking");

    if (_lastPositionPayload != null &&
        _lastPositionPayload?['time'].toInt() >
            tracking['payload']['time'].toInt()) {
      print("[trippage.processTrackingMessage.ignore position by time]");
      return;
    }

    if (tracking['relation_name'] != null &&
        tracking['relation_name'] == "eta.drivers") {
      final relationName = tracking['relation_name'];
      final relationId = tracking['relation_id'];

      if (tracking['payload'] != null) {
        final Position position = Position(
            double.parse("${tracking['payload']['longitude']}"),
            double.parse("${tracking['payload']['latitude']}"));
        final label = formatUnixEpoch(tracking['payload']['time'].toInt());

        try {
          tripDistance = double.parse("${tracking['payload']['distance']}");
        } catch (e) {
          //
        }

        _updateIcon(position, relationName, relationId, label);

        _lastPositionPayload = tracking['payload'];
        try {
          busHeading = _lastPositionPayload?['heading'] ?? _lastPositionPayload?['heading'];
          // print("busHeading: $busHeading");
        } catch (e) {
          print("busHeading error $e");
        }
        emitterServiceProvider.updateLastEmitterDate(DateTime.now());
      }
    }
  }

  Future<void> proccessTripEventMessage(String message) async {
    try {
      // si es un evento del viaje
      final event = EventModel.fromJson(jsonDecode(message));
      if (event.type == "end-trip" && relationName != 'eta.drivers') {
        try {
          _emitterServiceProvider?.stopTimer();
          trip.unSubscribeToTripEvents(_emitterServiceProvider);
          trip.unSubscribeToTripTracking(_emitterServiceProvider);
        } catch (e) {
          //
        }
        
        if (mounted) {
          setState(() {
            Get.back();
          });
        }
      } else {
        final updatedTrip = await httpService.getTrip(trip.trip_id);
        if (mounted) {
          setState(() {
            trip = updatedTrip;
          });
        }
      }
    } catch (e) {
      // print("[TripPage] $e");
    }
  }

  String formatUnixEpoch(int unixEpoch) {
    // Convierte el Unix Epoch (segundos) a milisegundos
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixEpoch);

    return Utils.formatearFechaCorta(dateTime);
  }

  onPushMessage() {
    print("[TripPage.onPushMessage]");

    final LastMessage? lastMessage = notificationServiceProvider.lastMessage;
    print("[TripPage.onPushMessage] ${lastMessage!}");
    if (mounted) {
      setState(() {
        // if (lastMessage?.status == 'foreground') {
        notificationServiceProvider.showTooltip(
            context, lastMessage.lastMessage);
        // }
      });
    } else {
      print("[TripPage.onPushMessage] not mounted");
    }
  }
}

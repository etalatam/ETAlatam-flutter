import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eta_school_app/Pages/map/mapbox_utils.dart';
import 'package:eta_school_app/Pages/providers/emitter_service_provider.dart';
import 'package:eta_school_app/Pages/providers/notification_provider.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Pages/attendance_page.dart';
import 'package:eta_school_app/Pages/providers/location_service_provider.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
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
import 'package:wakelock/wakelock.dart';

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

  bool isActiveTrip = true;

  String activeTab = 'pickup';

  TripModel trip = TripModel(trip_id: 0);

  bool showTripReportModal = false;

  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  MapboxMap? _mapboxMapController;

  String relationName = '';

  PointAnnotationManager? annotationManager;

  Map<String, PointAnnotation> annotationsMap = {};

  bool waitingBusPosition = true;

  // ScreenCoordinate busPulsatingCircleCoordinate = ScreenCoordinate( x: 0, y: 0);

    bool connectivityNone = false;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;


  @override
  Widget build(BuildContext context) {
    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(
                children: <Widget>[
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

                      mapboxMap.annotations
                          .createPointAnnotationManager()
                          .then((value) async {
                        annotationManager = value;
                        annotationManager?.addOnPointAnnotationClickListener(this);
                      });
                    },
                    onStyleLoadedListener: (MapboxMap mapboxMap) async {
                      showTripGeoJson(mapboxMap);
                      showPickupLocations(mapboxMap);
                    },
                  ),
                ),

                if(connectivityNone)
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
                              borderRadius: BorderRadius.circular(20), // Cambia el valor para ajustar el radio
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wifi_off, color: Colors.white),
                                SizedBox(width: 10),
                                Text('No hay conexión a Internet', style: TextStyle(color: Colors.white)),
                              ],
                            )
                        ),
                      ),
                      ),
                    ],
                  )),
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

                // if(busPulsatingCircleCoordinate.x.toDouble() > 0)
                // Positioned(
                //   left: busPulsatingCircleCoordinate.x.toDouble() - 25,
                //   top: busPulsatingCircleCoordinate.y.toDouble() - 25,
                //   child: Consumer<EmitterService>(builder: (context, emitterService, child) {
                //     return PulsatingCircle(
                //       color: emitterService.client!.isConnected ? Colors.green :  Colors.red
                //     );
                //   })
                // ),

                DraggableScrollableSheet(
                  snapAnimationDuration: const Duration(seconds: 1),
                  initialChildSize: trip.trip_status == 'Running' ? .5 : .29,
                  minChildSize: 0.29,
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
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 1,
                            color: activeTheme.main_color.withOpacity(.2),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: storage
                                          .getItem('lang')
                                          .toString()
                                          .toLowerCase() ==
                                      'español'
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${lang.translate('Trip')} #${trip.trip_id}",
                                      style: activeTheme.h3,
                                    ),
                                    Text(
                                      "${trip.trip_date}",
                                      style: activeTheme.normalText,
                                    ),
                                    if (trip.trip_status == 'Completed' &&
                                        relationName.contains('eta.drivers'))
                                      GestureDetector(
                                          onTap: (() {
                                            openNewPage(context,
                                                AttendancePage(trip: trip));
                                          }),
                                          child: Center(
                                              child: ButtonTextIcon(
                                                  '',
                                                  Icon(
                                                    Icons.list,
                                                    color: activeTheme.buttonBG,
                                                  ),
                                                  activeTheme.buttonColor))),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.3),
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
                                                  color:
                                                      activeTheme.buttonColor,
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
                                                lang.translate('Attendance'),
                                                Icon(
                                                  Icons.list,
                                                  color:
                                                      activeTheme.buttonColor,
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
                                          tripUser(trip.pickup_locations![i]),
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
                showTripReportModal ? TripReport(trip: trip) : const Center(),
              ]),
              // ])
            ),
            
    );
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
    print('[TripPage.tripUser.pickupLocation]');
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
    try {
      setState(() {
        showLoader = true;
      });
      await trip.endTrip();
      locationServiceProvider.stopLocationService();
      Wakelock.disable();
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
  }

  loadTrip() async {
    final LocalStorage storage = LocalStorage('tokens.json');
    final userId = await storage.getItem('id_usu');
    final relationNameLocal = await storage.getItem('relation_name');
    print("[TipPage.loadTrip.userId] $userId");
    print("[TipPage.loadTrip.relationNameLocal] $relationNameLocal");

    TripModel? trip_ = await httpService.getTrip(trip.trip_id);
    if (trip_.trip_id != 0) {
      setState(() {
        trip = trip_;
        isActiveTrip = true;
        showLoader = false;
        relationName = relationNameLocal;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
  }

  @override
  void initState() {
    super.initState();

    loadTrip();

    setState(() {
      trip = widget.trip!;
    });

    if (trip.trip_status == "Running") {
      Wakelock.enable();

      if (widget.showBus || widget.showStudents) {
        Provider.of<EmitterService>(context, listen: false)
            .addListener(onEmitterMessage);
      }
      
      Provider.of<NotificationService>(context, listen: false)
          .addListener(onPushMessage);

      initConnectivity();

      _connectivitySubscription =
      _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    }
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
      connectivityNone = results.any((result) => result == ConnectivityResult.none);
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

    await mapboxMap.style
        .addSource(GeoJsonSource(id: "trip_source", data: jsonEncode(data)));

    await mapboxMap.style.addLayer(LineLayer(
      id: "line_layer",
      sourceId: "trip_source",
      lineJoin: LineJoin.ROUND,
      lineCap: LineCap.ROUND,
      lineColor: Colors.blue.value,
      lineBlur: 1.0,
      lineDasharray: [1.0, 2.0],
      lineWidth: 6.0,
      lineSortKey: 0
    ));
  }

  void showPickupLocations(MapboxMap mapboxMap) async {
    print("[TripPage.showPickupLocations]");
    final ByteData bytes =
        await rootBundle.load('assets/markers/marker-start-route.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    List<Position> points = [];

    for (var pickupPoint in trip.pickup_locations!) {
      final position = Position(pickupPoint.location!.longitude as double,
          pickupPoint.location!.latitude as double);
      final point = PointAnnotationOptions(
          textField: "${pickupPoint.location?.location_name}",
          textOffset: [0.0, -2.0],
          textColor: Color.fromARGB(255, 2, 54, 37).value,
          textLineHeight: 15,
          textSize: 15,
          iconSize: 0.8,
          iconOffset: [0.0, -5.0],
          symbolSortKey: 1,
          geometry: Point(coordinates: position),
          image: imageData);
      annotationManager?.create(point);
      points.add(position);
    }

    final coordinateBounds = getCoordinateBounds(points);
    mapboxMap.setCamera(CameraOptions(
        center: coordinateBounds.southwest, zoom: 15.5, pitch: 70));
  }

  // _updatePulsatingCircle(Point point) async{
  //   final coordinate = await _mapboxMapController?.pixelForCoordinate(point);
  //   print("[_updatePulsatingCircle] ${coordinate?.x}");
  //   setState(() {
  //     busPulsatingCircleCoordinate = coordinate!;
  //   });
  // }

  Future<void> _updateIcon(
      Position position, String relationName, int relationId) async {
    PointAnnotation? pointAnnotation =
        annotationsMap.containsKey("$relationName.$relationId")
            ? annotationsMap["$relationName.$relationId"]
            : null;

    // if (relationName.indexOf("drivers") > 1) {
    //   _updatePulsatingCircle(Point(coordinates: position));
    // }

    // If it does not exist, the new element is created on the map
    if (pointAnnotation == null) {

      // is driver?
      if (relationName.indexOf("drivers") > 1) {
        print("[TripPage._updateIcon.driver_id] $relationId [trip.driver_id] ${trip.driver_id}");
        // is the trip driver?
        if(trip.driver_id != relationId){
          return;
        }
        final ByteData bytes = await rootBundle.load('assets/moving_car.gif');
        final Uint8List imageData = bytes.buffer.asUint8List();

        pointAnnotation = await mapboxUtils.createAnnotation(
            annotationManager, position, imageData);
        annotationsMap["$relationName.$relationId"] = pointAnnotation!;
      } else {
        // any user who wishes will be shown on the map, examples for students
        final networkImage = await mapboxUtils.getNetworkImage(
            httpService.getAvatarUrl(relationId, relationName));
        final circleImage = await mapboxUtils.createCircleImage(networkImage);
        pointAnnotation = await mapboxUtils.createAnnotation(
            annotationManager, position, circleImage);
        annotationsMap["$relationName.$relationId"] = pointAnnotation!;
      }
    } else {
      pointAnnotation.geometry = Point(coordinates: position);
      annotationManager?.update(pointAnnotation);
    }

    if (relationName.indexOf("drivers") > 1) {
      print("[TripPage._updateIcon.relationName] $relationName");
      _mapboxMapController?.setCamera(
            CameraOptions(center: Point(coordinates: position)));
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
    if (mounted) {
      final String? message =
          Provider.of<EmitterService>(context, listen: false).lastMessage;

      try {
        // si es un evento del viaje
        final event = EventModel.fromJson(jsonDecode(message!));
        if(event.type == "end-trip" && relationName != 'eta.drivers'){
          setState(() {
            Get.back();
          });
        }else{
          await event.requestData();
        }
      } catch (e) {
        //si es un evento posicion
        final Map<String, dynamic> tracking = jsonDecode(message!);

        if (tracking['relation_name'] != null) {
          final relationName = tracking['relation_name'];
          final relationId = tracking['relation_id'];

          if (tracking['payload'] != null) {
            final Position position = Position(
                double.parse("${tracking['payload']['longitude']}"),
                double.parse("${tracking['payload']['latitude']}"));

            if (relationId != null &&
                relationName == 'eta.drivers' &&
                widget.showBus) {
              print(
                  "[TripPage.onEmitterMessage.emitter-tracking.driver] $tracking");
              _updateIcon(position, relationName, relationId);
            } else if (relationName == 'eta.students' && widget.showStudents) {
              print(
                  "[TripPage.onEmitterMessage.emitter-tracking.student] $tracking");
              _updateIcon(position, relationName, relationId);
            }
          }
        }
      }
    }
  }

  onPushMessage(){
    if(!mounted) return;
    final LastMessage? lastMessage =
          Provider.of<NotificationService>(context, listen: false).lastMessage;

    setState(() {
      if(lastMessage?.status == 'foreground'){
        notificationServiceProvider.showTooltip(context, lastMessage!.lastMessage);
      }
    });
  }  
}

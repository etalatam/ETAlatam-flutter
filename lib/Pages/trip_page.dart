import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Pages/attendance_page.dart';
import 'package:eta_school_app/Pages/providers/location_service_provider.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/tripReportPage.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/components/button_text_icon.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'map/map_wiew.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key, this.trip, this.navigationMode, required this.showBus});

  final TripModel? trip;

  final String? navigationMode;

  final bool showBus;

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

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  MapboxMap? _mapboxMapController;

  String relationName = '';

  PointAnnotationManager? annotationManager;

  Map<String, PointAnnotation> annotationsMap = {};
  
  @override
  Widget build(BuildContext context) {

    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.40,
                  child: MapWiew(
                    navigationMode: widget.navigationMode == null ? false : (
                        trip.trip_status == 'Running' ? true : false ),
                    onMapReady: (MapboxMap mapboxMap) async {
                      _mapboxMapController = mapboxMap;

                      mapboxMap.annotations.createPointAnnotationManager().then((value) async {
                        annotationManager = value;
                      });
                    },
                    onStyleLoadedListener: (MapboxMap mapboxMap) async {
                      showTripGeoJson(mapboxMap);
                      showPickupLocations(mapboxMap);
                    },
                  ),
                ),
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
                                          onTap: (() {
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
                                                  Colors.red))),
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
      await trip.endTrip();
      locationServiceProvider.stopLocationService();
      setState(() {
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
    TripModel? trip_ = await httpService.getTrip(trip.trip_id);
    final LocalStorage storage = LocalStorage('tokens.json');
    final userId = await storage.getItem('id_usu');
    final relationNameLocal = await storage.getItem('relation_name');
    print("[TipPage.loadTrip.userId] $userId");
    print("[TipPage.loadTrip.relationNameLocal] $relationNameLocal");

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
  void initState() {
    super.initState();

    loadTrip();

    setState(() {
      trip = widget.trip!;
    });
    
    if(widget.showBus){
      Provider.of<EmitterService>(context, listen: false).addListener(onEmitterMessage);
    }
    
  }

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    // _showInfoWindow(annotation);
  }

  void _showInfoWindow(PointAnnotation annotation) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información del Marker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text('ID: ${annotation.id}'),
              Text('Coordenadas:'),
              // Puedes agregar más información aquí
            ],
          ),
        );
      },
    );
  }

  void showTripGeoJson(MapboxMap mapboxMap) async {
    print("[TripPage.showTripGeoJson]");

    Map<String, dynamic> data = trip.geoJson!;

    await mapboxMap.style.addSource(GeoJsonSource(
      id: "trip_source", 
      data: jsonEncode(data)
    ));

    await mapboxMap.style.addLayer(LineLayer(
      id: "line_layer",
      sourceId: "trip_source",
      lineJoin: LineJoin.ROUND,
      lineCap: LineCap.ROUND,
      lineColor: Colors.blue.value,
      lineBlur: 1.0,
      lineDasharray: [1.0, 2.0],
      lineWidth: 6.0,
      
      ));
  }
  
  void showPickupLocations(MapboxMap mapboxMap) async {
    print("[TripPage.showPickupLocations]");
    final ByteData bytes =
        await rootBundle.load('assets/markers/marker-start-route.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    final pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    pointAnnotationManager.addOnPointAnnotationClickListener(this);

    List<Position> points = [];

    for (var pickupPoint in trip.pickup_locations!) {
      final position = Position(pickupPoint.location!.longitude as double,
          pickupPoint.location!.latitude as double);
      final point = PointAnnotationOptions(
          textField: "${pickupPoint.location?.location_name}",
          textOffset: [0.0, -2.5],
          textColor: Color.fromARGB(255, 2, 54, 37).value,
          textLineHeight: 20,
          textSize: 20,
          iconSize: 1.3,
          iconOffset: [0.0, -5.0],
          symbolSortKey: 10,
          geometry: Point(coordinates: position),
          image: imageData);
      pointAnnotationManager.create(point);
      points.add(position);
    }

    final coordinateBounds = getCoordinateBounds(points);
    mapboxMap.setCamera(CameraOptions(
        center: coordinateBounds.southwest, zoom: 15.5, pitch: 70));
  }

  Future<void> _updateIcon(Position position, String relationName, int relationId) async {
    PointAnnotation? pointAnnotation = annotationsMap["$relationName.$relationId"];    
    
    if(pointAnnotation == null){
      if(relationName.indexOf("drivers") > 1){
        final ByteData bytes =
            await rootBundle.load('assets/moving_car.gif');
        final Uint8List imageData = bytes.buffer.asUint8List();

          pointAnnotation = await createAnnotation(position, imageData);
          annotationsMap["$relationName.$relationId"] = pointAnnotation!;
      }else{
        final networkImage = await getNetworkImage(httpService.getAvatarUrl(relationId, relationName));
        final circleImage = await createCircleImage(networkImage);
        pointAnnotation = await createAnnotation(position, circleImage);
      }
      
    }else{
      pointAnnotation.geometry = Point(
        coordinates: position
      );
      annotationManager?.update(pointAnnotation);
    }
    _mapboxMapController?.setCamera(CameraOptions(
        center: Point(coordinates: position)));
  }
  
  Future<Uint8List> getNetworkImage(String imageUrl) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));
    final Uint8List bytes = response.bodyBytes;
    
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageData = byteData!.buffer.asUint8List();

    return  imageData;
  }

   Future<Uint8List> createCircleImage(Uint8List imageData) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();
    const double size = 100.0;

    final ui.Image image = await decodeImageFromList(imageData);
    final Rect rect = Rect.fromLTWH(0, 0, size, size);
    final Path path = Path()..addOval(rect);
    canvas.clipPath(path);
    canvas.drawImageRect(image, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), rect, paint);

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image circularImage = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await circularImage.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  } 

  Future<PointAnnotation?> createAnnotation(Position position, Uint8List imageData) async {

    return await annotationManager
        ?.create(PointAnnotationOptions(
            geometry: Point(
                coordinates: position),
            textField: "",
            textOffset: [0.0, -2.0],
            textColor: Colors.black.value,
            iconSize: 0.5,
            iconOffset: [0.0, -5.0],
            symbolSortKey: 10,
            image: imageData));
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
      final String? message = Provider.of<EmitterService>(context, listen: false).lastMessage;
      try {
        // si es une evento del viaje
        final event = EventModel.fromJson(jsonDecode(message!));
        await event.requestData();        
      } catch (e) {
        //si es un evento posicion
        final Map<String, dynamic> tracking = jsonDecode(message!);

        if(tracking['relation_name'] != null){
          
          final relationName = tracking['relation_name'];
          final relationId = tracking['relation_id'];

          if(tracking['payload'] != null){
            
            if(relationId!=null && relationName == 'eta.drivers' && widget.showBus){
              print("[TripPage.onEmitterMessage.emitter-tracking.driver] $tracking");
              _updateIcon(Position(
                double.parse("${tracking['payload']['longitude']}"), 
                double.parse("${tracking['payload']['latitude']}")
              ),relationName, relationId);
            } else if(relationName == 'eta.students' && widget.showBus){
              print("[TripPage.onEmitterMessage.emitter-tracking.student] $tracking");
              _updateIcon(Position(
                double.parse("${tracking['payload']['longitude']}"), 
                double.parse("${tracking['payload']['latitude']}")
              ),relationName, relationId);
            }

          }
        }
      }
    }
  }
}

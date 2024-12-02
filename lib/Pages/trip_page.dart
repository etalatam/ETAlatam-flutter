import 'dart:math';

import 'package:eta_school_app/Pages/attendance_page.dart';
import 'package:eta_school_app/Pages/providers/location_service_provider.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/tripReportPage.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/components/button_text_icon.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'map/map_wiew.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key, this.trip});

  final TripModel? trip;

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

  // Object? customRoute;

  // LatLng? mapDestination;

  // LatLng? mapOrigin;

  // String currentPicture = "";

  bool showTripReportModal = false;

  // bool hasCustomRoute = false;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  MapboxMap? _mapboxMapController;

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

    print('[trip.getCoordinateBounds] $minLng, $minLat');
    print('[trip.getCoordinateBounds] $maxLng, $maxLat');

    return CoordinateBounds(
      southwest: Point(coordinates: Position(minLng, minLat)),
      northeast: Point(coordinates: Position(maxLng, maxLat)),
      infiniteBounds: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // print("[TripPage:build] ${widget.trip?.vehicle?.last_latitude}");
    // mapDestination = LatLng(trip.route!.latitude!, trip.route!.longitude!);
    // mapOrigin = LatLng(trip.vehicle!.last_latitude!, trip.vehicle!.last_longitude!);
    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.40,
                  child: MapWiew(
                    navigationMode:
                        trip.trip_status == 'Running' ? true : false,
                    onMapReady: (MapboxMap mapboxMap) async {
                      _mapboxMapController = mapboxMap;
                      _showPickupLocations();
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
                                    if (trip.trip_status == 'Completed')
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
                                  (trip.waiting_locations_count != 0 ||
                                          trip.trip_status
                                                  .toString()
                                                  .toLowerCase() ==
                                              'completed')
                                      ? const Center()
                                      : GestureDetector(
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
                                  if (trip.trip_status == 'Running')
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
                                // for (var i = 0;
                                //     i < trip.destinations!.length;
                                //     i++)
                                //   activeTab == 'destination'
                                //       ? Slideable(
                                //           model: trip.destinations![i],
                                //           hasLeft: true,
                                //           hasRight:
                                //               trip.destinations![i].status ==
                                //                       'waiting'
                                //                   ? true
                                //                   : false,
                                //           widget: Container(
                                //             margin: const EdgeInsets.only(
                                //                 bottom: 10, top: 10),
                                //             child:
                                //                 tripUser(trip.destinations![i]),
                                //           ),
                                //           finishCallback: finishDestination,
                                //         )
                                //       : const Center()
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

  Widget headWidget(item) {
    // final user = hasCustomRoute ? item.student : item;
    // currentPicture = user?.picture ?? ' ';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        // Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 20),
        //     child: CircleAvatar(
        //         radius: 50,
        //         foregroundImage:
        //             NetworkImage(httpService.getAvatarUrl(currentPicture)))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   padding: const EdgeInsets.only(top: 15),
            //   child: Text("${user.first_name}",
            //       style: TextStyle(
            //           fontSize: activeTheme.h5.fontSize,
            //           fontWeight: activeTheme.h4.fontWeight,
            //           color: Colors.white)),
            // ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //   decoration: BoxDecoration(
            //       color: activeTheme.buttonBG,
            //       borderRadius: const BorderRadius.all(Radius.circular(10))),
            //   margin: const EdgeInsets.only(top: 15),
            //   child: Text("${user.contact_number}",
            //       style: TextStyle(
            //         color: activeTheme.buttonColor,
            //         fontWeight: FontWeight.bold,
            //       )),
            // ),
          ],
        ),
        // const Expanded(child: Center()),
        // Column(
        //   children: [
        //     const SizedBox(height: 50),
        //     Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         mainAxisSize: MainAxisSize.max,
        //         children: [
        //           GestureDetector(
        //             onTap: () {
        //               launchCall(user.contact_number);
        //             },
        //             child: Padding(
        //               padding:
        //                   const EdgeInsets.only(top: 10, right: 20, left: 20),
        //               child: Icon(
        //                 Icons.call,
        //                 color: activeTheme.icon_color,
        //               ),
        //             ),
        //           ),
        //           GestureDetector(
        //             onTap: () {
        //               launchWP(user.contact_number);
        //             },
        //             child: Padding(
        //               padding:
        //                   const EdgeInsets.only(top: 10, right: 20, left: 20),
        //               child: Icon(
        //                 Icons.maps_ugc_outlined,
        //                 color: activeTheme.icon_color,
        //               ),
        //             ),
        //           ),
        //         ])
        //   ],
        // )
      ],
    );
  }

  Widget tripUser(TripPickupLocation pickupLocation) {
    print('[TripPage.tripUser.pickupLocation] ${pickupLocation.toString()}');
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
            Text(
              // '${pickupLocation.student!.student_name}',
              '${pickupLocation.location?.location_name}',
              style: activeTheme.h5,
            ),
            SizedBox(
                width: 300,
                child: Text(
                  // '${pickupLocation.student!.student_name}',
                  '${pickupLocation.location?.address}',
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: activeTheme.smallText.fontSize,
                      color: activeTheme.smallText.color),
                )),
            // pickupLocation.student == null
            //     ? const Text("")
            //     : Text(
            //         // '${pickupLocation.student!.student_name}',
            //         '${pickupLocation.location_name}',
            //         style: activeTheme.h5,
            //       ),
            const SizedBox(
              height: 5,
            ),
            // pickupLocation.status == 'waiting'
            //     ? Text(lang.translate('Waiting'),
            //         style: const TextStyle(color: Colors.red))
            //     : Text(
            //         '${pickupLocation.status}',
            //         style: TextStyle(
            //             fontSize: activeTheme.smallText.fontSize,
            //             color: activeTheme.smallText.color),
            //       )
          ],
        )
      ]),
    );
  }

  // Widget? MapWiew(location) {
  //   if (trip.trip_status == 'Completed') {
  //     return StaticMap(
  //         origin: LatLng(trip.pickup_locations![0].latitude!,
  //             trip.pickup_locations![0].longitude!),
  //         destination: mapDestination!,
  //         pickup_locations: trip.pickup_locations,
  //         destinations: trip.destinations);
  //   }

  //   if (hasCustomRoute) {
  //     return CustomRouteMap(
  //         origin: mapOrigin!,
  //         destination: mapDestination!,
  //         pickup_locations: trip.pickup_locations);
  //   }

  //   if (mapOrigin == null) {
  //     return null;
  //   }
  //   return MapWithRoute(
  //       origin: mapOrigin!,
  //       destination: mapDestination!,
  //       pickup_locations: trip.pickup_locations,
  //       trip: trip);
  // }

  endTrip() async {
    try {
      await httpService.endTrip(widget.trip!.trip_id.toString());
      locationServiceProvider.stopLocationService();
      setState(() {
        showTripReportModal = true;
      });
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

  finish(TripPickupLocation pickupLocation) async {
    await httpService.updatePickup(
        pickupLocation.trip_pickup_id!, pickupLocation.trip_id!, 'moving');
    setState(() {
      markers = <MarkerId, Marker>{};
      loadTrip();
    });
  }

  finishDestination(TripDestinationLocation pickupLocation) async {
    await httpService.update_destination(
        pickupLocation.trip_destination_id!, pickupLocation.trip_id!, 'moving');
    setState(() {
      markers = <MarkerId, Marker>{};
      loadTrip();
    });
  }

  loadTrip() async {
    TripModel? trip_ = await httpService.getTrip(trip.trip_id);
    final LocalStorage storage = LocalStorage('tokens.json');
    final userId = await storage.getItem('id_usu');
    print("[TipPage.loadTrip.usrId] $userId");

    if (trip_.trip_id != 0) {
      trip = trip_;
      // currentPicture = "$userId";
      // currentPicture = "${trip.driver!.picture}";
      // mapDestination = LatLng(trip.route!.latitude!, trip.route!.longitude!);
      // mapOrigin = LatLng(trip.vehicle!.last_latitude!, trip.vehicle!.last_longitude!);
      isActiveTrip = true;
      showLoader = false;
    }
  }

  Map<MarkerId, Marker> loadMarkers() {
    // for (var i = 0; i < trip.pickup_locations!.length; i++) {
    //   final a = trip.pickup_locations![i];
    //   addMarker(a.location!.address!, LatLng(a.latitude!, a.longitude!),
    //       a.location!.address);
    // }
    return markers;
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      trip = widget.trip!;
    });
    loadTrip();
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

  void _showPickupLocations() async {
    final ByteData bytes =
        await rootBundle.load('assets/markers/marker-start-route.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    final pointAnnotationManager =
        await _mapboxMapController?.annotations.createPointAnnotationManager();

    pointAnnotationManager?.addOnPointAnnotationClickListener(this);

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
      pointAnnotationManager?.create(point);
      points.add(position);
    }

    final coordinateBounds = getCoordinateBounds(points);
    _mapboxMapController?.setCamera(CameraOptions(
        center: coordinateBounds.southwest, zoom: 15.5, pitch: 70));
  }
}

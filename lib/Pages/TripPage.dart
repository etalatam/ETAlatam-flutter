import 'package:MediansSchoolDriver/Pages/providers/location_service_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:MediansSchoolDriver/Models/TripModel.dart';
import 'package:MediansSchoolDriver/components/TripReportPage.dart';
import 'package:MediansSchoolDriver/components/Widgets.dart';
import 'package:MediansSchoolDriver/components/button_text_icon.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:MediansSchoolDriver/components/loader.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/components/TripMap.dart';
import 'package:MediansSchoolDriver/components/CustomRouteMap.dart';
import 'package:MediansSchoolDriver/components/Slideable.dart';
import 'package:MediansSchoolDriver/components/StaticMap.dart';
import 'package:localstorage/localstorage.dart';

import 'map/full_map.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key, this.trip});

  final TripModel? trip;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> with MediansWidgets, MediansTheme {
  bool showLoader = false;

  bool isActiveTrip = true;
  String activeTab = 'pickup';

  TripModel trip = TripModel(trip_id: 0);

  Object? customRoute;

  LatLng? mapDestination;

  LatLng? mapOrigin;

  // String currentPicture = "/uploads/images/60x60.png";
  String currentPicture = "";

  bool showTripReportModal = false;

  bool hasCustomRoute = false;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  Widget build(BuildContext context) {
    // print("[TripPage:build] ${widget.trip?.vehicle?.last_latitude}");
    mapDestination = LatLng(trip.route!.latitude!, trip.route!.longitude!);
    // mapOrigin = LatLng(trip.vehicle!.last_latitude!, trip.vehicle!.last_longitude!);
    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 1.33,
                  // decoration: ShapeDecoration(
                  //   image: DecorationImage(
                  //     image: NetworkImage(
                  //         httpService.getAvatarUrl(currentPicture)),
                  //     fit: BoxFit.fitHeight,
                  //   ),
                  //   shape: const RoundedRectangleBorder(),
                  // ),
                  // child: !showMap ? const Center() : MapWidget(customRoute),
                  // child: !showMap ? const Center() : MapView(),
                  child: !showMap ? const Center() : FullMap(),
                ),
                DraggableScrollableSheet(
                  snapAnimationDuration: const Duration(seconds: 1),
                  initialChildSize:
                      .5, // The initial size of the sheet (0.2 means 20% of the screen)
                  minChildSize:
                      0.25, // Minimum size of the sheet (10% of the screen)
                  maxChildSize:
                      0.8, // Maximum size of the sheet (80% of the screen)
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                        child: Stack(children: [
                      // Container(
                      //   width: double.infinity,
                      //   height: 75,
                      // clipBehavior: Clip.antiAlias,
                      // decoration: BoxDecoration(
                      //     gradient: LinearGradient(
                      //   begin: Alignment.topCenter,
                      //   end: Alignment.bottomCenter,
                      //   colors: [
                      //     Colors.black.withOpacity(0),
                      //     Colors.black.withOpacity(.1),
                      //   ],
                      // )),
                      // ),
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
                        child: Container(
                            child: Stack(children: [
                          // HeadWidget(
                          //     hasCustomRoute ? customRoute : trip.driver!),
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
                                    ? MediansWidgets.tripInfoRow(trip)
                                    : const Center(),
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
                                Container(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // GestureDetector(
                                        //     onTap: () {
                                        //       setState(() {
                                        //         activeTab = 'pickup';
                                        //       });
                                        //     },
                                        //     child: Text(
                                        //       lang.translate(
                                        //           "Pickup Locations"),
                                        //       style: activeTab == 'pickup'
                                        //           ? activeTheme.h5
                                        //           : activeTheme.h6,
                                        //     )
                                        //     ),

                                        // const SizedBox(width: 50),
                                        // GestureDetector(
                                        //     onTap: () {
                                        //       setState(() {
                                        //         activeTab = 'destination';
                                        //       });
                                        //     },
                                        //     child: Text(
                                        //       lang.translate("Destinations"),
                                        //       style: activeTab == 'destination'
                                        //           ? activeTheme.h5
                                        //           : activeTheme.h6,
                                        //     )),
                                      ]),
                                ),

                                for (var i = 0;
                                    i < trip.pickup_locations!.length;
                                    i++)
                                  activeTab == 'pickup'
                                      ? Row(children: [
                                          tripUser(trip.pickup_locations![i]),
                                        ])
                                      // Slideable(
                                      //     model: trip.pickup_locations![i],
                                      //     hasLeft: true,
                                      //     hasRight: trip.pickup_locations![i]
                                      //                 .status ==
                                      //             'waiting'
                                      //         ? true
                                      //         : false,
                                      //     widget: Container(
                                      //       margin: const EdgeInsets.only(
                                      //           bottom: 10, top: 5),
                                      //       child: tripUser(
                                      //           trip.pickup_locations![i]),
                                      //     ),
                                      //     finishCallback: finish,
                                      //   )
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
                        ])),
                      )
                    ]));
                  },
                ),
                showTripReportModal ? TripReport(trip: trip) : const Center(),
              ]),
            ),
    );
  }

  Widget HeadWidget(item) {
    final user = hasCustomRoute ? item.student : item;
    // currentPicture = user?.picture ?? ' ';

    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CircleAvatar(
                radius: 50,
                foregroundImage:
                    NetworkImage(httpService.getAvatarUrl(currentPicture)))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 15),
              child: Text("${user.first_name}",
                  style: TextStyle(
                      fontSize: activeTheme.h5.fontSize,
                      fontWeight: activeTheme.h4.fontWeight,
                      color: Colors.white)),
            ),
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
    ));
  }

  bool showMap = true;

  Widget tripUser(TripPickupLocation pickupLocation) {
    print('[TripPage.tripUser.pickupLocation] ${pickupLocation.toString()}');
    return GestureDetector(
      onTap: () {
        setState(() {
          // currentPicture = pickupLocation.student.picture;
          showMap = false;
        });

        setState(() {
          customRoute = pickupLocation;
          hasCustomRoute = true;
          // mapOrigin = LatLng(
          //     trip.vehicle!.last_latitude!, trip.vehicle!.last_longitude!);
          mapDestination =
              LatLng(pickupLocation.latitude!, pickupLocation.longitude!);
          showMap = true;
        });
      },
      child: Row(children: [
        // CircleAvatar(
        //   maxRadius: 40,
        //   backgroundColor: Colors.white,
        //   foregroundImage: NetworkImage(httpService.getAvatarUrl(currentPicture)),
        // ),
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

  Widget? MapWidget(location) {
    if (trip.trip_status == 'Completed') {
      return StaticMap(
          origin: LatLng(trip.pickup_locations![0].latitude!,
              trip.pickup_locations![0].longitude!),
          destination: mapDestination!,
          pickup_locations: trip.pickup_locations,
          destinations: trip.destinations);
    }

    if (hasCustomRoute) {
      return CustomRouteMap(
          origin: mapOrigin!,
          destination: mapDestination!,
          pickup_locations: trip.pickup_locations);
    }

    if (mapOrigin == null) {
      return null;
    }
    return MapWithRoute(
        origin: mapOrigin!,
        destination: mapDestination!,
        pickup_locations: trip.pickup_locations,
        trip: trip);
  }

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
    await httpService.update_pickup(
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
      currentPicture = "$userId";
      // currentPicture = "${trip.driver!.picture}";
      mapDestination = LatLng(trip.route!.latitude!, trip.route!.longitude!);
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

    // WidgetsBinding.instance.endOfFrame.then((_) {
    //   final locationService =
    //       Provider.of<ETALocationService>(context, listen: false);

    //   if (mounted) {
    //     locationService.askPermission();
    //   }
    // });

    setState(() {
      trip = widget.trip!;
    });
    loadTrip();
  }
}

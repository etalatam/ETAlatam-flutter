import 'dart:async';
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

class TripPage extends StatefulWidget {
  const TripPage({super.key, this.trip});

  final TripModel? trip;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> with MediansWidgets, MediansTheme {
  bool showLoader = true;

  bool isActiveTrip = true;
  String activeTab = 'pickup';

  TripModel trip = TripModel(trip_id: 0);

  Object? customRoute;

  LatLng? mapDestination;

  LatLng? mapOrigin;

  String currentPicture = "/uploads/images/60x60.png";

  bool showTripReportModal = false;

  bool hasCustomRoute = false;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  Widget build(BuildContext context) {
    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          httpService.croppedImage(currentPicture, 800, 1200)),
                      fit: BoxFit.fitHeight,
                    ),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: !showMap ? const Center() : MapWidget(customRoute),
                ),
                DraggableScrollableSheet(
                  snapAnimationDuration: const Duration(seconds: 1),
                  initialChildSize:
                      .6, // The initial size of the sheet (0.2 means 20% of the screen)
                  minChildSize:
                      0.5, // Minimum size of the sheet (10% of the screen)
                  maxChildSize:
                      0.7, // Maximum size of the sheet (80% of the screen)
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                        child: Stack(children: [
                      Container(
                        width: double.infinity,
                        height: 75,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(.5),
                          ],
                        )),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 50),
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
                          HeadWidget(
                              hasCustomRoute ? customRoute : trip.driver!),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 1,
                            color: activeTheme.main_color.withOpacity(.2),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 120),
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
                                                  Icons.save,
                                                  color:
                                                      activeTheme.buttonColor,
                                                )))),
                                Container(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                activeTab = 'pickup';
                                              });
                                            },
                                            child: Text(
                                              lang.translate(
                                                  "Pickup Locations"),
                                              style: activeTab == 'pickup'
                                                  ? activeTheme.h5
                                                  : activeTheme.h6,
                                            )),
                                        const SizedBox(width: 50),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                activeTab = 'destination';
                                              });
                                            },
                                            child: Text(
                                              lang.translate("Destinations"),
                                              style: activeTab == 'destination'
                                                  ? activeTheme.h5
                                                  : activeTheme.h6,
                                            )),
                                      ]),
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                for (var i = 0;
                                    i < trip.pickup_locations!.length;
                                    i++)
                                  activeTab == 'pickup'
                                      ? Slideable(
                                          model: trip.pickup_locations![i],
                                          hasLeft: true,
                                          hasRight: trip.pickup_locations![i]
                                                      .status ==
                                                  'waiting'
                                              ? true
                                              : false,
                                          widget: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10, top: 10),
                                            child: TripUser(
                                                trip.pickup_locations![i]),
                                          ),
                                          finishCallback: finish,
                                        )
                                      : const Center(),
                                for (var i = 0;
                                    i < trip.destinations!.length;
                                    i++)
                                  activeTab == 'destination'
                                      ? Slideable(
                                          model: trip.destinations![i],
                                          hasLeft: true,
                                          hasRight:
                                              trip.destinations![i].status ==
                                                      'waiting'
                                                  ? true
                                                  : false,
                                          widget: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10, top: 10),
                                            child:
                                                TripUser(trip.destinations![i]),
                                          ),
                                          finishCallback: finishDestination,
                                        )
                                      : const Center()
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
    currentPicture = user.picture;

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
                foregroundImage: NetworkImage(
                    httpService.croppedImage(currentPicture, 200, 200)))),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: activeTheme.buttonBG,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              margin: const EdgeInsets.only(top: 15),
              child: Text("${user.contact_number}",
                  style: TextStyle(
                    color: activeTheme.buttonColor,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
        const Expanded(child: Center()),
        Column(
          children: [
            const SizedBox(height: 50),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTap: () {
                      launchCall(user.contact_number);
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 20, left: 20),
                      child: Icon(
                        Icons.call,
                        color: activeTheme.icon_color,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      launchWP(user.contact_number);
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 20, left: 20),
                      child: Icon(
                        Icons.maps_ugc_outlined,
                        color: activeTheme.icon_color,
                      ),
                    ),
                  ),
                ])
          ],
        )
      ],
    ));
  }

  bool showMap = true;

  Widget TripUser(pickupLocation) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentPicture = pickupLocation.student.picture;
          showMap = false;
        });

        Timer(const Duration(seconds: 1), () async {
          setState(() {
            customRoute = pickupLocation;
            hasCustomRoute = true;
            mapOrigin = LatLng(
                trip.vehicle!.last_latitude!, trip.vehicle!.last_longitude!);
            mapDestination =
                LatLng(pickupLocation.latitude!, pickupLocation.longitude!);
            showMap = true;
          });
        });
      },
      child: Row(children: [
        CircleAvatar(
          maxRadius: 40,
          backgroundColor: Colors.white,
          foregroundImage: NetworkImage(httpService.croppedImage(
              "${pickupLocation.location!.picture}", 200, 200)),
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 20,
          height: 2,
          child: Container(
              color: pickupLocation.status != 'waiting'
                  ? Colors.green
                  : Colors.red),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pickupLocation.student == null
                ? const Text("")
                : Text(
                    '${pickupLocation.student!.student_name}',
                    style: activeTheme.h5,
                  ),
            const SizedBox(
              height: 5,
            ),
            pickupLocation.status == 'waiting'
                ? Text(lang.translate('Waiting'),
                    style: const TextStyle(color: Colors.red))
                : Text(
                    '${pickupLocation.status}',
                    style: TextStyle(
                        fontSize: activeTheme.smallText.fontSize,
                        color: activeTheme.smallText.color),
                  )
          ],
        )
      ]),
    );
  }

  Widget MapWidget(location) {
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

    return MapWithRoute(
        origin: mapOrigin!,
        destination: mapDestination!,
        pickup_locations: trip.pickup_locations,
        trip: trip);
  }

  endTrip() async {
    final endTrip = await httpService.endTrip(widget.trip!.trip_id.toString());

    if (endTrip == 'true') {
      setState(() {
        showTripReportModal = true;
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
    if (trip_.trip_id != 0) {
      setState(() {
        trip = trip_;
        currentPicture = "${trip.driver!.picture}";
        mapDestination = LatLng(trip.route!.latitude!, trip.route!.longitude!);
        mapOrigin =
            LatLng(trip.vehicle!.last_latitude!, trip.vehicle!.last_longitude!);
        isActiveTrip = true;
        showLoader = false;
      });
    }
  }

  Map<MarkerId, Marker> loadMarkers() {
    for (var i = 0; i < trip.pickup_locations!.length; i++) {
      final a = trip.pickup_locations![i];
      addMarker(a.location!.address!, LatLng(a.latitude!, a.longitude!),
          a.location!.address);
    }
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
}

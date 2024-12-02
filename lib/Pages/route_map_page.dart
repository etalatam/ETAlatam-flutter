import 'package:eta_school_app/Models/PickupLocationModel.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/components/empty_data.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/components/slideable.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({super.key, required this.route_id});

  final int route_id;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  late GoogleMapController mapController;

  final LatLng _center = LatLng(30, 31);

  final HttpService httpService = HttpService();

  List<PickupLocationModel>? pickup_locations = [];

  RouteModel route = RouteModel(
      route_id: 0, route_name: '', pickup_locations: [], destinations: []);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  PickupLocationModel? activePickup;

  bool showUserModal = false;

  Location location = Location();
  LocationData? _locationData;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setCurrentLocation();
    zoomFirstLocation();
  }

  List<LatLng> polylineCoordinates = [];

  final Set<Polyline> _polylines = <Polyline>{};

  bool showLoader = true;
  String activeTab = 'pickup';
  String currentPicture = "/uploads/images/60x60.png";

  @override
  Widget build(BuildContext context) {
    return Material(
      child: route.pickup_locations.isEmpty
          ? showLoader
              ? Loader()
              : EmptyData(
                  title: lang.translate('No data here'),
                  text: lang.translate('No pickup locations at this route'),
                )
          : Scaffold(
              body: Stack(children: <Widget>[
                GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 17.0,
                    ),
                    markers: markers.values.toSet(),
                    polylines: _polylines),

                // showUserModal ? UserModal(activePickup, switchPopup, true) : Center(),

                DraggableScrollableSheet(
                  initialChildSize:
                      0.2, // The initial size of the sheet (0.2 means 20% of the screen)
                  minChildSize:
                      0.2, // Minimum size of the sheet (10% of the screen)
                  maxChildSize:
                      0.5, // Maximum size of the sheet (80% of the screen)
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
                          // HeadWidget(hasCustomRoute ? customRoute : trip.driver!),

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
                                      "${route.route_name}",
                                      style: activeTheme.h3,
                                    ),
                                    Text(
                                      "${route.description}",
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
                                    i < route.pickup_locations.length;
                                    i++)
                                  activeTab == 'pickup'
                                      ? Slideable(
                                          model: route.pickup_locations[i],
                                          hasLeft: true,
                                          hasRight: route.pickup_locations[i]
                                                      .status ==
                                                  'waiting'
                                              ? true
                                              : false,
                                          widget: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10, top: 10),
                                            child: RouteUser(
                                                route.pickup_locations[i]),
                                          ),
                                          finishCallback: null)
                                      : const Center(),
                                for (var i = 0;
                                    i < route.destinations!.length;
                                    i++)
                                  activeTab == 'destination'
                                      ? Slideable(
                                          model: route.destinations![i],
                                          hasRight: true,
                                          hasLeft:
                                              route.destinations![i].status ==
                                                      'waiting'
                                                  ? true
                                                  : false,
                                          widget: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10, top: 10),
                                            child: RouteUser(
                                                route.destinations![i]),
                                          ),
                                          finishCallback: null)
                                      : const Center()
                              ],
                            ),
                          )
                        ])),
                      )
                    ]));
                  },
                ),
              ]),
            ),
    );
  }

  Widget RouteUser(pickupLocation) {
    print(pickupLocation);
    return GestureDetector(
      onTap: () {
        setState(() {
          centerMap(
              LatLng(pickupLocation.latitude!, pickupLocation.longitude!));
        });
      },
      child: Row(children: [
        CircleAvatar(
          maxRadius: 40,
          backgroundColor: Colors.white,
          foregroundImage: NetworkImage(
              httpService.croppedImage("${pickupLocation.picture}", 200, 200)),
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
            pickupLocation.picture == null
                ? const Text("")
                : Text(
                    '${pickupLocation.student_name}',
                    style: activeTheme.h5,
                  ),
            const SizedBox(
              height: 5,
            ),
            // ,
            pickupLocation.distance != null
                ? Text('${pickupLocation.distance}  KM ',
                    style: const TextStyle(color: Colors.red))
                : const Center(),
          ],
        )
      ]),
    );
  }

  /// Load Trip through API
  loadRoute() async {
    RouteModel model_ = await httpService.getRouteInfo(widget.route_id);
    setState(() {
      route = model_;
      showLoader = false;
    });
  }

  getDistanceValue(location) {
    String dis =
        (location!.distance != null && double.parse(location!.distance) > 1)
            ? 'KM'
            : 'M';
    return location!.distance == null ? '' : (location!.distance! + ' ' + dis);
  }

  callbackPopup(index) {
    setState(() {
      activePickup = route.pickup_locations[index];
      showUserModal = true;
    });
  }

  ///
  /// Center the map to LatLng
  ///
  centerMap(LatLng position) {
    centerMapLocation(mapController, position);
  }

  reloadFuncs() async {
    _locationData = _locationData ?? await location.getLocation();

    sortLocations();

    for (var i = 0; i < route.pickup_locations.length; i++) {
      LatLng position_1 = LatLng(route.pickup_locations[i].latitude!,
          route.pickup_locations[i].longitude!);

      setDistance(position_1, i);

      await _add(i, position_1, route.pickup_locations[i].address!);
    }

    for (var i = 0; i < route.destinations!.length; i++) {
      LatLng position_2 = LatLng(
          route.destinations![i].latitude!, route.destinations![i].longitude!);

      setDestinationDistance(position_2, i);

      await _add(i + 50, position_2, route.destinations![i].address!);
    }

    _addPolyline();
  }

  setDistance(destination, i) {
    setState(() {
      route.pickup_locations[i].distance =
          getDistance(destination, i, _locationData);
    });
  }

  setDestinationDistance(destination, i) {
    setState(() {
      route.destinations![i].distance =
          getDistance(destination, i, _locationData);
    });
  }

  _add(i, LatLng center, String? title) async {
    _locationData = _locationData ?? await location.getLocation();

    Marker marker = await addMarker("marker{$i}", center, title);

    polylineCoordinates.add(LatLng(center.latitude, center.longitude));

    setState(() {
      markers[marker.markerId] = marker;
    });

    setDistance(center, i);
  }

  _addDestination(i, LatLng center, String? title) async {
    Marker marker = await addMarker("destination{$i}", center, title);
    setState(() {
      markers[marker.markerId] = marker;
    });

    setDistance(center, i);
  }

  void _addPolyline() {
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route1'),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 3,
      ),
    );
  }

  setCurrentLocation() async {
    _locationData = _locationData ?? await location.getLocation();

    return _locationData;
  }

  zoomFirstLocation() async {
    await reloadFuncs();
    centerMap(LatLng(route.pickup_locations[0].latitude!,
        route.pickup_locations[0].longitude!));
  }

  sortLocations() {
    setState(() {
      pickup_locations = getSortedLocations(pickup_locations, _locationData);
    });
  }

  setMapLocation(index) {
    centerMap(LatLng(route.pickup_locations[index].latitude!,
        route.pickup_locations[index].longitude!));
  }

  switchPopup(val) {
    setState(() {
      showUserModal = val;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRoute();
  }
}

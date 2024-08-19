import 'package:MediansSchoolDriver/Models/DestinationModel.dart';
import 'package:MediansSchoolDriver/Models/PickupLocationModel.dart';
import 'package:MediansSchoolDriver/components/button_text_icon.dart';
import 'package:location/location.dart' as Locations;
import 'package:flutter/material.dart';
import 'package:MediansSchoolDriver/components/loader.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';

CameraPosition centerPosition =
    CameraPosition(target: LatLng(0, 0), zoom: 17.0);

class LocationMapPage extends StatefulWidget {
  const LocationMapPage(
      {super.key,
      this.pickupLocation,
      this.destination,
      required this.center,
      required this.type});

  final DestinationModel? destination;
  final PickupLocationModel? pickupLocation;
  final LatLng center;
  final String type;

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  bool showLoader = true;

  LatLng center = LatLng(0, 0);

  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Locations.Location location = Locations.Location();

  String selectedDestination = '';
  String selectedPickup = '';

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      selectedPickup = widget.pickupLocation!.address == null
          ? ''
          : widget.pickupLocation!.address!;
      selectedDestination = widget.destination!.address == null
          ? ''
          : widget.destination!.address!;
    });
    // zoomFirstLocation();
  }

  setAddress(placemark) {
    setState(() {
      if (widget.type == 'pickupLocation') {
        selectedPickup =
            '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      } else {
        selectedDestination =
            '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      }
    });
  }

  Future<void> updateMarkerAddress(markerPosition) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      markerPosition.latitude,
      markerPosition.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      setAddress(placemark);
      // You can use the address details as needed
    }
  }

  List<Map> placesList = [];

  Future<bool> _onWillPop(BuildContext context) async {
    // Show a confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to go back?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User doesn't want to go back
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(true); // User confirmed, proceed with back navigation
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    // Return the user's confirmation choice
    return confirm;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              // appBar: AppBar(
              //     title: const Text('Route locations'), backgroundColor: Theme.of(context).primaryColor, titleTextStyle: TextStyle(color: Colors.white, fontSize: 18), ),
              body: PopScope(
              onPopInvoked: (old) => _onWillPop(context),
              child: Stack(children: <Widget>[
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: centerPosition,
                  markers: {
                    Marker(
                      markerId: MarkerId('marker_1'),
                      position: center,
                      icon: BitmapDescriptor.defaultMarker,
                      onTap: () {
                        updateMarkerAddress(center);
                      },
                    ),
                  },
                  onCameraMove: (position) {
                    cameraMoved(position);
                  },
                  // polylines: _polylines
                ),
                Container(
                    height: 400,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 50),
                    child: Column(
                      children: [
                        TextField(
                          // controller: _firstNameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              filled: true,
                              hintStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              hintText: lang.translate("Find address"),
                              fillColor:
                                  Theme.of(context).scaffoldBackgroundColor),

                          onChanged: (val) {
                            setState(() {
                              findAddress(val);
                              // firstName = val;
                            });
                          },
                        ),
                        placesList.isEmpty
                            ? const Center()
                            : Expanded(
                                child: Container(
                                  height: 300,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  child: ListView.builder(
                                    itemCount: placesList.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Text(
                                            placesList[index]['description'],
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ),
                                        onTap: () {
                                          setPlace(placesList[index]);
                                          placesList = [];
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ],
                    )),
                Positioned(
                  right: 52,
                  top: 62,
                  child: GestureDetector(
                    onTap: (() async {
                      final locationData = await location.getLocation();
                      centerMapLocation(
                          mapController,
                          LatLng(
                              locationData.latitude!, locationData.longitude!));
                    }),
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Theme.of(context).colorScheme.background,
                        )),
                  ),
                ),
                Positioned(
                    right: 50, left: 50, bottom: 50, child: onMapWidget()),
              ]),
            )),
    );
  }

  Widget onMapWidget() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: Theme.of(context).primaryColor.withOpacity(.1),
                child: Row(children: [
                  Expanded(
                    flex: 1,
                    child: CircleAvatar(
                      radius: 24.0,
                      backgroundImage: CachedNetworkImageProvider(
                          '${httpService.getImageUrl()}uploads/images/default_profile.jpg'),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      "Student pickup",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(children: [
                  Expanded(
                      flex: 1,
                      child: SvgPicture.asset("assets/svg/circles.svg")),
                  Expanded(
                    flex: 5,
                    child: Text(
                      selectedPickup.isEmpty ? "From : " : selectedPickup,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 10)
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(children: [
                  Expanded(
                      flex: 1,
                      child: SvgPicture.asset(
                        "assets/svg/circles_red.svg",
                      )),
                  Expanded(
                    flex: 5,
                    child: Text(
                      selectedDestination.isEmpty
                          ? "To : "
                          : selectedDestination,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 10)
                ]),
              ),
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: GestureDetector(
                      onTap: confirmCallback,
                      child: ButtonTextIcon(
                          lang.translate('Confirm'),
                          Icon(
                            Icons.check,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          )))),
            ],
          ),
        ));
  }

  /// Confirm data
  confirmCallback() {
    if (widget.type == 'pickupLocation') {
      PickupLocationModel newLocation = widget.pickupLocation!;
      newLocation.location_name = selectedPickup;
      newLocation.address = selectedPickup;
      newLocation.latitude = center.latitude;
      newLocation.longitude = center.longitude;

      Navigator.pop(context, newLocation);
    } else {
      DestinationModel newLocation = widget.destination!;
      newLocation.location_name = selectedDestination;
      newLocation.address = selectedDestination;
      newLocation.latitude = center.latitude;
      newLocation.longitude = center.longitude;

      Navigator.pop(context, newLocation);
    }

    // Pop back to Screen A with a result
  }

  /// Find address
  ///
  findAddress(val) async {
    if (val.length < 3) {
      return null;
    }

    placesList = [];
    List<dynamic> places = await httpService.getSuggestion(val);
    for (var place_ in places) {
      setState(() {
        placesList.add(place_);
      });
    }
  }

  /// Find address
  ///
  setPlace(place) async {
    final placeNew = await httpService.getPlace(place['place_id'].toString());

    setState(() {
      if (widget.type == 'destination') {
        selectedDestination = placeNew['formattedAddress'];
      } else {
        selectedPickup = placeNew['formattedAddress'];
      }

      center = LatLng(
          placeNew['location']['latitude'], placeNew['location']['longitude']);
      centerPosition = CameraPosition(target: center, zoom: 15.0);
      // centerMapLocation(mapController, center);
    });
  }

  addCurenMarker(String title) async {
    Marker marker = await addMarker('Pickup', center, title.toString());

    setState(() {
      markers[marker.markerId] = marker;
      showLoader = false;
    });
  }

  cameraMoved(CameraPosition position) {
    setState(() {
      center = LatLng(position.target.latitude, position.target.longitude);
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      center = widget.center;
      centerPosition = CameraPosition(target: center, zoom: 15.0);
    });
    addCurenMarker(lang.translate("Pickup Location"));
  }
}

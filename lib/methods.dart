import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:eta_school_app/controllers/helpers.dart';

void launchGoogleMaps(endLat, endLng) async {
  var currentPosition = await getCurrentLocation();
  var startLat = currentPosition.latitude;
  var startLng = currentPosition.longitude;
  final String googleMapsUrl =
      "https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving";
  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else {
    throw 'Could not launch Google Maps';
  }
}

locationService(title, subtitle) async {
  Location location = Location();

  location.enableBackgroundMode(enable: true);

  bool serviceEnabled;
  PermissionStatus permissionGranted;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  permissionGranted = await location.hasPermission();

  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
  location.changeSettings(interval: 1000);
  location.changeNotificationOptions(
      channelName: title,
      onTapBringToFront: true,
      subtitle: subtitle,
      iconName: "map",
      title: title);
}

Future<LocationData> getCurrentLocation() async {
  Location pos;

  pos = Location();

  return await pos.getLocation();
}

launchCall(number) async {
  final String url = 'tel:' + number;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch Google Maps';
  }
}

launchWP(number, {String code = '+2'}) async {
  final String url = "https://wa.me/" + number;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch Google Maps';
  }
}

double calculateDistance(LatLng loc1, LatLng loc2) {
  const double radius = 6371.0; // Radius of the Earth in kilometers

  double lat1 = _degreesToRadians(loc1.latitude);
  double lon1 = _degreesToRadians(loc1.longitude);
  double lat2 = _degreesToRadians(loc2.latitude);
  double lon2 = _degreesToRadians(loc2.longitude);

  double dLat = lat2 - lat1;
  double dLon = lon2 - lon1;

  double a =
      pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = radius * c;
  return distance;
}

double _degreesToRadians(double degrees) {
  return degrees * (pi / 180.0);
}

String loadImage(path) {
  return apiURL + path;
}

openNewPage(context, page) {
  Get.to(page);
}

PageRouteBuilder _createRoute(page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 50),
    transitionsBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      );
      // transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //   const begin = Offset(1.0, 0.0);
      //   const end = Offset(0.0, 0.0);
      //   const curve = Curves.easeInOut;
      //   var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      //   var offsetAnimation = animation.drive(tween);
      //   return SlideTransition(
      //     position: offsetAnimation,
      //     child: child,
      //   );
    },
  );
}

void showSuccessDialog(BuildContext context, title, text, Function? callback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              if (callback == null) {
                print("Using default action");
                Navigator.pop(context);
              } else {
                callback.call();
              }

              // You can add navigation or any other action here
            },
          ),
        ],
      );
    },
  );
}

// Go Back
back() {
  Get.back();
}

Future<Marker> addMarker(
    String markerIdVal, LatLng center, String? title) async {
  final MarkerId markerId = MarkerId(markerIdVal);

  // creating a new MARKER
  final Marker marker = Marker(
    markerId: markerId,
    position: center,
    icon: await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, 'assets/markers.png'),
    infoWindow:
        InfoWindow(title: title!.isEmpty ? markerIdVal : title, snippet: '*'),
    onTap: () {
      launchGoogleMaps(center.latitude, center.longitude);
    },
  );

  return marker;
}

carMarker(customIcon, LatLng center) async {
  final MarkerId markerId = MarkerId('car');

  // creating a new MARKER
  final Marker marker = Marker(
    markerId: markerId,
    position: center,
    icon: await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/car.png"),
    infoWindow: InfoWindow(title: 'Home maker', snippet: '*'),
    onTap: () {},
  );

  return marker;
}

destinationMarker(LatLng center) async {
  final MarkerId markerId = MarkerId('destination');

  // creating a new MARKER
  final Marker marker = Marker(
    markerId: markerId,
    position: center,
    icon: await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/school.png"),
    infoWindow: InfoWindow(title: 'Destination maker', snippet: '*'),
    onTap: () {
      launchGoogleMaps(center.latitude, center.longitude);
    },
  );

  return marker;
}

centerMapLocation(GoogleMapController mapController, LatLng position) {
  mapController.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: position,
        zoom: 14.5,
      ),
    ),
  );
}

getDistance(destination, i, locationData) {
  // Example usage
  double distance = calculateDistance(
      LatLng(locationData!.latitude!, locationData!.longitude!),
      LatLng(destination.latitude, destination.longitude));
  return distance.toStringAsFixed(2);
}

getSortedLocations(pickupLocations, locationData) {
  pickupLocations!.sort((a, b) => calculateDistance(
          LatLng(locationData!.latitude!, locationData!.longitude!),
          LatLng(a.latitude!, a.longitude!))
      .compareTo(calculateDistance(
          LatLng(locationData!.latitude!, locationData!.longitude!),
          LatLng(b.latitude!, b.longitude!))));

  return pickupLocations;
}

getSortedPolygons(polylineCoordinates, locationData) {
  polylineCoordinates.sort((a, b) => calculateDistance(
          LatLng(locationData!.latitude!, locationData!.longitude!),
          LatLng(a.latitude!, a.longitude!))
      .compareTo(calculateDistance(
          LatLng(locationData!.latitude!, locationData!.longitude!),
          LatLng(b.latitude!, b.longitude!))));

  return polylineCoordinates;
}

currentLang() {
  return localeController.selectedLocale.value;
}

bool isRTL() {
  return localeController.selectedLocale.value.toString().toLowerCase() == 'ar'
      ? true
      : false;
}

bool clickListenerAdded = false;


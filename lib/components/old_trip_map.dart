import 'dart:async';
import 'dart:convert';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class OldTripMap extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;
  final List<TripPickupLocation>? pickup_locations;
  final TripModel trip;

  const OldTripMap(
      {super.key,
      required this.origin,
      required this.destination,
      required this.trip,
      this.pickup_locations});

  @override
  _OldTripMapState createState() => _OldTripMapState();
}

class _OldTripMapState extends State<OldTripMap> {
  late GoogleMapController _mapController;
  late List<LatLng> _routeCoordinates = [];

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  LatLng? mapDestination;
  LatLng? mapOrigin;

  @override
  Widget build(BuildContext context) {
    return mapOrigin == null
        ? const Center()
        : GoogleMap(
            initialCameraPosition:
                CameraPosition(target: mapOrigin!, zoom: 15.0),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
                setMarkers();
                _setMapBounds();
              });
            },
            markers: markers.values.toSet(),
            polylines: {
              Polyline(
                polylineId: PolylineId('route'),
                points: _routeCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            },
          );
  }

  void _setMapBounds() {
    Timer(const Duration(seconds: 1), () {
      if (_routeCoordinates.isNotEmpty) {
        LatLngBounds bounds = _getBounds(_routeCoordinates);
        _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    });
  }

  LatLngBounds _getBounds(List<LatLng> routeCoordinates) {
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = -double.infinity;
    double maxLng = -double.infinity;

    for (LatLng point in routeCoordinates) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  reloadTrip() async {
    /// Load the trip
    TripModel? trip_ = await httpService.getTrip(widget.trip.trip_id);

    setState(() {
      mapDestination = LatLng(trip_.route!.latitude!, trip_.route!.longitude!);
      mapOrigin =
          LatLng(trip_.vehicle!.last_latitude!, trip_.vehicle!.last_longitude!);
    });

    /// Calculate zoom position
    _setMapBounds();
  }

  Future<void> fetchRoute() async {
    await reloadTrip();

    const String baseUrl =
        'https://maps.googleapis.com/maps/api/directions/json';
    final String url =
        '$baseUrl?origin=${mapOrigin!.latitude},${mapOrigin!.longitude}&destination=${mapDestination!.latitude},${mapDestination!.longitude}&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<LatLng> points = _decodePoly(
          encodedString: decoded['routes'][0]['overview_polyline']['points']);

      Marker mark = await carMarker('car', mapOrigin!);
      Marker destination = await destinationMarker(mapDestination!);
      setState(() {
        markers[mark.markerId] = mark;
        markers[destination.markerId] = destination;

        _routeCoordinates = points;
      });
    } else {
      throw Exception('Failed to fetch route');
    }
  }

  List<LatLng> _decodePoly({required String encodedString}) {
    List<LatLng> polylinePoints = [];
    int index = 0, len = encodedString.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encodedString.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encodedString.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;

      LatLng position = LatLng(latitude, longitude);
      polylinePoints.add(position);
    }
    return polylinePoints;
  }

  setMarkers() async {
    for (var i = 0; i < widget.pickup_locations!.length; i++) {
      Marker origMarker = await addMarker(
          "Pickup$i",
          LatLng(widget.pickup_locations![i].latitude!,
              widget.pickup_locations![i].longitude!),
          "Pickup$i");
      setState(() {
        markers[origMarker.markerId] = origMarker;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    fetchRoute();
  }
}

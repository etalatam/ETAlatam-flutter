import 'dart:math';

import 'package:eta_school_app/shared/location/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MapWiew extends StatefulWidget {
  // Indica si el mapa debe mostrar la ubicación
  // y actualizar el mapa
  bool navigationMode;

  // callback para iniclizar elementos sobre el mapa
  Future<void> Function(MapboxMap) onMapReady;
  Future<void> Function(MapboxMap) onStyleLoadedListener;

  MapWiew(
      {required this.navigationMode,
      required this.onMapReady,
      required this.onStyleLoadedListener}) {
    print('[MapWiew.navigationMode] $navigationMode');
  }

  @override
  State createState() => MapWiewState();
}

class MapWiewState extends State<MapWiew> {
  MapboxMap? mapboxMap;

  LocationService? locationService;

  bool _firstLocationUpdate = true;
  
  double _bearing = 0;
  
  _onMapCreated(MapboxMap mapboxMap) async {
    print('[MapView._onMapCreated]');

    this.mapboxMap = mapboxMap;

    this
        .mapboxMap
        ?.logo
        .updateSettings(LogoSettings(marginRight: 3000, marginTop: 3000));
    
    this.mapboxMap?.attribution.updateSettings(AttributionSettings(
        marginRight: 3000, 
        marginTop: 2500, 
        clickable: true));

    if(widget.navigationMode){
      print('[MapView._onMapCreated.navigationMode] ${widget.navigationMode}');
      // const double puckScale = 10.0;

      this.mapboxMap?.location.updateSettings(LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          showAccuracyRing: true,
          puckBearingEnabled: true,
          // locationPuck: LocationPuck(
          //       locationPuck3D: LocationPuck3D(
          //           modelUri: "assethttps://raw.githubusercontent.com/CesiumGS/cesium/refs/heads/master/Apps/SampleData/models/BoxInstanced/BoxInstanced.gltf",
          //           modelScale: [puckScale, puckScale, puckScale]))
        ));
      await locationService?.init();
      // listenToCompass();
    }

    this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(
        enabled: true, 
        position: OrnamentPosition.BOTTOM_LEFT
    ));
    this.mapboxMap?.compass.updateSettings(CompassSettings(
        enabled: true, 
        position: OrnamentPosition.TOP_LEFT,
        marginTop: 50,
        clickable: true));

    await widget.onMapReady(mapboxMap);
  }

  void _onStyleLoadedListener(StyleLoadedEventData styleLoadedEventData) async {
    await widget.onStyleLoadedListener(mapboxMap!);
  }

  @override
  Widget build(BuildContext context) {
    print('[MapView.build]');
    return Scaffold(body:
        Consumer<LocationService>(builder: (context, locationService, child) {
      final locationData = locationService.locationData;

      print('[MapView.Consumer.LocationService.locationData] $locationData');
      print(
          'MapView.Consumer.LocationService.widget.navigationMode ${widget.navigationMode}');
      if (locationData != null && mapboxMap != null && widget.navigationMode) {
        if (_firstLocationUpdate) {
          print('[MapView.build._firstLocationUpdate] $_firstLocationUpdate');
          mapboxMap?.setCamera(CameraOptions(
            zoom: 18,
            pitch: widget.navigationMode ? 80 : 0,
            center: Point(
                coordinates: Position(
                    locationData['longitude'], locationData['latitude'])),
          ));
          _firstLocationUpdate = false;
        } else {
          mapboxMap?.setCamera(CameraOptions(
            // bearing: widget.navigationMode? _bearing : 0,
            center: Point(
                coordinates: Position(
                    locationData['longitude'], locationData['latitude'])),
          ));
        }
      }

      return MapWidget(
          styleUri: MapboxStyles.MAPBOX_STREETS,
          onMapCreated: _onMapCreated,
          onStyleLoadedListener: _onStyleLoadedListener,
          cameraOptions: CameraOptions(
              center: Point(
                  coordinates: Position(-79.50451720694494, 9.055044879215595)),
              zoom: 5.0));
    }));
  }

  @override
  void initState() {
    print('[MapView.initState]');
    super.initState();
    locationService = Provider.of<LocationService>(context, listen: false);
  }

  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final lat1Rad = radians(lat1);
    final lon1Rad = radians(lon1);
    final lat2Rad = radians(lat2);
    final lon2Rad = radians(lon2);

    final y = sin(lon2Rad - lon1Rad) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(lon2Rad - lon1Rad);
    final bearingRad = atan2(y, x);

    // Convierte el rumbo a grados y normaliza a un valor entre 0 y 360
    final bearingDeg = (degrees(bearingRad) + 360) % 360;

    return bearingDeg;
  }

  double radians(double degrees) {
    return degrees * pi / 180;
  }

  double degrees(double radians) {
    return radians * 180 / pi;
  }

  void listenToCompass() {
    // Usa magnetometerEventStream() en lugar de magnetometerEvents
    magnetometerEventStream().listen((MagnetometerEvent event) {
      // Calcula el bearing usando los datos del magnetómetro
      setState(() {
        _bearing = atan2(event.y, event.x);
        print("bearing $_bearing");
      });

    });
  }  
}

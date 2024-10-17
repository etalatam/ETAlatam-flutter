import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../shared/location/location_service.dart';

class MapWiew extends StatefulWidget {
  // Indica si el mapa debe mostrar la ubicación
  // y actualizar el mapa
  final bool navigationMode;

  // callback para iniclizar elementos sobre el mapa
  Future<void> Function(MapboxMap) onMapReady;

  MapWiew({this.navigationMode = false, required this.onMapReady}){
    print('[MapWiew.navigationMode] $navigationMode');
  }

  @override
  State createState() => MapWiewState();
}

class MapWiewState extends State<MapWiew> {
  MapboxMap? mapboxMap;

  LocationService? locationService;

  bool _firstLocationUpdate = true;

  _onMapCreated(MapboxMap mapboxMap) async {
    print('[MapView._onMapCreated]');

    this.mapboxMap = mapboxMap;

    this
        .mapboxMap
        ?.logo
        .updateSettings(LogoSettings(marginRight: 3000, marginTop: 3000));
    this.mapboxMap?.attribution.updateSettings(AttributionSettings(
        marginRight: 3000, marginTop: 3000, clickable: false));

    this.mapboxMap?.location.updateSettings(LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          showAccuracyRing: true,
          puckBearingEnabled: true,
        ));

    // this.mapboxMap?.on UserLocationUpdated

    // this.mapboxMap?.setCamera(CameraOptions(
    //     center: Point(
    //         coordinates: Position(
    //       locationService?.locationData?['longitude'],
    //       locationService?.locationData?['latitude'],
    //     )),
    //     padding: MbxEdgeInsets(top: 1, left: 2, bottom: 3, right: 4),
    //     anchor: ScreenCoordinate(x: 1, y: 1),
    //     zoom: 5));
    // MbxEdgeInsets(top: 1, left: 2, bottom: 3, right: 4),
    this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(
        enabled: true, position: OrnamentPosition.BOTTOM_LEFT));
    this.mapboxMap?.compass.updateSettings(CompassSettings(
        enabled: true, position: OrnamentPosition.BOTTOM_RIGHT));

    await widget.onMapReady(mapboxMap);
  }

  @override
  Widget build(BuildContext context) {
    print('[MapView.build]');
    return Scaffold(body:
        Consumer<LocationService>(builder: (context, locationService, child) {
      final locationData = locationService.locationData;
      print('[MapView.Consumer.LocationService] $locationData');
      print('MapView.Consumer.LocationService.widget.navigationMode ${widget.navigationMode}');
      if (locationData != null && mapboxMap != null && widget.navigationMode) {
        if (_firstLocationUpdate) {
          print('[MapView.build._firstLocationUpdate] $_firstLocationUpdate');
          mapboxMap?.setCamera(CameraOptions(
            zoom: 18,
            pitch: 80,
            center: Point(
                coordinates: Position(
                    locationData?['longitude'], locationData?['latitude'])),
          ));
          _firstLocationUpdate = false;
        } else {
          mapboxMap?.setCamera(CameraOptions(
            center: Point(
                coordinates: Position(
                    locationData?['longitude'], locationData?['latitude'])),
          ));
        }
      }

      return MapWidget(
          styleUri: MapboxStyles.MAPBOX_STREETS,
          onMapCreated: _onMapCreated,
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
}

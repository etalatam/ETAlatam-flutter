
import 'package:eta_school_app/shared/location/location_service.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapWiew extends StatefulWidget {
  // Indica si el mapa debe mostrar la ubicación
  // y actualizar el mapa
  final bool navigationMode;

  // callback para iniclizar elementos sobre el mapa
  Future<void> Function(MapboxMap) onMapReady;
  Future<void> Function(MapboxMap) onStyleLoadedListener;

  MapWiew({
    this.navigationMode = false, 
    required this.onMapReady, 
    required this.onStyleLoadedListener}){
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

    this.mapboxMap?.logo
        .updateSettings(LogoSettings(marginRight: 3000, marginTop: 3000));
    this.mapboxMap?.attribution.updateSettings(AttributionSettings(
        marginRight: 3000, marginTop: 3000, clickable: false));

    this.mapboxMap?.location.updateSettings(LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          showAccuracyRing: true,
          puckBearingEnabled: true,
        ));

    this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(
        enabled: true, position: OrnamentPosition.BOTTOM_LEFT));
    this.mapboxMap?.compass.updateSettings(CompassSettings(
        enabled: true, position: OrnamentPosition.BOTTOM_RIGHT));

    if(widget.navigationMode){
      await locationService?.init();
    }
    await widget.onMapReady(mapboxMap);
  }
  
  void _onStyleLoadedListener(StyleLoadedEventData styleLoadedEventData) async{
    await widget.onStyleLoadedListener(mapboxMap!);
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
                    locationData['longitude'], locationData['latitude'])),
          ));
          _firstLocationUpdate = false;
        } else {
          mapboxMap?.setCamera(CameraOptions(
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
}
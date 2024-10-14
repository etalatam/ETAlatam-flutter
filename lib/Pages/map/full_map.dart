import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class FullMap extends StatefulWidget {
  const FullMap();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMap? mapboxMap;

  _onMapCreated(MapboxMap mapboxMap) {
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

    this.mapboxMap?.setCamera(CameraOptions(
        padding: MbxEdgeInsets(top: 1, left: 2, bottom: 3, right: 4),
        anchor: ScreenCoordinate(x: 1, y: 1),
        zoom: 14));
    // MbxEdgeInsets(top: 1, left: 2, bottom: 3, right: 4),
    this.mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(
        enabled: true, position: OrnamentPosition.BOTTOM_LEFT));
    this.mapboxMap?.compass.updateSettings(CompassSettings(
        enabled: true, position: OrnamentPosition.BOTTOM_RIGHT));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MapWidget(onMapCreated: _onMapCreated));
  }
}

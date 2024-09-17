import 'dart:typed_data';

import 'package:MediansSchoolDriver/components/bottom_menu.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:MediansSchoolDriver/shared/location/provider/location_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// ignore: constant_identifier_names
const TAG = "MapView";

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapBoxWidgetState();
}

class _MapBoxWidgetState extends ConsumerState<MapView> {
  MapboxMap? mapboxMap; // instancia del mapa de mapbox
  PointAnnotationManager?
      pointAnnotationManager; // instancia del manejador de la anotación del mapa (sin uso)
  PointAnnotation? pointAnnotation; // instancia del punto  en el mapa (sin uso)

  /// nombre de la key que almacena la data del mapa en la db de isar
  Position markerLocation = Position(
    -66,
    10.0,
  ); //  datos de la posición actual del marcador// subscripcion de la conectividad del gps

  double lat = 0.0; // coordenada de la camara
  double lon = 0.0; // coordenada de la camara
  bool isCreated = false; // bandera para saber si crea el marcador o actualiza

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //variable por defecto del mapa
    Map<String, dynamic> mapData = {
      "zoom": 5.0,
      "lat": 10,
      "lng": -66,
      "pitch": 50.0,
      "bearing": 0.0,
    };

    return _stackMap(mapData);
    // return MapView();
  }

  Stack _stackMap(Map<String, dynamic> mapData) {
    const func = "_stackMap";
    try {
      // MapboxOptions.setAccessToken(Environment.mapboxToken);

      return Stack(
        children: [
          MapWidget(
            cameraOptions: _mapCameraOptions(mapData),
            onMapCreated: _mapCreated,
          ),
          _positionedCenterBtn(),
          Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: BottomMenu('home', openNewPage))
        ],
      );
    } catch (e) {
      print("$TAG.$func  - ocurrio un error cargando el mapa: $e");
      return const Stack(
        children: [Text("Ocurrió un error cargando el mapa")],
      );
    }
  }

  CameraOptions _mapCameraOptions(Map<String, dynamic> mapData) {
    return CameraOptions(
      zoom: mapData["zoom"],
      pitch: mapData["pitch"],
      bearing: mapData["bearing"],
      center: Point(coordinates: Position(mapData['lng'], mapData['lat'])),
    );
  }

  Positioned _positionedCenterBtn() {
    return Positioned(
        top: 40,
        right: 16,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: _centerMarkerButton(),
        ));
  }

  /// Centrar el mapa al marcador
  IconButton _centerMarkerButton() {
    return IconButton(
        onPressed: () async {
          try {
            centerMarker(
                coordinates: markerLocation, delayed: 0, duration: 500);
          } catch (e) {
            print(
              "map.onpressed->CenterMarker.catch error: $e",
            );
          }
        },
        icon: Icon(
          Icons.location_on,
          color: context.theme.primaryColor,
        ));
  }

  //* seguimiento del usuario
  void tracking() async {
    const func = "tracking";
    await ref.read(locationNotifierProvider.notifier).init();
    final locationState = ref.watch(locationNotifierProvider.notifier);
    locationState.addListener((allPosition) {
      final position = allPosition.location;
      print("$TAG.$func - listen position: $position");
      if (position == null) return;
      markerLocation =
          Position((position.longitude as num), (position.latitude as num));
      final point1 = Point(coordinates: markerLocation);
      if (isCreated == false) {
        isCreated = true;
        addMarker(point1);
        return;
      }
      updateAnotation(point: point1);
    });
  }

  // funcion que se inicia al ser creado el mapa
  void _mapCreated(MapboxMap controller) async {
    const func = "_mapCreated";
    mapboxMap = controller;
    try {
      _initMapConfiguration(controller);
      final locationNotifier = ref.read(locationNotifierProvider.notifier);
      locationNotifier.startTracking();
      tracking();
    } catch (e) {
      print(
        "$TAG.$func error: $e",
      );
    }
  }

  /// Configuracion inicial del mapa
  void _initMapConfiguration(MapboxMap controller) {
    const func = "_initMapConfiguration";
    print("$TAG.$func - init");
    mapboxMap?.setBounds(CameraBoundsOptions(
        bounds: CoordinateBounds(
            southwest: Point(
                coordinates: Position(
              10.0,
              -66.0,
            )),
            northeast: Point(
                coordinates: Position(
              10.001,
              -66.001,
            )),
            infiniteBounds: true),
        maxZoom: 24,
        minZoom: 3,
        maxPitch: 10,
        minPitch: 0));

    controller.logo
        .updateSettings(LogoSettings(marginRight: 3000, marginTop: 3000));
    controller.attribution.updateSettings(AttributionSettings(
        marginRight: 3000, marginTop: 3000, clickable: false));
    controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    controller.compass.updateSettings(CompassSettings(
        enabled: false,
        clickable: false,
        visibility: false,
        position: OrnamentPosition.BOTTOM_LEFT,
        opacity: 0.0));
  }

  /// agrega un marcador
  void addMarker(Point point) async {
    const func = "addMarker";
    print(
      "$TAG.$func - init",
    );

    //* si la annotacion (marcador) existe se elimina
    if (pointAnnotation != null) {
      await pointAnnotationManager?.delete(pointAnnotation!);
    }

    //* se crea el marcador e inicia el seguimiento
    mapboxMap?.annotations.createPointAnnotationManager().then((value) async {
      pointAnnotationManager = value;
      createOneAnnotation(point: point);
    });

    centerMarker(coordinates: point.coordinates);
  }

  //* centra el mapa a la ubicacion del marcador
  void centerMarker(
      {required Position coordinates,
      int? delayed = 500,
      int? duration = 3500}) async {
    print(
      "map.centerMarker",
    );
    mapboxMap?.flyTo(
        CameraOptions(
            center: Point(coordinates: coordinates),
            anchor: ScreenCoordinate(x: lon, y: lat),
            zoom: 18,
            pitch: 50),
        MapAnimationOptions(duration: duration, startDelay: delayed));
  }

  //* crea una anotación de la posición actual en el mapa
  void createOneAnnotation({required Point point}) async {
    final ByteData bytes = await rootBundle.load('assets/marker.png');
    final Uint8List list = bytes.buffer.asUint8List();
    pointAnnotationManager
        ?.create(PointAnnotationOptions(
            geometry: point,
            textOffset: [0.0, -3.0],
            // iconSize: 2,
            iconOffset: [0.0, -5.0],
            symbolSortKey: 10,
            image: list))
        .then((value) => pointAnnotation = value);
  }

  /// actualiza una anotacion
  void updateAnotation({required Point point}) {
    const func = "updateAnotation";
    try {
      pointAnnotation?.geometry = point;
      pointAnnotationManager?.update(pointAnnotation!);
    } catch (e) {
      print(
        "$TAG.$func - ocurrió un error actualizando el punto: $e",
      );
    }
  }
}

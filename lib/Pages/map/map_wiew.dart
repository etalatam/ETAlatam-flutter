import 'dart:async';
import 'dart:math';

import 'package:eta_school_app/shared/location/location_service.dart';
import 'package:flutter/material.dart';
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

  bool _firstLocationUpdate = true;
  
  double _bearing = 0;
  
  bool _autoFollow = true;
  DateTime? _lastUserInteraction;
  Timer? _autoFollowTimer;
  
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
          //           modelUri: "https://raw.githubusercontent.com/CesiumGS/cesium/refs/heads/master/Apps/SampleData/models/BoxInstanced/BoxInstanced.gltf",
          //           modelScale: [puckScale, puckScale, puckScale]))
        ));
      await LocationService.instance.init();
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
    
    // La detección de movimiento ahora se hace con Listener en lugar de un timer

    await widget.onMapReady(mapboxMap);
  }

  void _onStyleLoadedListener(StyleLoadedEventData styleLoadedEventData) async {
    await widget.onStyleLoadedListener(mapboxMap!);
  }

  @override
  Widget build(BuildContext context) {
    print('[MapView.build]');
    return Scaffold(
      body: Consumer<LocationService>(
        builder: (context, locationService, child) {
          print('[MapView.builder] Current service instance: ${locationService.instanceId}');
          print('[MapView.Consumer] locationData: ${locationService.locationData}');
          
          if (locationService.locationData != null && 
                mapboxMap != null && 
                widget.navigationMode) {
              if (_firstLocationUpdate) {
                print('[MapView.build._firstLocationUpdate] $_firstLocationUpdate');
                mapboxMap?.setCamera(CameraOptions(
                  zoom: 18,
                  pitch: widget.navigationMode ? 80 : 0,
                  center: Point(
                    coordinates: Position(
                      locationService.locationData!['longitude'], 
                      locationService.locationData!['latitude']
                    ),
                  ),
                ));
                _firstLocationUpdate = false;
              } else if (_autoFollow) {
                // Solo actualizar la cámara si el auto-seguimiento está activado
                mapboxMap?.flyTo(
                  CameraOptions(
                    center: Point(
                      coordinates: Position(
                        locationService.locationData!['longitude'], 
                        locationService.locationData!['latitude']
                      ),
                    ),
                  ),
                  MapAnimationOptions(duration: 1000, startDelay: 0)
                );
              }
            }

          return Stack(
            children: [
              Listener(
                onPointerDown: (event) {
                  // Usuario tocó la pantalla - desactivar auto-follow inmediatamente
                  if (_autoFollow && widget.navigationMode) {
                    setState(() {
                      _autoFollow = false;
                      _lastUserInteraction = DateTime.now();
                    });
                    print("[MapView] User touch detected - auto-follow disabled");
                    
                    // Cancelar timer anterior si existe
                    _autoFollowTimer?.cancel();
                    
                    // Reactivar después de 30 segundos
                    _autoFollowTimer = Timer(Duration(seconds: 30), () {
                      if (mounted) {
                        setState(() {
                          _autoFollow = true;
                        });
                        print("[MapView] Auto-follow re-enabled after 30 seconds");
                      }
                    });
                  }
                },
                child: MapWidget(
                  styleUri: MapboxStyles.MAPBOX_STREETS,
                  onMapCreated: _onMapCreated,
                  onStyleLoadedListener: _onStyleLoadedListener,
                  cameraOptions: CameraOptions(
                    center: Point(
                      coordinates: Position(-79.50451720694494, 9.055044879215595)
                    ),
                    zoom: 5.0
                  ),
                ),
              ),
              // Botón de control de seguimiento automático
              if (widget.navigationMode)
                Positioned(
                  top: 160,  // Posición donde debe estar (tercer botón)
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _autoFollow = !_autoFollow;
                        if (_autoFollow) {
                          _lastUserInteraction = null;
                          _autoFollowTimer?.cancel();
                        }
                      });
                      print('[MapView] Auto-follow toggled: $_autoFollow');
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _autoFollow 
                            ? Colors.blue.withOpacity(0.85)
                            : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _autoFollow ? Icons.gps_fixed : Icons.gps_not_fixed,
                        color: _autoFollow ? Colors.white : Colors.black,
                        size: 26,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    print('[MapView.initState]');
    super.initState();
  }
  
  @override
  void dispose() {
    _autoFollowTimer?.cancel();
    super.dispose();
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

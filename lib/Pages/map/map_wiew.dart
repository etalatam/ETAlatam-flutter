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
  
  // Indica si debe mostrar el puck/dock de posición (solo para conductores)
  bool showLocationPuck;
  
  // Indica si el botón centrar debe centrar en la posición propia o en otros marcadores
  // true = centra en ubicación propia, false = centra en marcadores del mapa
  bool centerOnSelf;
  
  // Indica si debe mostrar el botón de ajuste automático (solo viajes activos)
  bool showAutoFollowButton;
  
  // Callback opcional para centrar en elementos externos (como el bus)
  void Function()? onCenterRequest;

  // callback para iniclizar elementos sobre el mapa
  Future<void> Function(MapboxMap) onMapReady;
  Future<void> Function(MapboxMap) onStyleLoadedListener;

  MapWiew(
      {required this.navigationMode,
      this.showLocationPuck = false,
      this.centerOnSelf = true,
      this.showAutoFollowButton = false, // Por defecto no mostrar (para viajes históricos)
      this.onCenterRequest,
      required this.onMapReady,
      required this.onStyleLoadedListener}) {
    print('[MapWiew] navigationMode: $navigationMode, showLocationPuck: $showLocationPuck, centerOnSelf: $centerOnSelf, showAutoFollowButton: $showAutoFollowButton');
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
      
      // Configurar LocationService siempre que navigationMode esté activo
      try {
        print('[MapView._onMapCreated] Initializing LocationService...');
        await LocationService.instance.init();
        
        // Si debe mostrar el puck (conductor con viaje activo), también iniciar el servicio
        if(widget.showLocationPuck) {
          print('[MapView._onMapCreated] Starting LocationService for driver...');
          await LocationService.instance.startLocationService(calculateDistance: true);
        }
      } catch (e) {
        print('[MapView._onMapCreated] Error initializing LocationService: $e');
      }
      
      // Solo mostrar el dock/puck de posición para conductores
      if(widget.showLocationPuck) {
        print('[MapView._onMapCreated.showLocationPuck] SHOWING location puck - showLocationPuck: ${widget.showLocationPuck}');
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
      } else {
        print('[MapView._onMapCreated.showLocationPuck] NOT showing location puck - showLocationPuck: ${widget.showLocationPuck}');
      }
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
    print('[MapView._onStyleLoadedListener] Style loaded');
    
    // Configurar el componente de ubicación después de que el estilo se haya cargado
    if(widget.navigationMode && widget.showLocationPuck && mapboxMap != null) {
      print('[MapView._onStyleLoadedListener] Configuring location component after style load');
      try {
        await mapboxMap!.location.updateSettings(LocationComponentSettings(
            enabled: true,
            pulsingEnabled: true,
            showAccuracyRing: true,
            puckBearingEnabled: true
        ));
        print('[MapView._onStyleLoadedListener] Location component configured successfully');
      } catch (e) {
        print('[MapView._onStyleLoadedListener] Error configuring location component: $e');
      }
    }
    
    await widget.onStyleLoadedListener(mapboxMap!);
  }

  @override
  Widget build(BuildContext context) {
    print('[MapView.build] navigationMode: ${widget.navigationMode}, showLocationPuck: ${widget.showLocationPuck}, centerOnSelf: ${widget.centerOnSelf}');
    
    // Obtener LocationService directamente del singleton en lugar del Provider
    final locationService = LocationService.instance;
    print('[MapView.build] Using singleton instance: ${locationService.instanceId}');
    print('[MapView.build] locationData: ${locationService.locationData}');
    
    return Scaffold(
      body: Consumer<LocationService>(
        builder: (context, providerLocationService, child) {
          // Usar el singleton directamente, pero mantener el Consumer para las actualizaciones
          print('[MapView.Consumer] Provider instance: ${providerLocationService.instanceId}');
          print('[MapView.Consumer] Provider locationData: ${providerLocationService.locationData}');
          print('[MapView.Consumer] Singleton locationData: ${locationService.locationData}');
          print('[MapView.Consumer] Has mapboxMap: ${mapboxMap != null}');
          
          // Usar el singleton directamente en lugar del provider
          final singletonLocationData = LocationService.instance.locationData;
          
          // Solo actualizar la cámara con la posición propia si centerOnSelf es true
          if (singletonLocationData != null && 
                mapboxMap != null && 
                widget.navigationMode && 
                widget.centerOnSelf) {
              
              // Actualizar la posición del componente de ubicación
              if (widget.showLocationPuck) {
                try {
                  final lat = singletonLocationData['latitude'];
                  final lng = singletonLocationData['longitude'];
                  print('[MapView] Updating location puck position: lat=$lat, lng=$lng');
                  
                  // Forzar actualización del componente de ubicación
                  mapboxMap?.location.updateSettings(LocationComponentSettings(
                    enabled: true,
                    pulsingEnabled: true,
                    showAccuracyRing: true,
                    puckBearingEnabled: true
                  ));
                } catch (e) {
                  print('[MapView] Error updating location puck: $e');
                }
              }
              
              if (_firstLocationUpdate) {
                print('[MapView.build._firstLocationUpdate] $_firstLocationUpdate');
                mapboxMap?.setCamera(CameraOptions(
                  zoom: 18,
                  pitch: widget.navigationMode ? 80 : 0,
                  center: Point(
                    coordinates: Position(
                      singletonLocationData['longitude'], 
                      singletonLocationData['latitude']
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
                        singletonLocationData['longitude'], 
                        singletonLocationData['latitude']
                      ),
                    ),
                  ),
                  MapAnimationOptions(duration: 1000, startDelay: 0)
                );
              }
            }
          
          // Si no centra en sí mismo y auto-follow está activo, usar callback
          if (!widget.centerOnSelf && _autoFollow && widget.onCenterRequest != null) {
            // El callback debería manejar el centrado en elementos externos
            // Esto se ejecuta continuamente mientras auto-follow esté activo
            // El padre (student_page o trip_page) debería manejar si necesita actualizar o no
          }

          return Stack(
            children: [
              Listener(
                onPointerDown: (event) {
                  // Usuario tocó la pantalla - desactivar auto-follow inmediatamente
                  // Debe funcionar tanto para navegación propia como para centrado en elementos externos
                  if (_autoFollow) {
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
                        
                        // Si se reactiva automáticamente y no centra en sí mismo, centrar en elemento externo
                        if (!widget.centerOnSelf && widget.onCenterRequest != null) {
                          widget.onCenterRequest!();
                        }
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
              // Solo se muestra si showAutoFollowButton es true (viajes activos)
              Builder(builder: (context) {
                final shouldShow = widget.showAutoFollowButton && (widget.navigationMode || widget.onCenterRequest != null);
                print('[MapView.AutoFollowButton] showAutoFollowButton: ${widget.showAutoFollowButton}, navigationMode: ${widget.navigationMode}, onCenterRequest: ${widget.onCenterRequest != null}, shouldShow: $shouldShow');
                if (shouldShow)
                  return Positioned(
                  top: 160,  // Posición donde debe estar (tercer botón)
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _autoFollow = !_autoFollow;
                        if (_autoFollow) {
                          _lastUserInteraction = null;
                          _autoFollowTimer?.cancel();
                          
                          // Si no centra en sí mismo, usar callback para centrar en elementos externos
                          if (!widget.centerOnSelf && widget.onCenterRequest != null) {
                            widget.onCenterRequest!();
                          }
                        }
                      });
                      print('[MapView] Auto-follow toggled: $_autoFollow, centerOnSelf: ${widget.centerOnSelf}');
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
                  );
                else
                  return SizedBox.shrink();
              }),
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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eta_school_app/components/pulsating_circle.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:eta_school_app/shared/location/location_service.dart';
import 'package:eta_school_app/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Pages/attendance_page.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/tripReportPage.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/components/button_text_icon.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:localstorage/localstorage.dart';
import 'package:eta_school_app/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/marquee_text.dart';
import 'map/map_wiew.dart';

class TripPage extends StatefulWidget {
  const TripPage(
      {super.key,
      this.trip,
      required this.navigationMode,
      required this.showBus,
      required this.showStudents});

  final TripModel? trip;

  final bool navigationMode;

  final bool showBus;

  final bool showStudents;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage>
    with ETAWidgets, MediansTheme
    implements OnPointAnnotationClickListener {
  bool existsTripGeoJson = false;

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print("Annotation clicked: ${annotation.id}");
  }

  bool showLoader = false;
  bool isLandscape = false;
  bool isMapExpand = false;
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  String activeTab = 'pickup';

  TripModel trip = TripModel(trip_id: 0);

  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  bool showTripReportModal = false;

  MapboxMap? _mapboxMapController;

  String relationName = '';

  PointAnnotationManager? annotationManager;

  // Map<String, PointAnnotation> annotationsMap = {};
  PointAnnotation? busPointAnnotation;

  bool waitingBusPosition = true;

  ScreenCoordinate busPulsatingCircleCoordinate = ScreenCoordinate(x: 0, y: 0);

  bool connectivityNone = false;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  EmitterService? _emitterServiceProvider;

  late NotificationService _notificationService;

  String tripDuration = "";

  double tripDistance = 0;

  final numberFormat = NumberFormat("#.##");

  Map<String, dynamic>? _lastPositionPayload;

  ScreenCoordinate busModelCoordinate = ScreenCoordinate(x: 0, y: 0);

  double busHeading = 270;

  // Variables for Emitter connection statistics
  int _messageCount = 0; // Total de mensajes (para compatibilidad)
  int _receivedCount = 0; // Eventos recibidos del viaje
  DateTime? _sessionStartTime;
  DateTime? _lastMessageTime;
  DateTime? _lastReceivedTime;
  
  // Control de actualización de anotaciones
  DateTime? _lastAnnotationUpdate;
  static const int _minAnnotationUpdateInterval = 500; // milisegundos

  // Color del autobús para el marcador en el mapa
  late int busColor;

  bool _isVisible = true;
  
  // Control de seguimiento automático del mapa
  bool _autoFollowBus = true;
  DateTime? _lastUserInteraction;
  Timer? _autoFollowTimer;
  
  // Timer para actualizar el tiempo del viaje
  Timer? _tripDurationTimer;

  @override
  void initState() {
    super.initState();

    trip = widget.trip!;
    _lastPositionPayload = trip.lastPositionPayload;

    print('[TripPage.initState] trip_id: ${trip.trip_id}, trip_status: "${trip.trip_status}", is Running: ${trip.trip_status == 'Running'}');

    // Cargar relationName de forma síncrona UNA SOLA VEZ
    _loadRelationName();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentOrientation = MediaQuery.of(context).orientation;
      setState(() {
        isLandscape = currentOrientation == Orientation.landscape;
        // isMapExpand = !isLandscape;
        if (isLandscape) {
          try {
            draggableScrollableController.jumpTo(0.05);
          } catch (e) {
            print("Error al ajustar el panel: $e");
          }
        }
      });
    });

    loadTrip();
    
    // Inicializar timer para actualizar duración del viaje cada segundo
    if (trip.trip_status == 'Running') {
      _tripDurationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted && trip.dt != null) {
          setState(() {
            tripDuration = Utils.formatElapsedTime(trip.dt!);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIsLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (currentIsLandscape != isLandscape) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isLandscape = currentIsLandscape;
          // isMapExpand = !isLandscape;

          // Ajustar el panel según la orientación
          try {
            if (isLandscape) {
              // Minimizar en landscape al mismo nivel que el botón minimizar
              draggableScrollableController.animateTo(
                0.05,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              // Expandir en portrait si estaba expandido
              draggableScrollableController.animateTo(
                0.4,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          } catch (e) {
            print("Error al ajustar el panel: $e");
          }
        });
      });
    }
    // Actualizar el color del autobús para el marcador
    busColor = trip.bus_color != null
        ? _convertColor(trip.bus_color!)
        : Colors.blue.value;
    
    print('[TripPage.build] trip_status: "${trip.trip_status}", navigationMode: ${widget.navigationMode}, showAutoFollowButton will be: ${trip.trip_status == 'Running'}');

    return Material(
        child: showLoader
            ? Loader()
            : Scaffold(
                body: VisibilityDetector(
                  key: Key('student_home_key'),
                  onVisibilityChanged: (info) {
                    _isVisible = info.visibleFraction > 0;
                    if (info.visibleFraction > 0) {
                      loadTrip();
                      // Si el mapa está listo y necesitamos recrear los marcadores
                      if (_mapboxMapController != null && annotationManager != null) {
                        Future.delayed(Duration(milliseconds: 300), () {
                          if (_mapboxMapController != null && mounted) {
                            // Solo mostrar los marcadores si el manager ya existe
                            showTripGeoJson(_mapboxMapController!);
                            showPickupLocations(_mapboxMapController!);
                          }
                        });
                      }
                    } else {
                      cleanResources();
                    }
                  },
                  child: Stack(children: <Widget>[
                    // Column(children: [
                    // // if(widget.showBus && !hasBusPosition )
                    //   SizedBox(
                    //     height: 15,
                    //     child: LinearProgressIndicator(
                    //       color: Colors.white,
                    //       semanticsLabel: "Esperando ubicación del bus...",
                    //     ),
                    //   ),
                    // El mapa ocupa todo el espacio disponible menos el tamaño mínimo del panel
                    Positioned.fill(
                      bottom: isMapExpand
                          ? 0
                          : MediaQuery.of(context).size.height *
                              (isLandscape
                                  ? 0.15
                                  : 0.15), // Ocupar toda la pantalla cuando el panel está oculto
                      child: MapWiew(
                          navigationMode: widget.navigationMode,
                          showLocationPuck: widget.navigationMode, // Si navigationMode es true, es conductor con viaje activo
                          centerOnSelf: widget.navigationMode, // Conductores centran en sí mismos
                          showAutoFollowButton: trip.trip_status == 'Running', // Solo mostrar botón en viajes activos
                          onCenterRequest: widget.navigationMode ? null : _centerOnBus, // Padres/estudiantes centran en el bus
                          onMapReady: (MapboxMap mapboxMap) async {
                            print('[TripPage.MapWiew] trip_status: "${trip.trip_status}", showAutoFollowButton: ${trip.trip_status == 'Running'}');
                            _mapboxMapController = mapboxMap;

                            // Asegurar que el annotationManager esté creado (solo si no existe)
                            if (annotationManager == null) {
                              try {
                                // Limpiar cualquier anotación previa antes de crear el manager
                                busPointAnnotation = null;
                                
                                final value = await mapboxMap.annotations
                                    .createPointAnnotationManager();
                                annotationManager = value;
                                annotationManager
                                    ?.addOnPointAnnotationClickListener(this);
                                print("[TripPage] AnnotationManager created successfully in onMapCreated");
                              } catch (e) {
                                print("[TripPage] Error creating annotation manager: $e");
                              }
                            }

                            // Detectar cuando el usuario interactúa con el mapa
                            mapboxMap.setOnMapMoveListener((context) {
                              if (_lastPositionPayload != null) {
                                final Position position = Position(
                                    double.parse(
                                        "${_lastPositionPayload?['longitude']}"),
                                    double.parse(
                                        "${_lastPositionPayload?['latitude']}"));
                                _updateBusModelCoordinates(
                                    Point(coordinates: position));
                              }
                            });
                            
                            // Por ahora no detectamos gestos automáticamente
                            // TODO: Implementar detección de gestos cuando la API de Mapbox lo soporte
                          },
                          onStyleLoadedListener: (MapboxMap mapboxMap) async {
                            showTripGeoJson(mapboxMap);
                            await Future.delayed(Duration(milliseconds: 100));
                            showPickupLocations(mapboxMap);
                          }),
                    ),

                    if (connectivityNone)
                      Positioned(
                        // left: 0,
                        top: 40,
                        child: SizedBox(
                            height: 50,
                            width: 300,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: AnimatedContainer(
                                    duration: Duration(seconds: 1),
                                    curve: Curves.fastOutSlowIn,
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                              20), // Cambia el valor para ajustar el radio
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.wifi_off,
                                                color: Colors.white),
                                            SizedBox(width: 10),
                                            Text('No hay conexión a Internet',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    if (trip.trip_status == 'Running')
                      Positioned(
                        top: 50,  // Primer botón - Estado de conexión
                        right: 10,
                        child: Consumer<EmitterService>(
                            builder: (context, emitterService, child) {
                          return GestureDetector(
                            onTap: () {
                              _showEmitterTooltip(context, emitterService);
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: emitterService.isConnected()
                                        ? Colors.green
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: emitterService.isConnected()
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      

                    // Positioned(
                    //   left: 0,
                    //   top: 0,
                    //   child: SizedBox(
                    //     height: 10,
                    //     child:
                    //       waitingBusPosition ?
                    //       LinearProgressIndicator() :
                    //       Center()
                    //   ),
                    //   ),
                    if (busPulsatingCircleCoordinate.x.toDouble() > 0)
                      Positioned(
                          left: busPulsatingCircleCoordinate.x.toDouble() - 25,
                          top: busPulsatingCircleCoordinate.y.toDouble() - 25,
                          child: Consumer<EmitterService>(
                              builder: (context, emitterService, child) {
                            return PulsatingCircle(
                                color: emitterService.isConnected()
                                    ? Colors.green
                                    : Colors.red);
                          })),

                    // Eliminado el marcador personalizado en la interfaz
                    // Ahora solo se usa el marcador nativo de Mapbox

                    /* Código comentado del modelo 3D que no se está usando
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: IgnorePointer(
                        child: ModelViewer(
                          src: 'assets/bus.glb', // Ruta al modelo 3D
                          alt: 'Autobús 3D',
                          ar: false, // Habilita AR (si es compatible)
                          backgroundColor: Colors.transparent,
                          autoRotate: false, // Rota el modelo automáticamente
                          cameraControls: false, // Permite controlar la cámara
                          disableZoom: true,
                          disablePan: true,
                          disableTap: true,
                          orientation: "0deg 0deg ${busHeading.toStringAsFixed(1)}deg",
                          interactionPrompt: InteractionPrompt.none,
                        )
                      )
                    )
                    // */

                    Positioned(
                      top: trip.trip_status == 'Running' ? 100 : 50,  // Segundo botón - Fullscreen
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isMapExpand = !isMapExpand;
                          });
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isMapExpand 
                                ? Colors.blue.withOpacity(0.85)
                                : Colors.white.withOpacity(0.9),
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
                            isMapExpand
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            color: isMapExpand ? Colors.white : Colors.black87,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    if (!isMapExpand)
                      DraggableScrollableSheet(
                        controller: draggableScrollableController,
                        snapAnimationDuration: const Duration(seconds: 1),
                        initialChildSize: isLandscape
                            ? 0.05
                            : isMapExpand
                                ? (trip.trip_status == 'Running' ? 0.05 : 0.15)
                                : (trip.trip_status == 'Running' ? 0.4 : 0.25),
                        minChildSize:
                            isLandscape ? 0.05 : (isMapExpand ? 0.05 : 0.25),
                        maxChildSize: 0.95,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return Stack(children: [
                            Container(
                              margin: const EdgeInsets.only(top: 0),
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: activeTheme.main_bg,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(0.0, -3.0),
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              controller: scrollController,
                              child: Stack(children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.2),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  padding: const EdgeInsets.all(20),
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                return _TappableMarqueeText(
                                                  text: "${lang.translate('Trip')} #${trip.trip_id} ${trip.route?.route_name ?? ''}",
                                                  width: constraints.maxWidth - 10,
                                                  style: activeTheme.h6,
                                                );
                                              },
                                            ),
                                          ),
                                          Row(children: [
                                            SvgPicture.asset(
                                              "assets/svg/bus.svg",
                                              width: 15,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              trip.vehicle?.plate_number ?? '',
                                            )
                                          ]),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      if (trip.trip_status == "Running")
                                        Row(
                                          // textDirection: TextDirection.LTR,
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(height: 10),
                                            Icon(Icons.access_time, size: 20),
                                            Text(tripDuration),
                                            const SizedBox(width: 10),
                                            Icon(Icons.route, size: 20),
                                            Text(tripDistance >= 1000
                                                ? '${numberFormat.format(tripDistance / 1000)} KM'
                                                : '${numberFormat.format(tripDistance)} m'),
                                            const SizedBox(width: 10),
                                            (trip.pickup_locations != null)
                                                ? Icon(Icons.pin_drop_outlined,
                                                    size: 20)
                                                : const Center(),
                                            (trip.pickup_locations != null)
                                                ? Text(
                                                    '${trip.visitedLocation()}/${trip.pickup_locations!.length.toString()} ',
                                                  )
                                                : const Center(),
                                            if (trip.trip_status ==
                                                    'Completed' &&
                                                relationName == 'eta.drivers')
                                              GestureDetector(
                                                  onTap: (() {
                                                    openNewPage(
                                                        context,
                                                        AttendancePage(
                                                            trip: trip));
                                                  }),
                                                  child: Center(
                                                      child: ButtonTextIcon(
                                                          '',
                                                          Icon(
                                                            Icons.list,
                                                            color: activeTheme
                                                                .buttonBG,
                                                          ),
                                                          activeTheme
                                                              .buttonColor))),
                                          ],
                                        ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        height: 1,
                                        color: activeTheme.main_color
                                            .withOpacity(.3),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      trip.trip_status == 'Completed'
                                          ? ETAWidgets.tripInfoRow(trip)
                                          : const Center(),
                                      // DEBUG: Print relationName and button visibility
                                      Builder(builder: (context) {
                                        print('[TripPage.build] relationName: "$relationName"');
                                        print('[TripPage.build] trip_status: "${trip.trip_status}"');
                                        print('[TripPage.build] Es conductor (eta.drivers): ${relationName == 'eta.drivers'}');
                                        print('[TripPage.build] Botones visibles: ${trip.trip_status == 'Running' && relationName == 'eta.drivers'}');
                                        return const SizedBox.shrink();
                                      }),
                                      Row(children: [
                                        // Mostrar SOLO si es conductor Y el viaje está Running
                                        if (trip.trip_status == 'Running' &&
                                            relationName == 'eta.drivers')
                                          GestureDetector(
                                              onTap: showLoader
                                                  ? null
                                                  : (() {
                                                      endTrip();
                                                    }),
                                              child: Center(
                                                  child: ButtonTextIcon(
                                                      lang.translate(
                                                          'End trip'),
                                                      Icon(
                                                        Icons.route,
                                                        color: activeTheme
                                                            .buttonColor,
                                                      ),
                                                      showLoader
                                                          ? Colors.grey
                                                          : Colors.red))),
                                        if (trip.trip_status == 'Running' &&
                                            relationName == 'eta.drivers')
                                          const SizedBox(
                                            width: 20,
                                          ),
                                        if (trip.trip_status == 'Running' &&
                                            relationName == 'eta.drivers')
                                          GestureDetector(
                                              onTap: (() {
                                                openNewPage(context,
                                                    AttendancePage(trip: trip));
                                              }),
                                              child: Center(
                                                  child: ButtonTextIcon(
                                                      lang.translate(
                                                          'Attendance'),
                                                      Icon(
                                                        Icons.list,
                                                        color: activeTheme
                                                            .buttonColor,
                                                      ),
                                                      Color.fromARGB(
                                                          255, 226, 187, 32)))),
                                      ]),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      for (var i = 0;
                                          i < trip.pickup_locations!.length;
                                          i++)
                                        activeTab == 'pickup'
                                            ? Row(children: [
                                                tripUser(
                                                    trip.pickup_locations![i]),
                                              ])
                                            : const Center(),
                                    ],
                                  ),
                                )
                              ]),
                            )
                          ]);
                        },
                      ),
                    showTripReportModal
                        ? TripReport(trip: trip)
                        : const Center(),
                  ]),
                  // ])
                ),
              ));
  }

  CoordinateBounds getCoordinateBounds(List<Position> points) {
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = -double.infinity;
    double maxLng = -double.infinity;

    for (var point in points) {
      minLat = min(minLat, point.lat as double);
      minLng = min(minLng, point.lng as double);
      maxLat = max(maxLat, point.lat as double);
      maxLng = max(maxLng, point.lng as double);
    }

    print('[TripPage.getCoordinateBounds] $minLng, $minLat');
    print('[TripPage.getCoordinateBounds] $maxLng, $maxLat');

    return CoordinateBounds(
      southwest: Point(coordinates: Position(minLng, minLat)),
      northeast: Point(coordinates: Position(maxLng, maxLat)),
      infiniteBounds: true,
    );
  }

  Widget tripUser(TripPickupLocation pickupLocation) {
    // print('[TripPage.tripUser.pickupLocation]');
    return GestureDetector(
      onTap: () {
        _mapboxMapController?.setCamera(CameraOptions(
            zoom: 18,
            center: Point(
                coordinates: Position(pickupLocation.location!.longitude as num,
                    pickupLocation.location!.latitude as num))));
      },
      child: Row(children: [
        const SizedBox(
          width: 10,
        ),
        Column(
          children: [
            SizedBox(
              width: 20,
              height: 10,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pickupLocation.status != 'waiting'
                        ? Colors.green
                        : Colors.grey),
              ),
            ),
            Container(
              width: 3.0,
              height: 120.0,
              color: pickupLocation.status != 'waiting'
                  ? Colors.green
                  : Colors.grey,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarqueeText(
              text: '${pickupLocation.location?.location_name ?? ''}',
              style: activeTheme.h5,
              width: 300,
              autoStart: true,
            ),
            SizedBox(
                width: 300,
                child: Text(
                  '${pickupLocation.location?.address}',
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: activeTheme.smallText.fontSize,
                      color: activeTheme.smallText.color),
                )),
          ],
        )
      ]),
    );
  }

  endTrip() async {
    if (mounted) {
      setState(() {
        showLoader = true;
      });
    }

    try {
      await trip.endTrip();
      setState(() {
        showLoader = false;
        showTripReportModal = true;
      });
    } catch (e) {
      print("[TripPage.endTrip.error] ${e.toString()}");
      var msg = e.toString().split('/');
      setState(() {
        showLoader = false;
      });
      showSuccessDialog(context, "${lang.translate('Error')} (${msg[1]})",
          lang.translate(msg[0]), () {
        Get.back();
      });
    }

    try {
      LocationService.instance.stopLocationService();
      cleanResources();
    } catch (e) {
      print(e);
    }
  }

  /// Carga relationName UNA SOLA VEZ desde StorageService
  void _loadRelationName() async {
    try {
      relationName = await StorageService.instance.getString('relation_name') ?? '';
      print('[TripPage] relationName cargado: "$relationName"');
      if (mounted) setState(() {});
    } catch (e) {
      print('[TripPage] Error cargando relationName: $e');
      relationName = '';
    }
  }

  loadTrip() async {
    print("[TripPage.loadTrip] ");
    try {
      if (trip.trip_status == "Running") {
        print("[TripPage.loadTrip][trip.trip_status] ${trip.trip_status}");
        Wakelock.enable();

        initConnectivity();
        _connectivitySubscription =
            _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

        _emitterServiceProvider =
            Provider.of<EmitterService>(context, listen: false);
        _emitterServiceProvider?.addListener(onEmitterMessage);
        _emitterServiceProvider?.startTimer(false);
        
        // Initialize Emitter session tracking
        _sessionStartTime = DateTime.now();
        _messageCount = 0;
        _receivedCount = 0;
        _lastMessageTime = null;
        _lastReceivedTime = null;
        
        trip.subscribeToTripEvents(_emitterServiceProvider);
        trip.subscribeToTripTracking(_emitterServiceProvider);

        _notificationService =
            Provider.of<NotificationService>(context, listen: false);
        _notificationService.addListener(onPushMessage);

        // Suscribirse a los temas relevantes
        _notificationService.subscribeToTopic("trip-${trip.trip_id}");
      }
    } catch (e) {
      print("[TripPage.loadTrip] $e");
    }

    // relationName ya fue cargado en initState() - no es necesario volver a leerlo

    try {
      TripModel? trip_ = await httpService.getTrip(widget.trip?.trip_id);
      print("[TripPage.loadTrip][getTrip] ${trip.trip_status}");
      if (trip_.trip_id != 0) {
        setState(() {
          trip = trip_;
          showLoader = false;
          print(
              "[TripPage.loadTrip][trip_.lastPositionPayload] ${trip_.lastPositionPayload}");
          processTrackingMessage(trip_.lastPositionPayload);
        });
      }
    } catch (e) {
      print("[TripPage.loadTrip.error] $e");
    }
  }

  // Helper method para determinar si el usuario es padre/representante
  bool _isParentRole() {
    return relationName.contains('eta.guardians') || 
           relationName.contains('eta.parents') || 
           relationName.contains('representante') ||
           relationName.contains('tutor') ||
           relationName.contains('guardian');
  }
  
  // Método para centrar el mapa en la posición del bus
  void _centerOnBus() {
    if (busPointAnnotation != null && _mapboxMapController != null) {
      final busPosition = busPointAnnotation!.geometry;
      print("[TripPage._centerOnBus] Centering on bus position: $busPosition");
      _mapboxMapController!.flyTo(
        CameraOptions(
          center: busPosition,
          zoom: 16,
          // pitch: 60, // original 3D tilt
          pitch: 0,
        ),
        MapAnimationOptions(duration: 1000, startDelay: 0)
      );
    } else if (_lastPositionPayload != null && _mapboxMapController != null) {
      // Si no hay anotación pero tenemos la última posición conocida
      final Position position = Position(
        double.parse("${_lastPositionPayload?['longitude']}"),
        double.parse("${_lastPositionPayload?['latitude']}")
      );
      print("[TripPage._centerOnBus] Centering on last known bus position: $position");
      _mapboxMapController!.flyTo(
        CameraOptions(
          center: Point(coordinates: position),
          zoom: 16,
          // pitch: 60, // original 3D tilt
          pitch: 0,
        ),
        MapAnimationOptions(duration: 1000, startDelay: 0)
      );
    } else {
      print("[TripPage._centerOnBus] No bus position available to center on");
    }
  }

  void cleanResources() {
    try {
      _emitterServiceProvider?.removeListener(onEmitterMessage);
      _notificationService.removeListener(onPushMessage);
      _connectivitySubscription.cancel();
      Wakelock.disable();

      // Limpiar el mapa solo si es una limpieza completa (cuando se destruye la página)
      print("Realizando limpieza completa de recursos");
      annotationManager?.deleteAll();
      annotationManager = null;
      busPointAnnotation = null;

      // Desuscribirse de eventos
      if (trip.trip_status == "Running") {
        trip.unSubscribeToTripTracking(_emitterServiceProvider);
        trip.unSubscribeToTripEvents(_emitterServiceProvider);
      }
    } catch (e) {
      print("Error cleaning resources: $e");
    }
  }

  void _showEmitterTooltip(BuildContext context, EmitterService emitterService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _LiveConnectionDialog(
          parentState: this,
        );
      },
    );
  }

  @override
  void dispose() {
    _autoFollowTimer?.cancel();
    _tripDurationTimer?.cancel();
    super.dispose();
    cleanResources();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status ${e.toString()}');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    setState(() {
      connectivityNone =
          results.any((result) => result == ConnectivityResult.none);
    });
    // ignore: avoid_print
    print('connectivityNone: $connectivityNone');
  }

  // void _showInfoWindow(PointAnnotation annotation) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return Container(
  //         padding: EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Información del Marker',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             SizedBox(height: 8.0),
  //             Text('ID: ${annotation.id}'),
  //             Text('Coordenadas:'),
  //             // Puedes agregar más información aquí
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void showTripGeoJson(MapboxMap mapboxMap) async {
    print("[TripPage.showTripGeoJson]");

    if (annotationManager == null) {
      try {
        final value = await mapboxMap.annotations.createPointAnnotationManager();
        annotationManager = value;
        annotationManager?.addOnPointAnnotationClickListener(this);
        print("[TripPage.showTripGeoJson] AnnotationManager created");
      } catch (e) {
        print("[TripPage.showTripGeoJson] Error creating annotation manager: $e");
      }
    }

    if (existsTripGeoJson) return;

    Map<String, dynamic> data = trip.geoJson!;
    // final lineColorValue = Color.fromRGBO(33, 150, 243, 0.4).value; // original semi-transparent
    final lineColorValue = Color.fromRGBO(33, 150, 243, 1.0).value; // más sólido

    if (trip.route_attributes != null &&
        trip.route_attributes!["lineColor"] != null) {
      // lineColorValue = _convertColor(trip.route_attributes!["lineColor"]);
    }

    await mapboxMap.style
        .addSource(GeoJsonSource(id: "trip_source", data: jsonEncode(data)));

    final lineLayer = LineLayer(
      id: "line_layer",
      sourceId: "trip_source",
      lineJoin: LineJoin.ROUND,
      lineCap: LineCap.ROUND,
      lineColor: lineColorValue,
      lineBlur: 0.0,
      // lineDasharray: [1.0, 2.2], // original línea punteada
      lineWidth: 5.0,
      lineSortKey: 0,
      // lineOpacity: 0.4, // original más transparente
      lineOpacity: 1.0,
    );

    // Intentar colocar la línea por debajo de las labels de transporte/POI
    try {
      await mapboxMap.style.addLayerAt(
        lineLayer,
        LayerPosition(below: "transit-label"),
      );
    } catch (e) {
      print("[TripPage.showTripGeoJson] addLayerAt below 'transit-label' failed: $e");
      try {
        await mapboxMap.style.addLayerAt(
          lineLayer,
          LayerPosition(below: "poi-label"),
        );
      } catch (e2) {
        print("[TripPage.showTripGeoJson] addLayerAt below 'poi-label' failed: $e2, falling back to addLayer");
        await mapboxMap.style.addLayer(lineLayer);
      }
    }

    // Banderas de inicio y fin basadas en la geometría de la ruta (geoJson)
    try {
      if (annotationManager != null) {
        List<dynamic>? coordinates;

        final type = data['type'];
        if (type == 'FeatureCollection') {
          final features = data['features'] as List?;
          if (features != null && features.isNotEmpty) {
            final feature = features.first;
            final geom = feature['geometry'];
            if (geom != null) {
              final geomType = geom['type'];
              if (geomType == 'LineString') {
                coordinates = geom['coordinates'] as List?;
              } else if (geomType == 'MultiLineString') {
                final lines = geom['coordinates'] as List?;
                if (lines != null && lines.isNotEmpty) {
                  coordinates = [];
                  for (final line in lines) {
                    coordinates.addAll(line as List);
                  }
                }
              }
            }
          }
        } else if (type == 'Feature') {
          final geom = data['geometry'];
          if (geom != null) {
            final geomType = geom['type'];
            if (geomType == 'LineString') {
              coordinates = geom['coordinates'] as List?;
            } else if (geomType == 'MultiLineString') {
              final lines = geom['coordinates'] as List?;
              if (lines != null && lines.isNotEmpty) {
                coordinates = [];
                for (final line in lines) {
                  coordinates.addAll(line as List);
                }
              }
            }
          }
        } else if (type == 'LineString') {
          coordinates = data['coordinates'] as List?;
        }

        if (coordinates != null && coordinates.isNotEmpty) {
          final start = coordinates.first;
          final end = coordinates.last;

          final startLng = (start[0] as num).toDouble();
          final startLat = (start[1] as num).toDouble();
          final endLng = (end[0] as num).toDouble();
          final endLat = (end[1] as num).toDouble();

          final startPosition = Position(startLng, startLat);
          final endPosition = Position(endLng, endLat);

          final Uint8List startMarker = await createCircleMarkerImage(
            circleColor: Colors.white,
            icon: FontAwesomeIcons.flag,
            size: 104,
            iconColor: Colors.yellow,
            iconSize: 56,
          );

          final Uint8List endMarker = await createCircleMarkerImage(
            circleColor: Colors.white,
            icon: FontAwesomeIcons.flagCheckered,
            size: 104,
            iconColor: Colors.green,
            iconSize: 56,
          );

          await annotationManager?.create(PointAnnotationOptions(
            textField: '',
            textColor: Colors.black.value,
            textLineHeight: 1,
            textSize: 11,
            iconSize: 0.8,
            textOffset: [0.0, -2.0],
            symbolSortKey: 3,
            geometry: Point(coordinates: startPosition),
            image: startMarker,
            textHaloColor: Colors.white.value,
            textHaloWidth: 2,
          ));

          await annotationManager?.create(PointAnnotationOptions(
            textField: '',
            textColor: Colors.black.value,
            textLineHeight: 1,
            textSize: 11,
            iconSize: 0.8,
            textOffset: [0.0, -2.0],
            symbolSortKey: 3,
            geometry: Point(coordinates: endPosition),
            image: endMarker,
            textHaloColor: Colors.white.value,
            textHaloWidth: 2,
          ));
        }
      }
    } catch (e) {
      print("[TripPage.showTripGeoJson] Error creating start/end flags from geoJson: $e");
    }

    existsTripGeoJson = true;
  }

  int _convertColor(String colorStr) {
    if (colorStr.isEmpty) return Colors.blue.value;
    colorStr = colorStr.trim();

    if (colorStr.toLowerCase().startsWith('rgba')) {
      final regExp = RegExp(
        r'rgba\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*([\d.]+)\s*\)',
      );
      final match = regExp.firstMatch(colorStr);

      if (match != null) {
        int r = int.parse(match.group(1)!);
        int g = int.parse(match.group(2)!);
        int b = int.parse(match.group(3)!);
        double a = double.parse(match.group(4)!);

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);
        a = a.clamp(0.0, 1.0);

        //int alpha = (a * 255).round() & 0xFF;
        int alpha = 255;
        return (alpha << 24) | (r << 16) | (g << 8) | b;
      }
    } else if (colorStr.toLowerCase().startsWith('rgb')) {
      final regExp =
          RegExp(r'rgb\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)');
      final match = regExp.firstMatch(colorStr);

      if (match != null) {
        int r = int.parse(match.group(1)!);
        int g = int.parse(match.group(2)!);
        int b = int.parse(match.group(3)!);

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        return (0xFF << 24) | (r << 16) | (g << 8) | b;
      }
    } else {
      colorStr = colorStr.toUpperCase().replaceAll('#', '');

      if (colorStr.length == 3) {
        colorStr = colorStr.split('').map((c) => c + c).join('');
      }

      if (colorStr.length == 6) {
        colorStr = 'FF$colorStr';
      }

      if (RegExp(r'^[0-9A-F]{8}$').hasMatch(colorStr)) {
        return int.parse(colorStr, radix: 16);
      }
    }

    return Colors.blue.value;
  }

  Future<Uint8List> createCircleMarkerImage(
      {required Color circleColor,
      IconData? icon,
      ui.Image? image,
      double size = 160,
      Color iconColor = Colors.white,
      double iconSize = 80,
      double imageSize = 80,
      Color borderColor = Colors.black12}) async {
    assert(icon != null || image != null,
        'Debe proporcionar un icono o una imagen');

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()..color = circleColor;
    final center = Offset(size / 2, size / 2);

    canvas.drawOval(
        Rect.fromLTWH(0, 0, size + 3, size + 3), Paint()..color = borderColor);

    // Dibujar el círculo de fondo
    canvas.drawCircle(center, size / 2, paint);

    if (image != null) {
      // Si se proporciona una imagen, dibujarla en el centro
      final srcRect =
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      final destSize = imageSize;
      final destRect = Rect.fromCenter(
        center: center,
        width: destSize,
        height: destSize,
      );

      canvas.drawImageRect(
        image,
        srcRect,
        destRect,
        Paint(),
      );
    } else if (icon != null) {
      // Si se proporciona un icono, dibujarlo como antes
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: icon.fontFamily,
            color: iconColor,
            package: icon.fontPackage,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  IconData _getIconByType(String iconName) {
    if (iconName.isEmpty) return FontAwesomeIcons.locationDot;

    String normalizedName = iconName.toLowerCase().trim();

    switch (normalizedName) {
      case 'pickup-point':
        return FontAwesomeIcons.personShelter;
      case 'school':
        return FontAwesomeIcons.school;
      case 'parking':
        return FontAwesomeIcons.squareParking;
      case 'waypoint':
        return FontAwesomeIcons.mapPin;
      default:
        return FontAwesomeIcons.locationDot;
    }
  }

  static final Map<int, Uint8List?> _busMarkerCache = {};

  Future<ui.Image> loadImageFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<ui.Image> loadImageFromFile(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  void showPickupLocations(MapboxMap mapboxMap) async {
    print("[TripPage.showPickupLocations]");

    List<Position> points = [];

    for (var pickupPoint in trip.pickup_locations!) {
      if (pickupPoint.location == null) continue;

      final position = Position(pickupPoint.location!.longitude as double,
          pickupPoint.location!.latitude as double);

      final Uint8List customMarker = await createCircleMarkerImage(
          circleColor: Colors.green,
          icon: _getIconByType(pickupPoint.location?.point_type ?? ''),
          size: 104,
          iconColor: Colors.white,
          iconSize: 56);

      final point = PointAnnotationOptions(
        textField: "${pickupPoint.location?.location_name}",
        textColor: Colors.black.value,
        textLineHeight: 1,
        textSize: 11,
        iconSize: 0.8,
        textOffset: [0.0, -2.0],
        symbolSortKey: 2,
        geometry: Point(coordinates: position),
        image: customMarker,
        textHaloColor: Colors.white.value,
        textHaloWidth: 2,
      );

      annotationManager?.create(point);
      points.add(position);
    }

    try {
      tripDuration = Utils.formatElapsedTime(trip.dt!);
    } catch (e) {
      print("[TripPage.initState.formatElapsedTime.error] $e");
    }

    if (trip.lastPositionPayload != null &&
        relationName != "eta.drivers" &&
        trip.trip_status == "Running") {
      print(
          "[TripPage.initState] lastPositionPayload ${trip.lastPositionPayload}");
      final Position position = trip.lastPosition()!;
      final label = formatUnixEpoch(trip.lastPositionPayload['time'].toInt());

      // FIX: Pasar el driver_id directamente en lugar de usar relationName del driver
      // El método _updateIcon verificará internamente si debe mostrar el ícono
      _updateIcon(
          position, 'driver-position', trip.driver_id!, label);
      // mapboxMap.setCamera(CameraOptions(zoom: 18, pitch: 70)); // original 3D tilt
      mapboxMap.setCamera(CameraOptions(zoom: 18, pitch: 0));
    } else {
      final coordinateBounds = getCoordinateBounds(points);
      // mapboxMap.setCamera(CameraOptions(center: coordinateBounds.southwest, zoom: 18, pitch: 45)); // original 3D tilt
      mapboxMap.setCamera(CameraOptions(
          center: coordinateBounds.southwest, zoom: 18, pitch: 0));
    }
  }

  _updatePulsatingCircle(Point point) async {
    final coordinate = await _mapboxMapController?.pixelForCoordinate(point);
    print("[_updatePulsatingCircle] ${coordinate?.x}");
    setState(() {
      busPulsatingCircleCoordinate = coordinate!;
    });

    Timer(Duration(seconds: 1), () {
      setState(() {
        busPulsatingCircleCoordinate.x = 0;
      });
    });
  }

  Future<void> _updateBusModelCoordinates(Point point) async {
    try {
      final coordinate = await _mapboxMapController?.pixelForCoordinate(point);
      if (coordinate == null || !mounted) return;

      final cameraState = await _mapboxMapController?.getCameraState();
      final mapBearing = cameraState?.bearing ?? 0;

      final busTrueHeading =
          _lastPositionPayload?['heading']?.toDouble() ?? 270;

      final adjustedHeading = (busTrueHeading - mapBearing + 360) % 360;

      if (mounted) {
        setState(() {
          busModelCoordinate = coordinate;
          busHeading = adjustedHeading;
        });
      }
    } catch (e) {
      print("Error en _updateBusModelCoordinates: $e");
    }
  }

  Future<void> _updateIcon(Position position, String identificador,
      int driverId, String label) async {
    String key = "$identificador.$driverId";
    print(
        "[TripPage._updateIcon] [identificador] $identificador [driverId] $driverId [userRole] $relationName");

    if (key.isEmpty) {
      return;
    }

    // El ícono del bus SOLO se muestra para estudiantes/guardians, NO para conductores
    // Si el usuario actual ES conductor (this.relationName), NO mostrar el ícono
    if (this.relationName == "eta.drivers") {
      print("[TripPage._updateIcon] Usuario actual es conductor - NO mostrar ícono del bus");
      return;
    }

    // Si llegamos aquí, el usuario NO es conductor (es estudiante/guardian)
    // Verificar que los datos correspondan al driver del viaje
    if (trip.driver_id != driverId) {
      print(
          "[TripPage._updateIcon] Datos no corresponden al driver de este viaje [${trip.driver_id} != $driverId]");
      return;
    }
    
    // Debounce: evitar actualizaciones muy frecuentes que puedan causar duplicados
    if (_lastAnnotationUpdate != null) {
      final timeSinceLastUpdate = DateTime.now().difference(_lastAnnotationUpdate!).inMilliseconds;
      if (timeSinceLastUpdate < _minAnnotationUpdateInterval) {
        print("[TripPage._updateIcon] Skipping update - too frequent (${timeSinceLastUpdate}ms since last update)");
        return;
      }
    }
    _lastAnnotationUpdate = DateTime.now();

    try {
      // If the annotation doesn't exist, create it
      if (busPointAnnotation == null) {
        print("[TripPage._updateIcon] creating new point annotation");

        // final int currentBusColor = trip.bus_color != null
        //     ? _convertColor(trip.bus_color!)
        //     : Colors.blue.value;
        final int currentBusColor = Colors.white.value;

        Uint8List? imageData;
        // if (_busMarkerCache.containsKey(currentBusColor) &&
        //     _busMarkerCache[currentBusColor] != null) {
        //   imageData = _busMarkerCache[currentBusColor]!;
        // // } else {
        final ui.Image busImage =
            await loadImageFromAsset('assets/bus_color.png');
        imageData = await createCircleMarkerImage(
            circleColor: Color(currentBusColor),
            image: busImage,
            size: 96,
            imageSize: 72);
        _busMarkerCache[currentBusColor] = imageData;
        // }

        busPointAnnotation =
            await annotationManager?.create(PointAnnotationOptions(
          geometry: Point(coordinates: position),
          image: imageData,
          textSize: 14,
          textField: label,
          textOffset: [
            0.0,
            -2.0
          ], // Ajustado de -3.5 a -2.0 para acercar el texto
          textColor: Colors.black.value,
          textHaloColor: Colors.white.value,
          textHaloWidth: 2,
          iconSize: 1.0, // Reducido de 1.2 a 1.0 para tamaño más adecuado
          symbolSortKey: 3,
        ));

        // Solo ajustar el zoom la primera vez
        _mapboxMapController?.setCamera(CameraOptions(
            // center: Point(coordinates: position), zoom: 18, pitch: 70)); // original 3D tilt
            center: Point(coordinates: position), zoom: 18, pitch: 0));
      }
      // Si ya existe, eliminamos la anterior y creamos una nueva para evitar duplicados
      else  {
        print("[TripPage._updateIcon] updating existing point annotation - recreating to avoid duplicates");
        
        // Eliminar la anotación anterior
        if (busPointAnnotation != null) {
          try {
            await annotationManager?.delete(busPointAnnotation!);
          } catch (e) {
            print("[TripPage._updateIcon] Error deleting old annotation: $e");
          }
        }
        
        // Crear nueva anotación con la posición y etiqueta actualizadas
        final int currentBusColor = Colors.white.value;
        
        Uint8List? imageData;
        if (_busMarkerCache.containsKey(currentBusColor) &&
            _busMarkerCache[currentBusColor] != null) {
          imageData = _busMarkerCache[currentBusColor]!;
        } else {
          final ui.Image busImage =
              await loadImageFromAsset('assets/bus_color.png');
          imageData = await createCircleMarkerImage(
              circleColor: Color(currentBusColor),
              image: busImage,
              size: 96,
              imageSize: 72);
          _busMarkerCache[currentBusColor] = imageData;
        }
        
        busPointAnnotation =
            await annotationManager?.create(PointAnnotationOptions(
          geometry: Point(coordinates: position),
          image: imageData,
          textSize: 14,
          textField: label,
          textOffset: [
            0.0,
            -2.0
          ],
          textColor: Colors.black.value,
          textHaloColor: Colors.white.value,
          textHaloWidth: 2,
          iconSize: 1.0,
          symbolSortKey: 3,
        ));

        // Solo centrar el mapa si el auto-seguimiento está activado
        if (_autoFollowBus) {
          _mapboxMapController?.flyTo(
            CameraOptions(center: Point(coordinates: position)),
            MapAnimationOptions(duration: 1000, startDelay: 0)
          );
        }
        
        // Si el usuario no ha interactuado en los últimos 30 segundos, reactivar auto-seguimiento
        if (_lastUserInteraction != null) {
          final timeSinceInteraction = DateTime.now().difference(_lastUserInteraction!);
          if (timeSinceInteraction.inSeconds > 30) {
            setState(() {
              _autoFollowBus = true;
            });
          }
        }
      }

      _updateBusModelCoordinates(Point(coordinates: position));
    } catch (e) {
      print("[TripPage._updateIcon] error: ${e.toString()}");
      // If update fails, recreate the annotation
      // busPointAnnotation = null;
      // _updateIcon(position, relationName, relationId, label);
    }
  }
  //  void _animateIcon(LatLng start, LatLng end) {
  //   const int animationDuration = 1000; // Duración en milisegundos
  //   const int frameRate = 60; // Frames por segundo
  //   final int totalFrames = (animationDuration / (1000 / frameRate)).round();

  //   double latDiff = end.latitude - start.latitude;
  //   double lonDiff = end.longitude - start.longitude;

  //   Timer.periodic(Duration(milliseconds: (1000 / frameRate).round()), (timer) {
  //     double t = timer.tick / totalFrames;
  //     if (t > 1.0) {
  //       t = 1.0;
  //       timer.cancel();
  //     }
  //     double latitude = start.latitude + latDiff * t;
  //     double longitude = start.longitude + lonDiff * t;
  //     _mapboxMapController.updateSymbol(
  //       _symbol!,
  //       SymbolOptions(
  //         geometry: LatLng(latitude, longitude),
  //       ),
  //     );
  //   });
  // }

  // Note: Position counting is now handled by LocationService directly

  void onEmitterMessage() async {
    if (!_isVisible) return; // No procesar si no está visible

    // Update Emitter statistics
    _messageCount++;
    _lastMessageTime = DateTime.now();
    
    // Los mensajes recibidos en trip_page son eventos del viaje
    _receivedCount++;
    _lastReceivedTime = DateTime.now();

    final String message = _emitterServiceProvider!.lastMessage();

    if (mounted) {
      setState(() {
        tripDuration = Utils.formatElapsedTime(trip.dt!);
      });
    }

    try {
      if (!widget.navigationMode) {
        processTrackingMessage(jsonDecode(message));
      }
    } catch (e) {
      await proccessTripEventMessage(message);
    }
  }

  void processTrackingMessage(Map<String, dynamic> tracking) async {
    print("[processTrackingMessage] $tracking");

    final lastTime = _lastPositionPayload?['time']?.toInt();
    final currentTime = tracking['payload']?['time']?.toInt();

    if (_lastPositionPayload != null &&
        lastTime != null &&
        currentTime != null &&
        lastTime > currentTime) {
      print("[trippage.processTrackingMessage.ignore position by time]");
      return;
    }

    if (tracking['relation_name'] != null &&
        tracking['relation_name'] == "eta.drivers") {
      final driverId = tracking['relation_id'];

      if (tracking['payload'] != null) {
        final Position position = Position(
            double.parse("${tracking['payload']['longitude']}"),
            double.parse("${tracking['payload']['latitude']}"));
        final label = formatUnixEpoch(tracking['payload']['time']?.toInt());

        try {
          tripDistance = double.parse("${tracking['payload']['distance']}");
        } catch (e) {
          print("Error procesando la distancia: $e");
        }

        // FIX: Pasar identificador correcto para mostrar posición del conductor
        _updateIcon(position, 'driver-position', driverId, label);

        _lastPositionPayload = tracking['payload'];
        try {
          busHeading = _lastPositionPayload?['heading'] ??
              _lastPositionPayload?['heading'];
        } catch (e) {
          print("busHeading error $e");
        }
        EmitterService.instance.updateLastEmitterDate(DateTime.now());
      }
    }
  }

  Future<void> proccessTripEventMessage(String message) async {
    try {
      // si es un evento del viaje
      final event = EventModel.fromJson(jsonDecode(message));
      if (event.type == "end-trip" && relationName != 'eta.drivers') {
        try {
          // Limpiar recursos y navegar al home
          // cleanResources(fullCleanup: true);

          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } catch (e) {
          //
        }

        if (mounted) {
          setState(() {
            Get.back();
          });
        }
      } else {
        final updatedTrip = await httpService.getTrip(trip.trip_id);
        if (mounted) {
          setState(() {
            trip = updatedTrip;
          });
        }
      }
    } catch (e) {
      // print("[TripPage] $e");
    }
  }

  String formatUnixEpoch(int? unixEpoch) {
    if (unixEpoch == null) {
      return '';
    }
    DateTime dateTimeUtc = DateTime.fromMillisecondsSinceEpoch(unixEpoch);
    DateTime dateTimeLocal = dateTimeUtc.toLocal();
    return Utils.formatearFechaCorta(dateTimeLocal);
  }

  void onPushMessage() {
    print("[TripPage.onPushMessage]");
    final LastMessage? lastMessage = NotificationService.instance.lastMessage;
    final title = lastMessage?.message!.notification!.title ?? "Nuevo mensaje";

    if (lastMessage != null && mounted) {
      // Mostrar el mensaje como un snackbar o diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(title),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// Widget del diálogo de conexión en vivo que se actualiza automáticamente
class _LiveConnectionDialog extends StatefulWidget {
  final _TripPageState parentState;

  const _LiveConnectionDialog({
    Key? key,
    required this.parentState,
  }) : super(key: key);

  @override
  State<_LiveConnectionDialog> createState() => _LiveConnectionDialogState();
}

class _LiveConnectionDialogState extends State<_LiveConnectionDialog> {
  Timer? _updateTimer;
  bool _wasDisconnected = false;
  DateTime? _disconnectionTime;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    
    // Actualizar cada segundo para refrescar todos los valores en tiempo real
    _updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Solo trigger rebuild, los valores se calculan en build()
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmitterService>(
      builder: (context, emitterService, child) {
        // Usar el rol real del usuario en lugar de solo navigationMode
        final relationName = widget.parentState.relationName;
        final isDriver = widget.parentState.widget.navigationMode && relationName == 'eta.drivers';
        final isParent = relationName.contains('eta.guardians') || 
                        relationName.contains('eta.parents') || 
                        relationName.contains('representante') ||
                        relationName.contains('tutor');
        
        // Solo mostrar posiciones si es conductor Y NO es padre/representante
        final shouldShowPositions = isDriver && !isParent;
        
        print("[LiveConnectionDialog] relationName: '$relationName', isDriver: $isDriver, isParent: $isParent, shouldShowPositions: $shouldShowPositions");
        
        final currentMessageCount = widget.parentState._messageCount;
        
        // Calcular tiempo real desde el inicio de la sesión del emitter
        final realSessionDuration = widget.parentState._sessionStartTime != null
            ? DateTime.now().difference(widget.parentState._sessionStartTime!).inSeconds
            : 0;
            
        final eventsPerSecond = realSessionDuration > 0 
            ? (currentMessageCount / realSessionDuration).toStringAsFixed(2)
            : '0.00';
        
        final lastEventTime = widget.parentState._lastMessageTime != null
            ? '${widget.parentState._lastMessageTime!.hour.toString().padLeft(2, '0')}:${widget.parentState._lastMessageTime!.minute.toString().padLeft(2, '0')}:${widget.parentState._lastMessageTime!.second.toString().padLeft(2, '0')}'
            : isDriver ? 'Sin envíos' : 'Sin eventos';
        
        final timeSinceLastEvent = widget.parentState._lastMessageTime != null
            ? DateTime.now().difference(widget.parentState._lastMessageTime!).inSeconds
            : 0;
        
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: emitterService.isConnected() ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: emitterService.isConnected() ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text('Conexión en Vivo'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    emitterService.isConnected() ? Icons.check_circle : Icons.cancel,
                    color: emitterService.isConnected() ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text('${emitterService.isConnected() ? "Conectado" : "Desconectado"}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: emitterService.isConnected() ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Sección de Posiciones Enviadas (solo para conductores, NO para padres/representantes)
              if (shouldShowPositions)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📤 Posiciones enviadas: ${LocationService.instance.positionsSent}',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    if (LocationService.instance.lastPositionSentTime != null) ...[
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Text('${LocationService.instance.lastPositionSentTime!.hour.toString().padLeft(2, '0')}:${LocationService.instance.lastPositionSentTime!.minute.toString().padLeft(2, '0')}:${LocationService.instance.lastPositionSentTime!.second.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          Text(' (hace ${DateTime.now().difference(LocationService.instance.lastPositionSentTime!).inSeconds}s)',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                    SizedBox(height: 16),
                  ],
                ),
              
              // Sección de Eventos Recibidos
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📥 Eventos recibidos: ${widget.parentState._receivedCount}',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  if (widget.parentState._lastReceivedTime != null) ...[
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Text('${widget.parentState._lastReceivedTime!.hour.toString().padLeft(2, '0')}:${widget.parentState._lastReceivedTime!.minute.toString().padLeft(2, '0')}:${widget.parentState._lastReceivedTime!.second.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        Text(' (hace ${DateTime.now().difference(widget.parentState._lastReceivedTime!).inSeconds}s)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ] else ...[
                    SizedBox(height: 6),
                    Text('Sin eventos recibidos', 
                      style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                  SizedBox(height: 16),
                ],
              ),
              
              // Separador visual
              Divider(color: Colors.grey[300], height: 1),
              SizedBox(height: 12),
              
              // Estadísticas generales
              Text('Frecuencia total: $eventsPerSecond mensajes/seg',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
              SizedBox(height: 8),
              Text('Tiempo activo: ${_formatDuration(realSessionDuration)}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
              
              // Mensaje de desconexión con altura fija para evitar cambios de tamaño
              Container(
                height: 40, // Altura fija para evitar cambios de tamaño
                padding: EdgeInsets.only(top: 12),
                child: Builder(builder: (context) {
                  // Detectar cambio de estado de conexión
                  if (!emitterService.isConnected() && !_wasDisconnected) {
                    _wasDisconnected = true;
                    _disconnectionTime = DateTime.now();
                    // Mantener el mensaje visible por 5 segundos mínimo
                    _messageTimer?.cancel();
                    _messageTimer = Timer(Duration(seconds: 5), () {
                      if (mounted && emitterService.isConnected()) {
                        setState(() {
                          _wasDisconnected = false;
                        });
                      }
                    });
                  } else if (emitterService.isConnected() && _wasDisconnected) {
                    // Si se reconecta pero no ha pasado el tiempo mínimo, esperar
                    if (_disconnectionTime != null && 
                        DateTime.now().difference(_disconnectionTime!).inSeconds < 5) {
                      // Mantener mensaje visible
                    } else {
                      _wasDisconnected = false;
                    }
                  }
                  
                  return AnimatedOpacity(
                    opacity: (!emitterService.isConnected() || _wasDisconnected) ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Wrap(
                      children: [
                        Text(
                          'Conexión interrumpida. Verifique su conexión a internet',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

// Widget de marquee que se puede tocar para activar
class _TappableMarqueeText extends StatefulWidget {
  final String text;
  final double width;
  final TextStyle? style;

  const _TappableMarqueeText({
    Key? key,
    required this.text,
    required this.width,
    this.style,
  }) : super(key: key);

  @override
  State<_TappableMarqueeText> createState() => _TappableMarqueeTextState();
}

class _TappableMarqueeTextState extends State<_TappableMarqueeText> {
  bool _forceMarquee = false;
  bool _needsScroll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollNeeded();
    });
  }

  @override
  void didUpdateWidget(_TappableMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.width != widget.width) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfScrollNeeded();
      });
    }
  }

  void _checkIfScrollNeeded() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    
    setState(() {
      _needsScroll = textPainter.width > widget.width;
    });
  }

  void _onTap() {
    setState(() {
      _forceMarquee = !_forceMarquee;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowMarquee = _needsScroll || _forceMarquee;
    
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: widget.width,
        height: widget.style?.fontSize != null 
            ? (widget.style!.fontSize! * 1.5) 
            : 24,
        child: shouldShowMarquee
            ? MarqueeText(
                text: widget.text,
                width: widget.width,
                style: widget.style,
                velocity: 60.0,
                pauseAfterRound: Duration(seconds: 2),
                blankSpace: 80.0,
                autoStart: _forceMarquee || _needsScroll,
              )
            : Text(
                widget.text,
                style: widget.style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}

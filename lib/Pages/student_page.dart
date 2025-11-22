import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/Pages/history_absences.dart';
import 'package:eta_school_app/Pages/map/map_wiew.dart';
import 'package:eta_school_app/Pages/map/mapbox_utils.dart';
import 'package:eta_school_app/Pages/register_absences.dart';
import 'package:eta_school_app/Pages/upload_picture_page.dart';
import 'package:eta_school_app/components/button_text_icon.dart';
import 'package:eta_school_app/components/custom_row.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/image_default.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:eta_school_app/shared/location/location_service.dart';
import 'package:eta_school_app/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';

class StudentPage extends StatefulWidget {
  StudentPage({super.key, this.student, this.hasActiveTrip = false, this.isOnBoard = false});

  final StudentModel? student;
  final bool hasActiveTrip;
  final bool isOnBoard;

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  bool showLoader = true;

  MapboxMap? _mapboxMapController;

  PointAnnotationManager? annotationManager;

  PointAnnotation? studentPointAnnotation;

  bool connectivityNone = false;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  EmitterService? _emitterServiceProvider;
  
  bool _isVisible = true;
  late bool hasActiveTrip;
  bool isMapExpand = false;
  String relationName = '';

  // Variables for Emitter connection statistics (same as trip_page)
  int _messageCount = 0; // Total de mensajes (para compatibilidad)
  int _receivedCount = 0; // Eventos recibidos del estudiante
  DateTime? _sessionStartTime;
  DateTime? _lastMessageTime;
  DateTime? _lastReceivedTime;

  @override
  Widget build(BuildContext context) {
    // Si el rol no se ha cargado aún, mostrar loader
    if (relationName.isEmpty && !showLoader) {
      return Material(
        type: MaterialType.transparency,
        child: Loader(),
      );
    }
    
    return Material(
      type: MaterialType.transparency,
      child: showLoader
          ? Loader()
          : Scaffold(
              body: VisibilityDetector(
                  key: Key('student_home_key'),
                  onVisibilityChanged: (info) {
                      _isVisible = info.visibleFraction > 0;
                    if (info.visibleFraction > 0) {
                      // loadTrip();
                    }else{
                      cleanResources();
                    }
                  },
                  child: Stack(children: <Widget>[
                // El mapa ahora responde al estado de pantalla completa
                Positioned.fill(
                  bottom: isMapExpand ? 0 : MediaQuery.of(context).size.height * 0.45,
                  child: MapWiew(
                    navigationMode: relationName.isNotEmpty ? _shouldEnableTracking() : false, // Solo después de cargar rol
                    showLocationPuck: relationName.isNotEmpty ? _shouldShowLocationPuck() : false, // Solo después de cargar rol
                    centerOnSelf: relationName.isNotEmpty ? _shouldCenterOnSelf() : false, // Determina si centra en sí mismo o en el estudiante
                    showAutoFollowButton: true, // Siempre mostrar en vista de estudiante (siempre es "activa")
                    onCenterRequest: (relationName.isEmpty || !_shouldCenterOnSelf()) ? _centerOnStudent : null, // Callback para centrar en estudiante si es padre o rol no cargado
                    onMapReady: (MapboxMap mapboxMap) async {
                      _mapboxMapController = mapboxMap;
                      annotationManager = await mapboxMap.annotations
                          .createPointAnnotationManager();

                      if (widget.student?.lastPositionPayload != null) {
                        print(
                            "[StudentPage] lasposition ${widget.student?.lastPosition}");
                        final Position? position =
                            widget.student?.lastPosition()!;
                        final label = formatUnixEpoch(widget
                            .student?.lastPositionPayload['time']?.toInt());

                        _updateIcon(position!, 'eta.students',
                            widget.student!.student_id, label);
                      }
                    },
                    onStyleLoadedListener: (MapboxMap mapboxMap) async {},
                  ),
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
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    )),
                              ),
                            ),
                          ],
                        )),
                  ),
                // Botón de estado de conexión con diálogo completo
                Positioned(
                  top: 40,
                  right: 10,
                  child: Consumer<EmitterService>(
                      builder: (context, emitterService, child) {
                    return GestureDetector(
                      onTap: () => _showConnectionDialog(),
                      child: Tooltip(
                        message: emitterService.isConnected() 
                          ? 'Conectado - Toca para ver detalles' 
                          : 'Desconectado - Toca para ver detalles',
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
                      ),
                    );
                  }),
                ),
                
                // Botón de pantalla completa
                Positioned(
                  top: 90,  // Segundo botón - Fullscreen
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
                  snapAnimationDuration: const Duration(seconds: 1),
                  initialChildSize: .55,
                  minChildSize: 0.35,
                  maxChildSize: 0.7,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Stack(children: [
                      // Container(
                      //   width: double.infinity,
                      //   height: 75,
                      //   clipBehavior: Clip.antiAlias,
                      //   decoration: BoxDecoration(
                      //       gradient: LinearGradient(
                      //     begin: Alignment.topCenter,
                      //     end: Alignment.bottomCenter,
                      //     colors: [
                      //       Colors.black.withOpacity(0),
                      //       Colors.black.withOpacity(.5),
                      //     ],
                      //   )),
                      // ),
                      Container(
                        margin: EdgeInsets.only(top: 50),
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: activeTheme.main_bg,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(0.0, -3.0),
                              blurRadius: 5.0,
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        controller: scrollController,
                        child: Stack(children: [
                          Row(
                            textDirection:
                                isRTL() ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  uploadPicture();
                                },
                                child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                       decoration: hasActiveTrip 
                                         ? BoxDecoration(
                                             shape: BoxShape.circle,
                                             border: Border.all(
                                               color: widget.isOnBoard ? Colors.green : Colors.red,
                                               width: 3,
                                             ),
                                             boxShadow: [
                                               BoxShadow(
                                                 color: Colors.black.withOpacity(0.2),
                                                 blurRadius: 5,
                                                 spreadRadius: 1,
                                               )
                                             ],
                                           )
                                         : null,
                                       child: ClipOval(
                                         child: Container(
                                           width: 100,
                                           height: 100,
                                           color: Colors.white,
                                           child: Image.network(
                                             httpService.getAvatarUrl(
                                               widget.student?.student_id,
                                               'eta.students'),
                                             headers: {'Accept': 'image/png'},
                                             fit: BoxFit.cover,
                                             width: 100,
                                             height: 100,
                                             loadingBuilder: (context, child, loadingProgress) {
                                               if (loadingProgress == null) {
                                                 return child;
                                               }
                                               return Center(
                                                 child: CircularProgressIndicator(),
                                               );
                                             },
                                             errorBuilder: (context, error, stackTrace) => 
                                               ImageDefault(name: widget.student?.first_name ?? "", height: 100, width: 100),
                                           ),
                                         ),
                                       ),
                                     ))),
                              Column(
                                textDirection: isRTL()
                                    ? ui.TextDirection.rtl
                                    : ui.TextDirection.ltr,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Container(
                                  //   padding: EdgeInsets.only(top: 15),
                                  //   child: Text("${widget.student!.first_name}",
                                  //       style: TextStyle(
                                  //         fontSize: activeTheme.h5.fontSize,
                                  //         fontWeight: activeTheme.h4.fontWeight,
                                  //       )),
                                  // ),
                                  // Container(
                                  //   padding: EdgeInsets.symmetric(
                                  //       horizontal: 10, vertical: 4),
                                  //   decoration: BoxDecoration(
                                  //       color: activeTheme.buttonBG,
                                  //       borderRadius: BorderRadius.all(
                                  //           Radius.circular(10))),
                                  //   margin: EdgeInsets.only(top: 15),
                                  //   child: Text(
                                  //       "${widget.student!.route!.route_name}",
                                  //       style: TextStyle(
                                  //         color: activeTheme.buttonColor,
                                  //         fontWeight: FontWeight.bold,
                                  //       )),
                                  // ),
                                ],
                              ),
                              // Expanded(child: Icon(Icons.edit, color: activeTheme.icon_color,)),
                              // Padding(padding: EdgeInsets.only(top: 10, right: 20, left: 20), child: Icon(Icons.edit, color: activeTheme.icon_color,),)
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 80),
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            child: Column(
                                crossAxisAlignment: isRTL()
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  CustomRow(lang.translate('First Name'),
                                      widget.student?.first_name),
                                  Container(
                                    height: 1,
                                    color:
                                        activeTheme.main_color.withOpacity(.3),
                                  ),
                                  CustomRow(lang.translate('Last Name'),
                                      widget.student?.last_name),
                                  Container(
                                    height: 1,
                                    color:
                                        activeTheme.main_color.withOpacity(.3),
                                  ),
                                  Container(
                                    height: 1,
                                    color:
                                        activeTheme.main_color.withOpacity(.3),
                                  ),
                                  CustomRow(lang.translate('Contact number'),
                                      widget.student?.contact_number ?? ''),
                                  Container(
                                    height: 1,
                                    color:
                                        activeTheme.main_color.withOpacity(.3),
                                  ),

                                  SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(lang.translate('absences'),style: activeTheme.h5),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              openNewPage(context, HistoryAbsences(studentId: widget.student!.student_id));
                                            },
                                            child: ButtonTextIcon(
                                              lang.translate('history'),
                                              Icon(
                                                Icons.history,
                                                color: activeTheme.buttonColor,
                                              ),
                                              Color.fromARGB(
                                                  255, 226, 187, 32)),
                                          )
                                        ]
                                      ),
                                      const SizedBox(width: 20,),
                                      Column(
                                        children: [
                                         GestureDetector(
                                            onTap: () {
                                              openNewPage(context, RegisterAbsences(studentId: widget.student!.student_id));
                                            },
                                            child: ButtonTextIcon(
                                            lang.translate('notify'),
                                            Icon(
                                              Icons.note_alt,
                                              color: activeTheme.buttonColor,
                                            ),
                                            Colors.green)
                                          )
                                        ]
                                      ),
                                      ],
                                    ),
                                  ),
                                ]),
                          )
                        ]),
                      )
                    ]);
                  },
                ),
              ]),
            ),
    ));
  }

  /// Open map to set location
  uploadPicture() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UploadPicturePage(student_id: widget.student!.student_id)));

    setState(() {
      if (result != null) {
        widget.student!.picture = jsonDecode(result);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    showLoader = false;
    hasActiveTrip = widget.hasActiveTrip;
    
    // Cargar rol del usuario antes de inicializar servicios
    _initializeUserRoleAndServices();

    Wakelock.enable();

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _emitterServiceProvider =
        Provider.of<EmitterService>(context, listen: false);

    if (!_emitterServiceProvider!.isConnected()) {
      _emitterServiceProvider?.connect();
    }

    _emitterServiceProvider?.addListener(onEmitterMessage);
    _emitterServiceProvider?.startTimer(true);

    // Initialize Emitter session tracking
    _sessionStartTime = DateTime.now();
    _messageCount = 0;
    _receivedCount = 0;
    _lastMessageTime = null;
    _lastReceivedTime = null;

    // Ya no llamamos _initLocationServiceByRole() aquí porque se hace después de cargar el rol
  }

  @override
  void dispose() {
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

  Future<void> _updateIcon(Position position, String relationName,
      int relationId, String label) async {

    if (studentPointAnnotation== null) {
      String studentName = "";
      if (widget.student != null) {
        studentName = widget.student!.first_name ?? '';
      }
      
      final networkImage = await mapboxUtils
          .getNetworkImage(
            httpService.getAvatarUrl(relationId, relationName),
            name: studentName
          );
          
      final circleImage = await mapboxUtils.createCircleImage(networkImage, hasActiveTrip: hasActiveTrip, isOnBoard: widget.isOnBoard);
      studentPointAnnotation = await mapboxUtils.createAnnotation(
          annotationManager, position, circleImage, label);

      if ("$relationId" == "${widget.student?.student_id}") {
        _mapboxMapController?.setCamera(CameraOptions(
          center: Point(coordinates: position),
          zoom: 15.5,
          pitch: 70,
        ));
      }
    } else {
      studentPointAnnotation?.geometry = Point(coordinates: position);
      studentPointAnnotation?.textField = label;
      annotationManager?.update(studentPointAnnotation!);
    }

    if ("$relationId" == "${widget.student?.student_id}") {
      _mapboxMapController?.flyTo(
          CameraOptions(center: Point(coordinates: position)),
          MapAnimationOptions(duration: 1));
    }
  }

  void onEmitterMessage() async {
    String message = EmitterService.instance.lastMessage();

    // Update connection statistics
    _messageCount++;
    _lastMessageTime = DateTime.now();
    
    // Los mensajes recibidos en student_page son eventos del estudiante
    _receivedCount++;
    _lastReceivedTime = DateTime.now();

    try {
      // si es un evento del viaje
      final event = EventModel.fromJson(jsonDecode(message));
      await event.requestData();
    } catch (e) {
      try {
        //si es un evento posicion
        final Map<String, dynamic> tracking = jsonDecode(message);

        if (tracking['relation_name'] != null &&
            tracking['relation_name'] == 'eta.students') {
          final relationName = tracking['relation_name'];
          final relationId = tracking['relation_id'];

          if (tracking['payload'] != null) {
            final Position position = Position(
                double.parse("${tracking['payload']['longitude']}"),
                double.parse("${tracking['payload']['latitude']}"));
            final label = formatUnixEpoch(tracking['payload']['time']?.toInt());

            print(
                "[StudentPage.onEmitterMessage.emitter-tracking.student] $tracking");
            _updateIcon(position, relationName, relationId, label);

            widget.student?.lastPositionPayload = tracking['payload'];
          }
        }
      } catch (e) {
        print(e);
      }
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

  // Initialize user role and then location services
  Future<void> _initializeUserRoleAndServices() async {
    await _loadUserRole();
    await _initLocationServiceByRole();
    // Forzar rebuild para actualizar UI con el rol correcto
    if (mounted) {
      setState(() {
        print("[StudentPage._initializeUserRoleAndServices] UI rebuilt with relationName: '$relationName'");
      });
    }
  }

  // Load user role from storage
  Future<void> _loadUserRole() async {
    try {
      relationName = await storage.getItem('relation_name') ?? '';
      print("[StudentPage._loadUserRole] User role: $relationName");
    } catch (e) {
      print("[StudentPage._loadUserRole.error] $e");
    }
  }

  // Determine if tracking should be enabled based on user role
  bool _shouldEnableTracking() {
    print("[StudentPage._shouldEnableTracking] relationName: '$relationName', hasActiveTrip: ${widget.hasActiveTrip}");
    
    // SOLO estudiantes pueden hacer tracking en esta vista
    // Los conductores usan trip_page, no student_page
    bool isStudent = relationName.contains('eta.students');
    
    if (isStudent) {
      print("[StudentPage._shouldEnableTracking] Student role detected - enabling tracking");
      return true;
    }
    
    // Cualquier otro rol NO hace tracking
    print("[StudentPage._shouldEnableTracking] Non-student role ('$relationName') - disabling tracking");
    return false;
  }

  // Determine if location puck/dock should be shown
  bool _shouldShowLocationPuck() {
    print("[StudentPage._shouldShowLocationPuck] relationName: '$relationName', hasActiveTrip: ${widget.hasActiveTrip}");
    
    // En student_page NO mostramos el puck para ningún rol
    // Los padres ven la posición del estudiante, no la propia
    // Los estudiantes no necesitan ver su propio puck en esta vista
    print("[StudentPage._shouldShowLocationPuck] Always false in student_page - viewing student position, not self");
    return false;
  }
  
  // Determine if center button should center on self or on student
  bool _shouldCenterOnSelf() {
    // Si el rol no se ha cargado, por defecto NO centra en sí mismo (centra en estudiante)
    if (relationName.isEmpty) {
      print("[StudentPage._shouldCenterOnSelf] relationName empty - defaulting to centerOnStudent");
      return false;
    }
    
    // Solo los estudiantes centran en sí mismos
    // Los padres/tutores/representantes centran en el estudiante que están viendo
    bool isStudent = relationName.contains('eta.students');
    bool isParentOrGuardian = relationName.contains('eta.guardians') || 
                              relationName.contains('eta.parents') || 
                              relationName.contains('representante') ||
                              relationName.contains('tutor') ||
                              relationName.contains('guardian');
    
    print("[StudentPage._shouldCenterOnSelf] relationName: '$relationName', isStudent: $isStudent, isParent: $isParentOrGuardian, centerOnSelf: $isStudent");
    
    // Explícitamente retornar false para padres/tutores
    if (isParentOrGuardian) {
      return false;
    }
    
    return isStudent;
  }
  
  // Método para centrar el mapa en la posición del estudiante
  void _centerOnStudent() {
    print("[StudentPage._centerOnStudent] Called - Looking for student position to center on");
    
    if (studentPointAnnotation != null && _mapboxMapController != null) {
      final studentPosition = studentPointAnnotation!.geometry;
      print("[StudentPage._centerOnStudent] Centering on student annotation position: $studentPosition");
      _mapboxMapController!.flyTo(
        CameraOptions(
          center: studentPosition,
          zoom: 16.5,
          pitch: 70,
        ),
        MapAnimationOptions(duration: 1200, startDelay: 0)
      );
    } else if (widget.student?.lastPositionPayload != null && _mapboxMapController != null) {
      // Si no hay anotación pero tenemos la última posición conocida del estudiante
      final Position? position = widget.student?.lastPosition();
      if (position != null) {
        print("[StudentPage._centerOnStudent] Centering on last known student position: $position");
        _mapboxMapController!.flyTo(
          CameraOptions(
            center: Point(coordinates: position),
            zoom: 16.5,
            pitch: 70,
          ),
          MapAnimationOptions(duration: 1200, startDelay: 0)
        );
      } else {
        print("[StudentPage._centerOnStudent] lastPosition() returned null");
      }
    } else {
      print("[StudentPage._centerOnStudent] WARNING: No student position available to center on");
      print("[StudentPage._centerOnStudent] studentPointAnnotation: $studentPointAnnotation");
      print("[StudentPage._centerOnStudent] _mapboxMapController: $_mapboxMapController");
      print("[StudentPage._centerOnStudent] widget.student?.lastPositionPayload: ${widget.student?.lastPositionPayload}");
    }
  }

  // Determine if positions sent section should be shown in dialog
  bool _shouldShowPositionsSection() {
    print("[StudentPage._shouldShowPositionsSection] ===== INICIO =====");
    print("[StudentPage._shouldShowPositionsSection] relationName: '$relationName' (length: ${relationName.length})");
    print("[StudentPage._shouldShowPositionsSection] hasActiveTrip: ${widget.hasActiveTrip}");
    
    // Verificar que relationName se haya cargado
    if (relationName.isEmpty) {
      print("[StudentPage._shouldShowPositionsSection] relationName is EMPTY - hiding section");
      return false;
    }
    
    // SOLO estudiantes (y ÚNICAMENTE estudiantes) pueden enviar posiciones
    bool isStudent = relationName == 'eta.students' || 
                     relationName.toLowerCase() == 'estudiante' ||
                     relationName.toLowerCase() == 'student';
    
    if (isStudent) {
      print("[StudentPage._shouldShowPositionsSection] CONFIRMED Student role - SHOWING positions section");
      return true;
    }
    
    // Explícitamente loggear los roles de padres/tutores
    if (relationName.contains('guardian') || 
        relationName.contains('parent') ||
        relationName.contains('representante') ||
        relationName.contains('tutor')) {
      print("[StudentPage._shouldShowPositionsSection] PARENT/GUARDIAN role detected ('$relationName') - HIDING positions section");
      return false;
    }
    
    // Cualquier otro rol también NO ve la sección
    print("[StudentPage._shouldShowPositionsSection] Other role ('$relationName') - HIDING positions section");
    return false;
  }

  // Initialize LocationService based on user role
  Future<void> _initLocationServiceByRole() async {
    if (!_shouldEnableTracking()) {
      print("[StudentPage._initLocationServiceByRole] Tracking disabled for role: $relationName");
      return;
    }

    try {
      await LocationService.instance.init();
      // Los estudiantes no deben calcular distancia, solo reportar ubicación
      await LocationService.instance.startLocationService(calculateDistance: false);
      print("[StudentPage._initLocationServiceByRole] LocationService started for role: $relationName");
    } catch (e) {
      print("[StudentPage._initLocationServiceByRole.error] $e");
    }
  }


  // Método para mostrar el diálogo de conexión en vivo
  void _showConnectionDialog() {
    print("[StudentPage._showConnectionDialog] Opening dialog with relationName: '$relationName'");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _LiveConnectionDialog(
          key: ValueKey('connection_dialog_${DateTime.now().millisecondsSinceEpoch}'), // Forzar recreación
          parentState: this,
        );
      },
    );
  }
  
  void cleanResources() {
    _emitterServiceProvider?.removeListener(onEmitterMessage);
    _emitterServiceProvider?.stopTimer();
    _connectivitySubscription.cancel();
    Wakelock.disable();
    
    // Stop LocationService if we started it
    if (_shouldEnableTracking()) {
      try {
        LocationService.instance.stopLocationService();
        print("[StudentPage.cleanResources] LocationService stopped for role: $relationName");
      } catch (e) {
        print("[StudentPage.cleanResources.stopLocationService.error] $e");
      }
    }
    
    super.dispose();
  }
}

// Widget del diálogo de conexión en vivo que se actualiza automáticamente (para student_page)
class _LiveConnectionDialog extends StatefulWidget {
  final _StudentPageState parentState;

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
    // Actualizar el diálogo cada segundo
    _updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Fuerza actualización de la UI
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
        final currentMessageCount = widget.parentState._messageCount;
        
        // Re-evaluar la condición en cada rebuild
        final shouldShowPositions = widget.parentState._shouldShowPositionsSection();
        print("[LiveConnectionDialog.build] shouldShowPositions: $shouldShowPositions, relationName: '${widget.parentState.relationName}'");
        
        // Calcular tiempo real desde el inicio de la sesión del emitter
        final realSessionDuration = widget.parentState._sessionStartTime != null
            ? DateTime.now().difference(widget.parentState._sessionStartTime!).inSeconds
            : 0;
            
        final eventsPerSecond = realSessionDuration > 0 
            ? (currentMessageCount / realSessionDuration).toStringAsFixed(2)
            : '0.00';
        
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
              
              // Sección de Posiciones Enviadas (solo si el usuario actual puede enviar posiciones)
              if (shouldShowPositions) ...[
                // Debug print justo antes de mostrar la sección
                Builder(builder: (context) {
                  print("[LiveConnectionDialog] SHOWING positions section for role: '${widget.parentState.relationName}'");
                  return SizedBox.shrink();
                }),
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
                  ] else ...[
                    SizedBox(height: 6),
                    Text('Sin posiciones enviadas', 
                      style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                  SizedBox(height: 16),
                ],
              ),
              ],
              
              // Sección de Eventos Recibidos del estudiante
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

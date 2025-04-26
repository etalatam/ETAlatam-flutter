import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/Pages/history_absences.dart';
import 'package:eta_school_app/Pages/map/map_wiew.dart';
import 'package:eta_school_app/Pages/map/mapbox_utils.dart';
import 'package:eta_school_app/Pages/providers/emitter_service_provider.dart';
import 'package:eta_school_app/Pages/register_absences.dart';
import 'package:eta_school_app/Pages/upload_picture_page.dart';
import 'package:eta_school_app/components/button_text_icon.dart';
import 'package:eta_school_app/components/custom_row.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/image_default.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:eta_school_app/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.40,
                  child: MapWiew(
                    navigationMode: false,
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
                            .student?.lastPositionPayload['time']
                            .toInt());

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
                Positioned(
                  top: 40,
                  right: 10,
                  child: Consumer<EmitterService>(
                      builder: (context, emitterService, child) {
                    return Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: emitterService.isConnected()
                            ? Colors.green
                            : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    );
                  }),
                ),
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
                                isRTL() ? TextDirection.rtl : TextDirection.ltr,
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
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
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
    String message = emitterServiceProvider.lastMessage();

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
            final label = formatUnixEpoch(tracking['payload']['time'].toInt());

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

  String formatUnixEpoch(int unixEpoch) {
    // Convierte el Unix Epoch (segundos) a milisegundos
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixEpoch);
    return Utils.formatearFechaCorta(dateTime);
    // Formatea la fecha como desees
    // return '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }
  
  void cleanResources() {
    _emitterServiceProvider?.removeListener(onEmitterMessage);
    _emitterServiceProvider?.stopTimer();
    _connectivitySubscription.cancel();
    Wakelock.disable();
    super.dispose();
  }
}

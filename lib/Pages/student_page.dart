import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/Pages/map/map_wiew.dart';
import 'package:eta_school_app/Pages/map/mapbox_utils.dart';
import 'package:eta_school_app/Pages/providers/emitter_service_provider.dart';
import 'package:eta_school_app/Pages/upload_picture_page.dart';
import 'package:eta_school_app/components/custom_row.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class StudentPage extends StatefulWidget {
  StudentPage({super.key, this.student});

  final StudentModel? student;

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  bool showLoader = true;

  MapboxMap? _mapboxMapController;

  PointAnnotationManager? annotationManager;

  Map<String, PointAnnotation> annotationsMap = {};

  bool connectivityNone = false;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  Timer? _timer;
    
  DateTime? _lastEmitterDate = DateTime.now();
  
  EmitterService? _emitterServiceProvider;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.40,
                  child: MapWiew(
                    navigationMode: false,
                    onMapReady: (MapboxMap mapboxMap) async {
                      _mapboxMapController = mapboxMap;
                      annotationManager = await mapboxMap.annotations
                          .createPointAnnotationManager();
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
                    child:  Consumer<EmitterService>(builder: (context, emitterService, child) {
                      return Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: emitterService.client!.isConnected? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                      );
                    }),

                  ),
                DraggableScrollableSheet(
                  snapAnimationDuration: const Duration(seconds: 1),
                  initialChildSize: .35,
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
                                    child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.white,
                                        foregroundImage: NetworkImage(
                                            httpService.getAvatarUrl(
                                                widget.student?.student_id,
                                                'eta.students'),
                                            headers: {'Accept': 'image/png'}))),
                              ),
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
                                      widget.student?.contact_number),
                                  Container(
                                    height: 1,
                                    color:
                                        activeTheme.main_color.withOpacity(.3),
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
    );
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
    
    Wakelock.enable();

    _emitterServiceProvider = Provider.of<EmitterService>(context, listen: false);
    _emitterServiceProvider?.addListener(onEmitterMessage);

    initConnectivity();

    _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _startTimer();

    if (widget.student?.lastPosition != null) {
      print("[StudentPage] lasposition ${widget.student?.lastPosition}");
      final Position position = Position(
          double.parse("${widget.student?.lastPosition['longitude']}"),
          double.parse("${widget.student?.lastPosition['latitude']}"));
          final label = formatUnixEpoch(widget.student?.lastPosition['time'].toInt());

      _updateIcon(position, 
      'eta.students', 
        widget.student!.student_id,
         label);
    }
  }

  @override
  void dispose() {
    _emitterServiceProvider?.removeListener(onEmitterMessage);
    Wakelock.disable();
    _timer?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
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
  
  void _startTimer() {

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      final now = DateTime.now();
      final difference = now.difference(_lastEmitterDate!);
      print("[StudentPage.emittertimer.difference] ${difference.inSeconds}s.");

      if (difference.inSeconds >= 30) {
        print("[StudentPage.emittertimer] restaring... ");
        emitterServiceProvider.close();
        emitterServiceProvider.connect();
        _lastEmitterDate = DateTime.now();
      }
    });
  }


  Future<void> _updateIcon(
      Position position, String relationName, int relationId, String label) async {
    PointAnnotation? pointAnnotation =
        annotationsMap.containsKey("$relationName.$relationId")
            ? annotationsMap["$relationName.$relationId"]
            : null;

    if (pointAnnotation == null) {
      final networkImage = await mapboxUtils
          .getNetworkImage(httpService.getAvatarUrl(relationId, relationName));
      final circleImage = await mapboxUtils.createCircleImage(networkImage);
      pointAnnotation = await mapboxUtils.createAnnotation(
          annotationManager, position, circleImage, label);
      annotationsMap["$relationName.$relationId"] = pointAnnotation!;

      if ("$relationId" == "${widget.student?.student_id}") {
        _mapboxMapController?.setCamera(CameraOptions(
          center: Point(coordinates: position),
          zoom: 15.5,
          pitch: 70,
        ));
      }
    } else {
      pointAnnotation.geometry = Point(coordinates: position);
      pointAnnotation.textField = label;
      annotationManager?.update(pointAnnotation);
    }

    if ("$relationId" == "${widget.student?.student_id}") {
      _mapboxMapController?.flyTo(
          CameraOptions(center: Point(coordinates: position)),
          MapAnimationOptions(duration: 1));
    }
  }

  void onEmitterMessage() async {

    _lastEmitterDate = DateTime.now();
    if (mounted) {
      final String message =
          Provider.of<EmitterService>(context, listen: false).lastMessage;

      if(message.isEmpty) return;

      try {
        // si es un evento del viaje
        final event = EventModel.fromJson(jsonDecode(message));
        await event.requestData();
      } catch (e) {
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
          }
        }
      }
    }
  }

  String formatUnixEpoch(int unixEpoch) {
    // Convierte el Unix Epoch (segundos) a milisegundos
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixEpoch * 1000);

    // Formatea la fecha como desees
    return '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

}

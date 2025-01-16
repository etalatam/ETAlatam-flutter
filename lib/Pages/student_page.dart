import 'dart:convert';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/Pages/map/map_wiew.dart';
import 'package:eta_school_app/Pages/map/mapbox_utils.dart';
import 'package:eta_school_app/Pages/upload_picture_page.dart';
import 'package:eta_school_app/components/custom_row.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

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
                    },
                    onStyleLoadedListener: (MapboxMap mapboxMap) async {},
                  ),
                ),
                DraggableScrollableSheet(
                  snapAnimationDuration: const Duration(seconds: 1),
                  initialChildSize: .4,
                  minChildSize: 0.4,
                  maxChildSize: 0.7,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Stack(children: [
                      Container(
                        width: double.infinity,
                        height: 75,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(.5),
                          ],
                        )),
                      ),
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
                          child: 
                          Column(
                            crossAxisAlignment: isRTL()
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                              CustomRow(lang.translate('First Name'),
                                  widget.student?.first_name),
                              Container(
                                height: 1,
                                color: activeTheme.main_color.withOpacity(.3),
                              ),
                              CustomRow(lang.translate('Last Name'),
                                  widget.student?.last_name),
                              Container(
                                height: 1,
                                color: activeTheme.main_color.withOpacity(.3),
                              ),
                              
                              Container(
                                height: 1,
                                color: activeTheme.main_color.withOpacity(.3),
                              ),
                              CustomRow(lang.translate('Contact number'),
                                  widget.student?.contact_number),
                              Container(
                                height: 1,
                                color: activeTheme.main_color.withOpacity(.3),
                              ),
                          ]
                          ),
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
    Provider.of<EmitterService>(context, listen: false)
        .addListener(onEmitterMessage);
  }

  Future<void> _updateIcon(
      Position position, String relationName, int relationId) async {
    PointAnnotation? pointAnnotation =
        annotationsMap["$relationName.$relationId"];

    if (pointAnnotation == null) {
      final networkImage = await mapboxUtils
          .getNetworkImage(httpService.getAvatarUrl(relationId, relationName));
      final circleImage = await mapboxUtils.createCircleImage(networkImage);
      pointAnnotation = await mapboxUtils.createAnnotation(
          annotationManager, position, circleImage);
    } else {
      pointAnnotation.geometry = Point(coordinates: position);
      annotationManager?.update(pointAnnotation);
    }
    _mapboxMapController
        ?.setCamera(CameraOptions(center: Point(coordinates: position)));
  }

  void onEmitterMessage() async {
    if (mounted) {
      final String? message =
          Provider.of<EmitterService>(context, listen: false).lastMessage;

      try {
        // si es un evento del viaje
        final event = EventModel.fromJson(jsonDecode(message!));
        await event.requestData();
      } catch (e) {
        //si es un evento posicion
        final Map<String, dynamic> tracking = jsonDecode(message!);

        if (tracking['relation_name'] != null &&
            tracking['relation_name'] == 'eta.students') {
          final relationName = tracking['relation_name'];
          final relationId = tracking['relation_id'];

          if (tracking['payload'] != null) {
            final Position position = Position(
                double.parse("${tracking['payload']['longitude']}"),
                double.parse("${tracking['payload']['latitude']}"));

            print(
                "[TripPage.onEmitterMessage.emitter-tracking.student] $tracking");
            _updateIcon(position, relationName, relationId);
          }
        }
      }
    }
  }
}

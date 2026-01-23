import 'dart:async';
import 'dart:convert';
import 'package:eta_school_app/Models/attendance_model.dart';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/Pages/student_page.dart';
import 'package:eta_school_app/Pages/trip_page.dart';
import 'package:eta_school_app/components/active_trip.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Models/parent_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GuardiansHome extends StatefulWidget {
  @override
  State<GuardiansHome> createState() => _GuardiansHomeState();
}

class _GuardiansHomeState extends State<GuardiansHome>
    with ETAWidgets, MediansTheme {
  final widgets = ETAWidgets;

  late GoogleMapController mapController;

  ParentModel? parentModel =
      ParentModel(parentId: 0, firstName: '', contactNumber: "", students: []);

  bool showLoader = true;

  List<TripModel> oldTripsList = [];

  List<TripModel> activeTrips = [];
  
  List<Map<String, dynamic>> studentsTrips = [];

  EmitterService? _emitterServiceProvider;
  EmitterTopic? _schoolEventsTopic;
  bool _isFirstLoad = true;

  bool _studentHasActiveTrip(int studentId) {
    for (var studentInfo in studentsTrips) {
      if (studentInfo['studentId'] == studentId) {
        return studentInfo['hasActiveTrip'] ?? false;
      }
    }
    return false; 
  }

  bool _studentIsOnBoard(int studentId) {
    for (var studentInfo in studentsTrips) {
      if (studentInfo['studentId'] == studentId) {
        return studentInfo['isOnBoard'] ?? false;
      }
    }
    return false; 
  }

  @override
  Widget build(BuildContext context) {
    activeTheme =
        storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();
    return showLoader
        ? Loader()
        : Material(
            type: MaterialType.transparency,
            child: Scaffold(
                body: RefreshIndicator(
                    triggerMode: RefreshIndicatorTriggerMode.onEdge,
                    onRefresh:
                        _refreshData, // Function to be called on pull-to-refresh
                    child: VisibilityDetector(
                          key: Key('guardians_home_key'),
                          onVisibilityChanged: (info) {
                            if (info.visibleFraction > 0 && _isFirstLoad) {
                              _isFirstLoad = false;
                              loadParent();
                            }
                          }, 
                      child:Stack(
                      children: [                        
                        Container(
                            color: activeTheme.main_bg,
                            height: MediaQuery.of(context).size.height,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: 100),
                              physics: AlwaysScrollableScrollPhysics(),
                              child: Stack(children: <Widget>[
                                Container(
                                  color: activeTheme.main_bg,
                                  margin: EdgeInsets.only(top: 120),
                                  child: Column(children: [
                                    activeTrips.isEmpty
                                        ? ETAWidgets.infoMessage(lang.translate(
                                            "Does not have active trips"))
                                        : SizedBox(
                                            height: 150,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: activeTrips.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return SizedBox(
                                                      width: 400,
                                                      child: ActiveTrip(
                                                          openTrip,
                                                          activeTrips[index]));
                                                })),

                                    ETAWidgets.svgTitle(
                                        "assets/svg/school.svg",
                                        lang.translate(
                                            "List of your added children")),

                                    SizedBox(height: 10),

                                    /// Students list
                                    parentModel!.students.isEmpty
                                        ? Center()
                                        : SizedBox(
                                            height: 230,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: parentModel!.students
                                                  .length, // Replace with the total number of items
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                /// Student block
                                                return GestureDetector(
                                                    onTap: () {
                                                      openNewPage(
                                                          context,
                                                          StudentPage(
                                                              student: parentModel!
                                                                      .students[
                                                                  index],
                                                              hasActiveTrip: _studentHasActiveTrip(parentModel!.students[index].student_id),
                                                              isOnBoard: _studentIsOnBoard(parentModel!.students[index].student_id)));
                                                    },
                                                    child: ETAWidgets
                                                        .homeStudentBlock(
                                                            context,
                                                            parentModel!
                                                                    .students[
                                                                index],
                                                            hasActiveTrip: _studentHasActiveTrip(parentModel!.students[index].student_id),
                                                            isOnBoard: _studentIsOnBoard(parentModel!.students[index].student_id)));
                                              },
                                            ),
                                          ),

                                    SizedBox(
                                      height: 10,
                                    ),

                                    ETAWidgets.svgTitle("assets/svg/route.svg",
                                        lang.translate('trips_history')),

                                    /// Old trips
                                    SizedBox(
                                        height: 250,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: oldTripsList
                                                .length, // Replace with the total number of items
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return GestureDetector(
                                                  onTap: () {
                                                    openNewPage(
                                                        context,
                                                        TripPage(
                                                          trip: oldTripsList[
                                                              index],
                                                          navigationMode: false,
                                                          showBus: false,
                                                          showStudents: false,
                                                        ));
                                                  },
                                                  child:
                                                      ETAWidgets.homeTripBlock(
                                                          context,
                                                          oldTripsList[index]));
                                            })),
                                  ]),
                                ),
                              ]),
                            )),
                        Positioned(left: 0, right: 0, top: 0, child: Header()),
                      ],
                    )))));
  }

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    if(mounted){
      setState(() {
        showLoader = true;
      });
    }

    loadParent();
  }

  loadParent() async {
    if (!mounted) return;

    final check = await storage.getItem('id_usu');
    if (check == null || !mounted) return;

    try {
      final parentQuery = await httpService.getParent();
      if(mounted){
        setState(() {
          parentModel = parentQuery;
        });
      }else{
        parentModel = parentQuery;
      }
        
      studentsTrips.clear();
      
      for (var student in parentModel!.students) {
        student.subscribeToStudentTracking();
        
        try {
          final List<AttendanceModel> studentTrips = await httpService.getStudentActiveTrips(student.student_id);
          final bool hasActiveTrip = studentTrips.isNotEmpty;
          bool isOnBoard = false;
          
          if (hasActiveTrip) {
            isOnBoard = studentTrips[0].onBoarding();
          }
          
          studentsTrips.add({
            'studentId': student.student_id,
            'hasActiveTrip': hasActiveTrip,
            'isOnBoard': isOnBoard
          });
          print('Student ${student.student_id} has active trip: $hasActiveTrip, isOnBoard: $isOnBoard');
        } catch (e) {
          print('Error al verificar viaje activo para estudiante ${student.student_id}: $e');
          studentsTrips.add({
            'studentId': student.student_id,
            'hasActiveTrip': false,
            'isOnBoard': false
          });
        }
      }
    } catch (e) {
      print("[GuardianHome.loadParent] error loading parent info : $e");
    }

    try {
      final results = await Future.wait([
        httpService.getGuardianTrips("true"),
        httpService.getGuardianRoutes(),
        httpService.getGuardianTrips("false"),
      ]);

      final List<TripModel> trips = results[0] as List<TripModel>;
      final List<RouteModel> routes = results[1] as List<RouteModel>;
      final List<TripModel> oldTrips = results[2] as List<TripModel>;

      for (var trip in trips) {
        trip.subscribeToTripTracking(_emitterServiceProvider);
      }
      await _subscribeToSchoolEvents();

      if(mounted){
        setState(() {
          activeTrips = trips;
        });
      }else{
        activeTrips = trips;
      }

      print("[GuardianHome.loadParent] routes count: ${routes.length}");

      if(mounted){
        setState(() {
          oldTripsList = oldTrips;
        });
      }else{
        oldTripsList = oldTrips;
      }
    } catch (e) {
      print("[GuardianHome.loadParent] error loading data in parallel: $e");
    } finally {
      if(mounted){
        setState(() {
          showLoader = false;
        });
      }else{
        showLoader = false;
      }
    }
  }

  openTrip(trip) {
    Get.to(TripPage(
      trip: trip,
      navigationMode: false, // Padres/representantes nunca tienen navigationMode activo
      showBus: true,
      showStudents: true,
    ));
  }

  @override
  void initState() {
    super.initState();

    showLoader = true;

    Provider.of<NotificationService>(context, listen: false)
          .addListener(onPushMessage);

    _emitterServiceProvider =
        Provider.of<EmitterService>(context, listen: false);
    _emitterServiceProvider?.addListener(_onEmitterMessage);

    if(_emitterServiceProvider != null && !_emitterServiceProvider!.isConnected()){
      _emitterServiceProvider?.connect();
    }
    
    loadParent();
  }

  @override
  void dispose() {
    _unsubscribeFromSchoolEvents();
    _emitterServiceProvider?.removeListener(_onEmitterMessage);
    Provider.of<NotificationService>(context, listen: false)
        .removeListener(onPushMessage);
    super.dispose();
  }

  onPushMessage() {
    loadParent();
  }

  void _onEmitterMessage() {
    if (!mounted) return;
    
    final message = _emitterServiceProvider?.lastMessage();
    try {
      final jsonMsg = jsonDecode(message!);
      
      // Actualizar viaje activo cuando llegue nueva posición
      if (jsonMsg['relation_name'] == 'eta.drivers' && 
          jsonMsg['payload'] != null) {
        
        if (mounted) {
          setState(() {
            for (var i = 0; i < activeTrips.length; i++) {
              if (activeTrips[i].driver_id == jsonMsg['relation_id']) {
                activeTrips[i].lastPositionPayload = jsonMsg['payload'];
                break;
              }
            }
          });
        }
      }
      
      // Si el viaje terminó o inició, verificar si es relevante para el usuario
      if (jsonMsg['event_type'] == 'end-trip' || jsonMsg['event_type'] == 'start-trip') {
        final eventTripId = jsonMsg['id_trip'];

        if (jsonMsg['event_type'] == 'start-trip') {
          print('[GuardiansHome] Evento start-trip recibido, recargando datos...');
          if (mounted) loadParent();
        } else if (jsonMsg['event_type'] == 'end-trip') {
          final bool isRelevant = activeTrips.any((trip) => trip.trip_id == eventTripId);
          if (isRelevant) {
            print('[GuardiansHome] Evento end-trip recibido para viaje activo $eventTripId, recargando datos...');
            if (mounted) loadParent();
          }
        }
      }

      // Si una parada fue visitada o reseteada, solo actualizar el trip (no todo el home)
      if (jsonMsg['event_type'] == 'point-arrival' || jsonMsg['event_type'] == 'point-reset' ||
          jsonMsg['event_type'] == 'point-departure' || jsonMsg['event_type'] == 'proximity-to-point') {
        final eventTripId = jsonMsg['id_trip'];
        final bool isRelevant = activeTrips.any((trip) => trip.trip_id == eventTripId);
        if (isRelevant) {
          print('[GuardiansHome] Evento ${jsonMsg['event_type']} recibido para viaje activo $eventTripId, actualizando trip...');
          if (mounted) _refreshActiveTrips(eventTripId);
        }
      }
    } catch (e) {
      // No es un mensaje JSON válido o no es relevante
    }
  }

  Future<void> _refreshActiveTrips(int tripId) async {
    try {
      final List<TripModel> trips = await httpService.getGuardianTrips("true");
      if (mounted && trips.isNotEmpty) {
        setState(() {
          for (int i = 0; i < activeTrips.length; i++) {
            if (activeTrips[i].trip_id == tripId) {
              final updatedTrip = trips.firstWhere(
                (t) => t.trip_id == tripId,
                orElse: () => activeTrips[i],
              );
              activeTrips[i] = updatedTrip;
              break;
            }
          }
        });
      }
    } catch (e) {
      print('[GuardiansHome._refreshActiveTrips] Error: $e');
    }
  }

  Future<void> _subscribeToSchoolEvents() async {
    try {
      if (parentModel == null || parentModel!.students.isEmpty) return;
      
      final int? schoolId = parentModel!.schoolId ?? 
          parentModel!.students.fold<int?>(null, (prev, s) => prev ?? s.schoolId);
      
      if (schoolId == null) {
        print('[GuardiansHome] No se pudo obtener schoolId para suscribirse a eventos');
        return;
      }

      final channel = 'events/school/$schoolId/';
      final keyModel = await httpService.emitterKeyGen('events/school/$schoolId/');
      
      if (keyModel?.key == null || keyModel!.key!.isEmpty) {
        print('[GuardiansHome] No se pudo obtener key para canal de eventos');
        return;
      }

      if (_schoolEventsTopic != null) {
        try {
          _emitterServiceProvider?.unsubscribe(_schoolEventsTopic!);
        } catch (_) {}
      }

      _schoolEventsTopic = EmitterTopic(channel, keyModel.key!);
      _emitterServiceProvider?.subscribe(_schoolEventsTopic!);
      print('[GuardiansHome] Suscrito a canal de eventos: $channel');
    } catch (e) {
      print('[GuardiansHome] Error suscribiendo a eventos de escuela: $e');
    }
  }

  void _unsubscribeFromSchoolEvents() {
    if (_schoolEventsTopic != null) {
      try {
        _emitterServiceProvider?.unsubscribe(_schoolEventsTopic!);
      } catch (_) {}
      _schoolEventsTopic = null;
    }
  }

}

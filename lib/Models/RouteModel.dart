import 'dart:core';
import 'package:MediansSchoolDriver/Models/VehicleModel.dart';
import 'package:MediansSchoolDriver/Models/DriverModel.dart';
import 'package:MediansSchoolDriver/Models/PickupLocationModel.dart';
import 'package:MediansSchoolDriver/Models/DestinationModel.dart';
import 'package:MediansSchoolDriver/Pages/providers/driver_provider.dart';
import 'package:MediansSchoolDriver/domain/entities/user/driver.dart';

class RouteModel {
  int? route_id;
  String? route_name;
  String? description;
  double? latitude;
  double? longitude;
  List<PickupLocationModel> pickup_locations;
  List<DestinationModel>? destinations;
  Driver? driver;
  VehicleModel? vehicle;
  String? busPlate;
  String? busModel;
  String? startTime;
  String? endTime;
  String? busYear;
  int? driverId;
  int? monitorId;

  RouteModel({
    required this.route_id,
    required this.route_name,
    this.description,
    this.latitude,
    this.longitude,
    required this.pickup_locations,
    this.destinations,
    this.driver,
    this.vehicle,
    this.busPlate,
    this.busModel,
    this.busYear,
    this.endTime,
    this.startTime,
    this.driverId,
    this.monitorId,
  });

  // Convertimos el factory en un Future para manejar la carga asíncrona del driver
  static Future<RouteModel> fromJson(Map<String, dynamic> json) async {
    // Cargamos el driver de forma asíncrona
    Driver? driver = await driverProvider.load();

    // Procesamos las otras partes del JSON
    final init = json["schedule_start_time"];
    List<String> initParts = init.split(':');
    String initTime = "${initParts[0]}:${initParts[1]}";

    final end = json["schedule_end_time"];
    List<String> endParts = end.split(':');
    String endTime = "${endParts[0]}:${endParts[1]}";

    final description = "Horario: $initTime - $endTime";

    return RouteModel(
      route_id: json['route_id'] as int?,
      route_name: json['route_description'] ?? '',
      description: description,
      busPlate: json['bus_plate'] ?? 'Sin información',
      startTime: json["schedule_start_time"] ?? '',
      endTime: json["schedule_end_time"] ?? '',
      driverId: json['driver_id'],
      monitorId: json['monitor_id'],
      pickup_locations: [], // TODO: a agregar al API las ubicaciones
      driver: driver, // Asignamos el driver cargado
      // Puedes asignar los vehículos y destinos según lo que se tenga disponible
    );
  }
}

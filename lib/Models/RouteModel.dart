import 'dart:core';
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
    // {
    //     "schedule_start_time": "05:30:00",
    //     "schedule_end_time": "07:30:00",
    //     "route_id": 1,
    //     "route_description": "Ruta1",
    //     "bus_plate": "ABCDEF",
    //     "bus_model": "",
    //     "bus_year": 2006,
    //     "driver_id": 25,
    //     "monitor_id": 3,
    //     "relation_name_monitor": "eta.drivers"
    // },
    
    final veh = {
      "vehicle_id": driver?.driver_id,
      "vehicle_name": json['bus_plate'],
      "vehicle_type": json['bus_model'],
      "plate_number": json['bus_plate'],
      "picture": "https://example.com/vehicle_image.png",
      "capacity": null,
      "maintenance_status": null,
      "driver_id": driver?.driver_id,
      "route_id": json['route_id'],
      "last_latitude": "10.4912",
      "last_longitude": "-66.9028"
    };
    final vehicle = VehicleModel.fromJson(veh);

    List<Map<String, dynamic>> test = [
      {
        "id": 2,
        "id_route": 1,
        "id_pickup_point": 2,
        "register_ts": "2024-08-24T12:47:00.693317",
        "name": "Parada1",
        "address": null,
        "lon": null,
        "lat": null
      },
      {
        "id": 3,
        "id_route": 1,
        "id_pickup_point": 4,
        "register_ts": "2024-08-24T13:39:45.310855",
        "name": "Parada2",
        "address": null,
        "lon": null,
        "lat": null
      },
      {
        "id": 4,
        "id_route": 1,
        "id_pickup_point": 6,
        "register_ts": "2024-08-24T13:39:45.310855",
        "name": "Parada3",
        "address": null,
        "lon": null,
        "lat": null
      }
    ];

    final List<PickupLocationModel> pickupLocation =
        test.map((dynamic item) => PickupLocationModel.fromJson(item)).toList();

    return RouteModel(
        route_id: json['route_id'] as int?,
        route_name: json['route_description'] ?? '',
        description: description,
        busPlate: json['bus_plate'] ?? 'Sin información',
        startTime: json["schedule_start_time"] ?? '',
        endTime: json["schedule_end_time"] ?? '',
        driverId: json['driver_id'],
        monitorId: json['monitor_id'],
        pickup_locations: pickupLocation,
        driver: driver, // Asignamos el driver cargado
        vehicle: vehicle,
        latitude: 10,
        longitude: -66
        // Puedes asignar los vehículos y destinos según lo que se tenga disponible
        );
  }
}
